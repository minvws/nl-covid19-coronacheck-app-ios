/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The different kind of cards
enum CardIdentifier {

	/// Make an appointment to get tested
	case appointment

	/// Create a QR code
	case create
}

/// The card information
struct CardInfo {

	/// The identifier of the card
	let identifier: CardIdentifier

	/// The title of the card
	let title: String

	/// The message of the card
	let message: String

	/// The title on the action button of the card
	let actionTitle: String

	/// The optional background image
	let image: UIImage?
}

class HolderDashboardViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "HolderDashboardViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The configuration
	weak var configuration: ConfigurationGeneralProtocol?

	/// The previous brightness
	var previousBrightness: CGFloat?

	/// A timer to keep sending pings
	var validityTimer: Timer?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The introduction message of the scene
	@Bindable private(set) var message: String

	/// The title of the QR card
	@Bindable private(set) var qrTitle: String

	/// The message below the QR card
	@Bindable private(set) var qrSubTitle: String?

	/// The message on the expired card
	@Bindable private(set) var expiredTitle: String?

	/// The encrypted test proof
	@Bindable private(set) var qrMessage: String?

	/// Show a valid QR Message
	@Bindable private(set) var showValidQR: Bool

	/// Show an expired QR Message
	@Bindable private(set) var showExpiredQR: Bool

	/// The appointment Card information
	@Bindable private(set) var appointmentCard: CardInfo

	/// The create QR Card information
	@Bindable private(set) var createCard: CardInfo

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	///   - configuration: the configuration
	init(
		coordinator: HolderCoordinatorDelegate,
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration
		self.title = .holderDashboardTitle
		self.message = .holderDashboardIntro
		self.qrTitle = .holderDashboardQRTitle
		self.expiredTitle = .holderDashboardQRExpired

		// Start by showing nothing
		self.showValidQR = false
		self.showExpiredQR = false

		self.appointmentCard = CardInfo(
			identifier: .appointment,
			title: .holderDashboardAppointmentTitle,
			message: .holderDashboardAppointmentMessage,
			actionTitle: .holderDashboardAppointmentAction,
			image: .appointment
		)
		self.createCard = CardInfo(
			identifier: .create,
			title: .holderDashboardCreateTitle,
			message: .holderDashboardCreateMessage,
			actionTitle: .holderDashboardCreatetAction,
			image: .create
		)
	}

	/// The user tapped on one of the cards
	/// - Parameter identifier: the identifier of the card
	func cardClicked(_ identifier: CardIdentifier) {

		if identifier == CardIdentifier.appointment {
			coordinator?.navigateToAppointment()
		} else if identifier == CardIdentifier.create {
			coordinator?.navigateToChooseProvider()
		}
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		if let wrapper = proofManager?.getTestWrapper(),
		   let dateString = wrapper.result?.sampleDate,
		   let date = parseDateFormatter.date(from: dateString) {

			var comp = DateComponents()
			comp.second = Configuration().getTestResultTTL()
			if let validUntilDate = Calendar.current.date(byAdding: comp, to: date) {
				let printDate = printDateFormatter.string(from: validUntilDate)

				if validUntilDate > Date() {
					logDebug("Proof is valid until \(printDate)")
					showQRMessageIsValid(printDate)
					startValidityTimer()
					setBrightness()
				} else {
					// No longer valid
					logDebug("Proof is no longer valid \(printDate)")
					showQRMessageIsExpired()
					validityTimer?.invalidate()
					validityTimer = nil
					setBrightness(reset: true)
				}
			}
		} else {
			qrMessage = nil
			showValidQR = false
			showExpiredQR = false
			setBrightness(reset: true)
		}
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

	/// Show the QR message is valid
	/// - Parameter printDate: valid until time
	func showQRMessageIsValid(_ printDate: String) {

		if let message = self.cryptoManager?.generateQRmessage() {
			qrMessage = message
			qrSubTitle = String(format: .holderDashboardQRMessage, printDate)
			showValidQR = true
			showExpiredQR = false
		}
	}

	/// Show the QR Message is expired
	func showQRMessageIsExpired() {

		showValidQR = false
		showExpiredQR = true
	}

	/// Start the validity timer, check every 10 seconds.
	func startValidityTimer() {

		guard validityTimer == nil else {
			return
		}

		guard let configuration = configuration else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getQRTTL() - 30),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	/// Formatter to parse
	private lazy var parseDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {
		
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "d MMMM HH:mm"
		return dateFormatter
	}()
}
