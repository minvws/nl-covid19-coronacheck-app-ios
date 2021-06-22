/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRViewModel: PreventableScreenCapture, Logging {

	static let domesticCorrectionLevel = "M"
	static let internationalCorrectionLevel = "Q"

	var loggingCategory: String = "ShowQRViewModel"

	weak private var coordinator: HolderCoordinatorDelegate?
	weak private var cryptoManager: CryptoManaging?
	weak private var remoteConfigManager: RemoteConfigManaging?
	weak private var configuration: ConfigurationGeneralProtocol?

	var previousBrightness: CGFloat?

	weak var validityTimer: Timer?

	private var greenCard: GreenCard

	@Bindable private(set) var title: String?
    
    @Bindable private(set) var qrAccessibility: String?

	@Bindable private(set) var infoButtonAccessibility: String?

	@Bindable private(set) var qrImage: UIImage?

	@Bindable private(set) var showValidQR: Bool

	private lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM yyyy"
		return dateFormatter
	}()

	private lazy var printDateTimeFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - configuration: the configuration
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: HolderCoordinatorDelegate,
		greenCard: GreenCard,
		cryptoManager: CryptoManaging,
		configuration: ConfigurationGeneralProtocol,
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager) {

		self.coordinator = coordinator
		self.greenCard = greenCard
		self.cryptoManager = cryptoManager
		self.configuration = configuration
		self.remoteConfigManager = remoteConfigManager

		// Start by showing nothing
		self.showValidQR = false
		self.qrImage = nil

		if greenCard.type == GreenCardType.domestic.rawValue {
			title = .holderShowQRDomesticTitle
            qrAccessibility = .holderShowQRDomesticQRTitle
			infoButtonAccessibility = .holderShowQRDomesticAboutTitle
		} else if greenCard.type == GreenCardType.eu.rawValue {
			title = .holderShowQREuTitle
            qrAccessibility = .holderShowQRDomesticQRTitle
			infoButtonAccessibility = .holderShowQREuAboutTitle
		}

		super.init()
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
				   let image = message.generateQRCode(correctionLevel: ShowQRViewModel.domesticCorrectionLevel) {
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
				let image = data.generateQRCode(correctionLevel: ShowQRViewModel.internationalCorrectionLevel)
				DispatchQueue.main.async {
					self.setQRValid(image: image)
				}
			}
		}
	}

	func showMoreInformation() {

		guard let credential = greenCard.getActiveCredential(), let data = credential.data else {
			return
		}

		if greenCard.type == GreenCardType.domestic.rawValue {
			if let domesticCredentialAttributes = cryptoManager?.readDomesticCredentials(data) {
				let identity = domesticCredentialAttributes
					.mapIdentity(months: String.shortMonths)
					.map({ $0.isEmpty ? "_" : $0 })
					.joined(separator: " ")

				coordinator?.presentInformationPage(
					title: L.holderShowqrDomesticAboutTitle(),
					body: L.holderShowqrDomesticAboutMessage(identity),
					hideBodyForScreenCapture: true
				)
			}
		} else if greenCard.type == GreenCardType.eu.rawValue {
			if let euCredentialAttributes = cryptoManager?.readEuCredentials(data) {

				logDebug("euCredentialAttributes: \(euCredentialAttributes)")

				if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
					showMoreInformationVaccination(euCredentialAttributes: euCredentialAttributes, vaccination: vaccination)
				} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
					showMoreInformationVaccination(euCredentialAttributes: euCredentialAttributes, test: test)
				} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
					showMoreInformationRecovery(euCredentialAttributes: euCredentialAttributes, recovery: recovery)
				}
			}
		}
	}

	private func showMoreInformationVaccination(
		euCredentialAttributes: EuCredentialAttributes,
		vaccination: EuCredentialAttributes.Vaccination) {

		var dosage: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = String(format: .holderVaccinationAboutOf, "\(doseNumber)", "\(totalDose)")
		}

		let vaccineType = remoteConfigManager?.getConfiguration().getTypeMapping(
			vaccination.vaccineOrProphylaxis) ?? vaccination.vaccineOrProphylaxis
		let vaccineBrand = remoteConfigManager?.getConfiguration().getBrandMapping(
			vaccination.medicalProduct) ?? vaccination.medicalProduct
		let vaccineManufacturer = remoteConfigManager?.getConfiguration().getVaccinationManufacturerMapping(
			vaccination.marketingAuthorizationHolder) ?? vaccination.marketingAuthorizationHolder

		let formattedBirthDate: String = Formatter.getDateFrom(dateString8601: euCredentialAttributes.digitalCovidCertificate.dateOfBirth)
			.map(printDateFormatter.string) ?? euCredentialAttributes.digitalCovidCertificate.dateOfBirth

		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(printDateFormatter.string) ?? vaccination.dateOfVaccination

		let body: String = String(
			format: .holderShowQREuAboutVaccinationMessage,
			"\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)",
			formattedBirthDate,
			vaccineBrand,
			vaccineType,
			vaccineManufacturer,
			dosage ?? " ",
			formattedVaccinationDate,
			vaccination.country,
			vaccination.certificateIdentifier
		)
		coordinator?.presentInformationPage(title: .holderShowQREuAboutTitle, body: body, hideBodyForScreenCapture: true)
	}

	private func showMoreInformationVaccination(
		euCredentialAttributes: EuCredentialAttributes,
		test: EuCredentialAttributes.TestEntry) {

		logDebug("test: \(test)")

		let formattedBirthDate: String = Formatter.getDateFrom(dateString8601: euCredentialAttributes.digitalCovidCertificate.dateOfBirth)
			.map(printDateFormatter.string) ?? euCredentialAttributes.digitalCovidCertificate.dateOfBirth

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(printDateTimeFormatter.string) ?? test.sampleDate

		let testType = remoteConfigManager?.getConfiguration().getTestTypeMapping(
			test.typeOfTest) ?? test.typeOfTest

		let manufacturer = remoteConfigManager?.getConfiguration().getTestManufacturerMapping(
			test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		var testResult = test.testResult
		if test.testResult == "260415000" {
			testResult = .holderShowQREuAboutTestNegative
		}
		if test.testResult == "260373001" {
			testResult = .holderShowQREuAboutTestPositive
		}

		let body: String = String(
			format: .holderShowQREuAboutTestMessage,
			"\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)",
			formattedBirthDate,
			testType,
			test.name ?? "",
			formattedTestDate,
			testResult,
			test.testCenter,
			manufacturer,
			test.country,
			test.certificateIdentifier
		)
		coordinator?.presentInformationPage(title: .holderShowQREuAboutTitle, body: body, hideBodyForScreenCapture: true)
	}

	private func showMoreInformationRecovery(
		euCredentialAttributes: EuCredentialAttributes,
		recovery: EuCredentialAttributes.RecoveryEntry) {

	}

	private func setQRValid(image: UIImage?) {

		logDebug("Credential is valid")
		qrImage = image
		showValidQR = true
		startValidityTimer()
	}

	private func setQRNotValid() {

		logWarning("Credential is not valid")
		qrImage = nil
		showValidQR = false
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

		guard validityTimer == nil, let configuration = configuration else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getQRRefreshPeriod()),
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
}
