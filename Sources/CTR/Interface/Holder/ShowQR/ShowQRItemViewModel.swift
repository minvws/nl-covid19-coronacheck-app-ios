/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ShowQRItemViewModel: Logging {

	// MARK: - Static
	
	static let domesticCorrectionLevel = "M"
	static let internationalCorrectionLevel = "Q"
	static let screenshotWarningMessageDuration: TimeInterval = 3 * 60

	// MARK: - vars

	var loggingCategory: String = "ShowQRViewModel"

	weak private var coordinator: HolderCoordinatorDelegate?
	weak private var cryptoManager: CryptoManaging? = Services.cryptoManager
	weak private var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager

	weak var validityTimer: Timer?
	weak private var screenshotWarningTimer: Timer?

	private var previousBrightness: CGFloat?
	private var greenCard: GreenCard
	private let screenCaptureDetector: ScreenCaptureDetectorProtocol

	private var currentQRImage: UIImage? {
		didSet {
			updateQRVisibility()
		}
	}

	private var screenIsBeingCaptured: Bool {
		didSet {
			updateQRVisibility()
		}
	}

	private var screenIsBlockedForScreenshotWithSecondsRemaining: Int? {
		didSet {
			updateQRVisibility()
		}
	}

	@Bindable private(set) var title: String?
    
    @Bindable private(set) var qrAccessibility: String?

	@Bindable private(set) var infoButtonAccessibility: String?

	@Bindable private(set) var visibilityState: ShowQRImageView.VisibilityState = .loading

	@Bindable private(set) var showInternationalAnimation: Bool = false

	@Bindable private(set) var thirdPartyTicketAppButtonTitle: String?

	private lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()

	private lazy var printDateTimeFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()

	private let userSettings: UserSettingsProtocol
	private let now: () -> Date
	private var clockDeviationObserverToken: ClockDeviationManager.ObserverToken?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - greenCard: a greencard to display
	///   - screenCaptureDetector: the screen capture detector
	init(
		coordinator: HolderCoordinatorDelegate,
		greenCard: GreenCard,
		thirdPartyTicketAppName: String?,
		screenCaptureDetector: ScreenCaptureDetectorProtocol = ScreenCaptureDetector(),
		userSettings: UserSettingsProtocol,
		now: @escaping () -> Date = Date.init
	) {

		self.coordinator = coordinator
		self.greenCard = greenCard
		self.screenCaptureDetector = screenCaptureDetector
		self.userSettings = userSettings
		self.now = now

		if greenCard.type == GreenCardType.domestic.rawValue {
			title = L.holderShowqrDomesticTitle()
			qrAccessibility = L.holderShowqrDomesticQrTitle()
			infoButtonAccessibility = L.holderShowqrDomesticAboutTitle()
			showInternationalAnimation = false
			thirdPartyTicketAppButtonTitle = thirdPartyTicketAppName.map { L.holderDashboardQrBackToThirdPartyApp($0) }
		} else if greenCard.type == GreenCardType.eu.rawValue {
			title = L.holderShowqrEuTitle()
            qrAccessibility = L.holderShowqrEuQrTitle()
			infoButtonAccessibility = L.holderShowqrEuAboutTitle()
			showInternationalAnimation = true
		}

		screenIsBeingCaptured = screenCaptureDetector.screenIsBeingCaptured

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.screenIsBeingCaptured = isBeingCaptured
		}

		screenCaptureDetector.screenshotWasTakenCallback = { [weak self] in
			guard self?.screenIsBlockedForScreenshotWithSecondsRemaining == nil else { return }
			userSettings.lastScreenshotTime = now()
			self?.screenshotWasTaken(blockQRUntil: now().addingTimeInterval(ShowQRItemViewModel.screenshotWarningMessageDuration))
		}

		if let lastScreenshotTime = userSettings.lastScreenshotTime {
			let expiryDate = lastScreenshotTime.addingTimeInterval(ShowQRItemViewModel.screenshotWarningMessageDuration)
			if expiryDate > now() {
				screenshotWasTaken(blockQRUntil: expiryDate)
			} else {
				userSettings.lastScreenshotTime = nil
			}
		}

		clockDeviationObserverToken = Services.clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			self?.validityTimer?.fire()
		}

		updateQRVisibility()
	}

	deinit {
		clockDeviationObserverToken.map(Services.clockDeviationManager.removeDeviationChangeObserver)
	}

	func updateQRVisibility() {
		if let screenshotBlockTimeRemaining = screenIsBlockedForScreenshotWithSecondsRemaining {
			let mins = screenshotBlockTimeRemaining / 60 % 60
			let secs = screenshotBlockTimeRemaining % 60
			let zeroPaddedSeconds = String(format: "%02d", secs)

			let message = L.holderShowqrScreenshotwarningMessage("\(mins):\(zeroPaddedSeconds)")

			// Attempt to make a nicer voiceover string:
			let voiceoverTimeRemaining: String

			let durationFormatter = DateComponentsFormatter()
			durationFormatter.unitsStyle = . full
			durationFormatter.maximumUnitCount = 2
			durationFormatter.allowedUnits = [.minute, .second]

			// e.g. "in ten seconds"
			let relativeString = durationFormatter.string(from: Date(), to: Date().addingTimeInterval(TimeInterval(screenshotBlockTimeRemaining)))
			voiceoverTimeRemaining = relativeString.map { L.holderShowqrScreenshotwarningMessage($0) } ?? message

			self.visibilityState = .screenshotBlocking(timeRemainingText: message, voiceoverTimeRemainingText: voiceoverTimeRemaining)

		} else if screenIsBeingCaptured {
			self.visibilityState = .hiddenForScreenCapture
		} else if let currentQRImage = self.currentQRImage {
			self.visibilityState = .visible(qrImage: currentQRImage)
		} else {
			self.visibilityState = .loading
		}
	}

	private func screenshotWasTaken(blockQRUntil: Date) {
		// Cleanup the old timer
		screenshotWarningTimer?.invalidate()
		screenshotWarningTimer = nil

		screenshotWarningTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
			guard let self = self else { return }

			let timeRemaining = blockQRUntil.timeIntervalSince(self.now())

			if timeRemaining <= 1 {
				timer.invalidate()
				self.screenIsBlockedForScreenshotWithSecondsRemaining = nil
			} else {
				self.screenIsBlockedForScreenshotWithSecondsRemaining = Int(timeRemaining)
			}
		}
		screenshotWarningTimer?.fire() // don't wait 1s
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = self.greenCard.getActiveCredential(),
			  let data = credential.data,
			  let expirationTime = credential.expirationTime, expirationTime > Date() else {
			setQRNotValid()
			return
		}

		if greenCard.type == GreenCardType.domestic.rawValue {
			DispatchQueue.global(qos: .userInitiated).async {
				if let message = self.cryptoManager?.generateQRmessage(data),
				   let image = message.generateQRCode(correctionLevel: ShowQRItemViewModel.domesticCorrectionLevel) {
					DispatchQueue.main.async {
						self.setQRValid(image: image)
					}
				} else {
					DispatchQueue.main.async {
						self.setQRNotValid()
					}
				}
			}
		} else {
			DispatchQueue.global(qos: .userInitiated).async {
				// International
				if let image = data.generateQRCode(correctionLevel: ShowQRItemViewModel.internationalCorrectionLevel) {
					DispatchQueue.main.async {
						self.setQRValid(image: image)
					}
				}
			}
		}
	}

	func didTapThirdPartyAppButton() {
		coordinator?.userWishesToLaunchThirdPartyTicketApp()
	}

	func showMoreInformation() {

		guard let credential = greenCard.getActiveCredential(), let data = credential.data else { return }

		if greenCard.type == GreenCardType.domestic.rawValue {
			if let domesticCredentialAttributes = cryptoManager?.readDomesticCredentials(data) {
				let identity = domesticCredentialAttributes
					.mapIdentity(months: String.shortMonths)
					.map({ $0.isEmpty ? "_" : $0 })
					.joined(separator: " ")

				coordinator?.presentInformationPage(
					title: L.holderShowqrDomesticAboutTitle(),
					body: L.holderShowqrDomesticAboutMessage(identity),
					hideBodyForScreenCapture: true,
					openURLsInApp: true
				)
			}
		} else if greenCard.type == GreenCardType.eu.rawValue {
			if let euCredentialAttributes = cryptoManager?.readEuCredentials(data) {

				logVerbose("euCredentialAttributes: \(euCredentialAttributes)")

				if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
					showVaccinationDetails(euCredentialAttributes: euCredentialAttributes, vaccination: vaccination)
				} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
					showTestDetails(euCredentialAttributes: euCredentialAttributes, test: test)
				} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
					showRecoveryDetails(euCredentialAttributes: euCredentialAttributes, recovery: recovery)
				}
			}
		}
	}

	private func showVaccinationDetails(euCredentialAttributes: EuCredentialAttributes, vaccination: EuCredentialAttributes.Vaccination) {

		var dosage: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = "\(doseNumber) / \(totalDose)"
		}

		let vaccineType = remoteConfigManager?.getConfiguration().getTypeMapping(
			vaccination.vaccineOrProphylaxis) ?? vaccination.vaccineOrProphylaxis
		let vaccineBrand = remoteConfigManager?.getConfiguration().getBrandMapping(
			vaccination.medicalProduct) ?? vaccination.medicalProduct
		let vaccineManufacturer = remoteConfigManager?.getConfiguration().getVaccinationManufacturerMapping(
			vaccination.marketingAuthorizationHolder) ?? vaccination.marketingAuthorizationHolder
		
		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)

		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(printDateFormatter.string) ?? vaccination.dateOfVaccination
		
		let issuer = getDisplayIssuer(vaccination.issuer)
		let country = getDisplayCountry(vaccination.country)
		
		let details: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsVaccination.name, value: name),
			DCCQRDetails(field: DCCQRDetailsVaccination.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsVaccination.pathogen, value: L.holderShowqrEuAboutVaccinationPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineBrand, value: vaccineBrand),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineType, value: vaccineType),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer),
			DCCQRDetails(field: DCCQRDetailsVaccination.dosage, value: dosage),
			DCCQRDetails(field: DCCQRDetailsVaccination.date, value: formattedVaccinationDate),
			DCCQRDetails(field: DCCQRDetailsVaccination.country, value: country),
			DCCQRDetails(field: DCCQRDetailsVaccination.issuer, value: issuer),
			DCCQRDetails(field: DCCQRDetailsVaccination.uniqueIdentifer, value: vaccination.certificateIdentifier)
		]
		
		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutVaccinationDescription(),
			details: details,
			dateInformation: L.holderShowqrEuAboutVaccinationDateinformation()
		)
	}

	private func showTestDetails(euCredentialAttributes: EuCredentialAttributes, test: EuCredentialAttributes.TestEntry) {

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(printDateTimeFormatter.string) ?? test.sampleDate

		let testType = remoteConfigManager?.getConfiguration().getTestTypeMapping(
			test.typeOfTest) ?? test.typeOfTest

		let manufacturer = remoteConfigManager?.getConfiguration().getTestManufacturerMapping(
			test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		var testResult = test.testResult
		if test.testResult == "260415000" {
			testResult = L.holderShowqrEuAboutTestNegative()
		}
		if test.testResult == "260373001" {
			testResult = L.holderShowqrEuAboutTestPostive()
		}
		
		let issuer = getDisplayIssuer(test.issuer)
		let country = getDisplayCountry(test.country)
		let facility = getDisplayFacility(test.testCenter)
		
		let details: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsTest.name, value: name),
			DCCQRDetails(field: DCCQRDetailsTest.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: L.holderShowqrEuAboutTestPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsTest.testType, value: testType),
			DCCQRDetails(field: DCCQRDetailsTest.testName, value: test.name),
			DCCQRDetails(field: DCCQRDetailsTest.date, value: formattedTestDate),
			DCCQRDetails(field: DCCQRDetailsTest.result, value: testResult),
			DCCQRDetails(field: DCCQRDetailsTest.facility, value: facility),
			DCCQRDetails(field: DCCQRDetailsTest.manufacturer, value: manufacturer),
			DCCQRDetails(field: DCCQRDetailsTest.country, value: country),
			DCCQRDetails(field: DCCQRDetailsTest.issuer, value: issuer),
			DCCQRDetails(field: DCCQRDetailsTest.uniqueIdentifer, value: test.certificateIdentifier)
		]
		
		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutTestDescription(),
			details: details,
			dateInformation: L.holderShowqrEuAboutTestDateinformation()
		)
	}

	private func showRecoveryDetails(euCredentialAttributes: EuCredentialAttributes, recovery: EuCredentialAttributes.RecoveryEntry) {

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)

		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(printDateFormatter.string) ?? recovery.firstPositiveTestDate
		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
			.map(printDateFormatter.string) ?? recovery.validFrom
		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
			.map(printDateFormatter.string) ?? recovery.expiresAt
		
		let country = getDisplayCountry(recovery.country)
		let issuer = getDisplayIssuer(recovery.issuer)

		let details: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsRecovery.name, value: name),
			DCCQRDetails(field: DCCQRDetailsRecovery.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.pathogen, value: L.holderShowqrEuAboutRecoveryPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsRecovery.date, value: formattedFirstPostiveDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.country, value: country),
			DCCQRDetails(field: DCCQRDetailsRecovery.issuer, value: issuer),
			DCCQRDetails(field: DCCQRDetailsRecovery.validFrom, value: formattedValidFromDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.validUntil, value: formattedValidUntilDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.uniqueIdentifer, value: recovery.certificateIdentifier)
		]
		
		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutRecoveryDescription(),
			details: details,
			dateInformation: L.holderShowqrEuAboutRecoveryDateinformation()
		)
	}

	private func setQRValid(image: UIImage) {

		logDebug("Credential is valid")
		currentQRImage = image
		startValidityTimer()
	}

	private func setQRNotValid() {

		logWarning("Credential is not valid")
		currentQRImage = nil
		stopValidityTimer()
		coordinator?.navigateBackToStart()
	}

	/// Adjust the brightness
	/// - Parameter reset: True if we reset to previous value
	func setBrightness(reset: Bool = false) {

		let currentBrightness = UIScreen.main.brightness
		if currentBrightness < 1 {
			previousBrightness = currentBrightness
		}

		UIScreen.main.brightness = reset ? previousBrightness ?? 1 : 1
	}

	/// Start the validity timer, check every 90 seconds.
	private func startValidityTimer() {

		guard validityTimer == nil else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(remoteConfigManager?.getConfiguration().domesticQRRefreshSeconds ?? 60),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	func stopValidityTimer() {
		validityTimer?.invalidate()
		validityTimer = nil
	}
	
	private func getDisplayIssuer(_ issuer: String) -> String {
		guard issuer == "Ministry of Health Welfare and Sport" else {
			return issuer
		}
		return L.holderVaccinationAboutIssuer()
	}
	
	private func getDisplayCountry(_ country: String) -> String {
		guard ["NL", "NLD"].contains(country) else {
			return country
		}
		return L.holderVaccinationAboutCountry()
	}
	
	private func getDisplayFacility(_ facility: String) -> String {
		guard facility == "Facility approved by the State of The Netherlands" else {
			return facility
		}
		return L.holderDccListFacility()
	}
}

private extension EuCredentialAttributes {
	
	func dateOfBirth(_ dateFormatter: DateFormatter) -> String {
		return Formatter
			.getDateFrom(dateString8601: digitalCovidCertificate.dateOfBirth)
			.map(dateFormatter.string)
			?? digitalCovidCertificate.dateOfBirth
	}
}
