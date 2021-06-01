/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRViewModel: PreventableScreenCapture, Logging {

	var loggingCategory: String = "ShowQRViewModel"

	weak private var coordinator: HolderCoordinatorDelegate?
	weak private var cryptoManager: CryptoManaging?
	weak private var remoteConfigManager: RemoteConfigManaging?
	weak private var configuration: ConfigurationGeneralProtocol?

	private var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	var previousBrightness: CGFloat?

	weak var validityTimer: Timer?

	private var greenCard: GreenCard

	@Bindable private(set) var title: String?

	@Bindable private(set) var infoButtonAccessibility: String?

	/// The cl signed test proof
	@Bindable private(set) var qrMessage: Data?

	/// Show a valid QR Message
	@Bindable private(set) var showValidQR: Bool

	/// Show a warning for a screenshot
	@Bindable private(set) var showScreenshotWarning: Bool = false

	private lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateStyle = .medium
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

		if greenCard.type == GreenCardType.domestic.rawValue {
			title = .holderShowQRDomesticTitle
			infoButtonAccessibility = .holderShowQRDomesticAboutTitle
		} else if greenCard.type == GreenCardType.eu.rawValue {
			title = .holderShowQREuTitle
			infoButtonAccessibility = .holderShowQREuAboutTitle
		}

		super.init()
		addObserver()
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = greenCard.getActiveCredential(),
			  let data = credential.data,
			  let expirationTime = credential.expirationTime, expirationTime > Date() else {
			setQRNotValid()
			return
		}

		if greenCard.type == GreenCardType.domestic.rawValue {
			if let message = self.cryptoManager?.generateQRmessage(data) {
				setQRValid(message)
			} else {
				setQRNotValid()
				return
			}
		} else {
			setQRValid(data)
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
				let body: String = String(format: .holderShowQRDomesticAboutMessage, identity)
				coordinator?.presentInformationPage(title: .holderShowQRDomesticAboutTitle, body: body)
			}
		} else if greenCard.type == GreenCardType.eu.rawValue {
			if let euCredentialAttributes = cryptoManager?.readEuCredentials(data) {

				logDebug("euCredentialAttributes: \(euCredentialAttributes)")

				if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
					showMoreInformationVaccination(
						euCredentialAttributes: euCredentialAttributes,
						vaccination: vaccination
					)
				}
			}
		}
	}

	private func showMoreInformationVaccination(
		euCredentialAttributes: EuCredentialAttributes,
		vaccination: EuCredentialAttributes.Vaccination) {

		var dosage = ""
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = String(format: .holderVaccinationAboutOf, "\(doseNumber)", "\(totalDose)")
		}

		let vaccineType = remoteConfigManager?.getConfiguration().getTypeMapping(
			vaccination.vaccineOrProphylaxis) ?? ""
		let vaccineBrand = remoteConfigManager?.getConfiguration().getBrandMapping(
			vaccination.medicalProduct) ?? ""
		let vaccineManufacturer = remoteConfigManager?.getConfiguration().getManufacturerMapping(
			vaccination.marketingAuthorizationHolder) ?? ""

		let body: String = String(
			format: .holderShowQREuAboutVaccinationMessage,
			"\(euCredentialAttributes.digitalCovidCertificate.name.givenName)  \(euCredentialAttributes.digitalCovidCertificate.name.familyName)",
			euCredentialAttributes.digitalCovidCertificate.dateOfBirth,
			printDateFormatter.string(from: Date(timeIntervalSince1970: euCredentialAttributes.issuedAt)),
			printDateFormatter.string(from: Date(timeIntervalSince1970: euCredentialAttributes.expirationTime)),
			vaccineBrand,
			vaccineType,
			vaccineManufacturer,
			dosage,
			vaccination.dateOfVaccination,
			vaccination.country,
			vaccination.issuer,
			vaccination.certificateIdentifier
		)
		// Change body on test / vaccination / recovery.

		coordinator?.presentInformationPage(title: .holderShowQREuAboutTitle, body: body)

	}

	private func setQRValid(_ data: Data) {

		logDebug("Credential is valid")
		qrMessage = data
		showValidQR = true
		startValidityTimer()
	}

	private func setQRNotValid() {

		logDebug("Credential is not valid")
		qrMessage = nil
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

	/// Add an observer for the userDidTakeScreenshotNotification notification
	private func addObserver() {

		notificationCenter.addObserver(
			self,
			selector: #selector(handleScreenShot),
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil
		)
	}

	/// handle a screen shot taken
	@objc internal func handleScreenShot() {

		showScreenshotWarning = true
	}
}
