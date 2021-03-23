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

	/// The cut of the image
	let imageRect: CGRect
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
	var configuration: ConfigurationGeneralProtocol

	/// The proof validator
	var proofValidator: ProofValidatorProtocol

	/// The previous brightness
	var previousBrightness: CGFloat?

	/// A timer to keep refreshing the QR
	var validityTimer: Timer?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The introduction message of the scene
	@Bindable private(set) var message: String

	/// The title of the QR card
	@Bindable private(set) var qrTitle: String

	/// The message below the title
	@Bindable private(set) var qrSubTitle: String?

	/// The message below the QR card
	@Bindable private(set) var qrValidUntilTitle: String?

	/// The message on the expired card
	@Bindable private(set) var expiredTitle: String?

	/// The cl signee test proof
	@Bindable private(set) var qrMessage: Data?

	/// Show a valid QR Message
	@Bindable private(set) var showValidQR: Bool

	/// Show an expired QR Message
	@Bindable private(set) var showExpiredQR: Bool

	/// Hide for screen capture
	@Bindable var hideForCapture: Bool

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
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: HolderCoordinatorDelegate,
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol,
		maxValidity: Int) {

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
		self.hideForCapture = false

		self.appointmentCard = CardInfo(
			identifier: .appointment,
			title: .holderDashboardAppointmentTitle,
			message: .holderDashboardAppointmentMessage,
			actionTitle: .holderDashboardAppointmentAction,
			image: .appointment,
			imageRect: CGRect(x: 0, y: 0, width: 0.77, height: 1)
		)
		self.createCard = CardInfo(
			identifier: .create,
			title: .holderDashboardCreateTitle,
			message: .holderDashboardCreateMessage,
			actionTitle: .holderDashboardCreatetAction,
			image: .create,
			imageRect: CGRect(x: 0, y: 0, width: 0.65, height: 1)
		)

		self.proofValidator = ProofValidator(maxValidity: maxValidity)

		self.addObserver()
	}

	/// The user tapped on one of the cards
	/// - Parameter identifier: the identifier of the card
	func cardTapped(_ identifier: CardIdentifier) {

		if identifier == CardIdentifier.appointment {
			coordinator?.navigateToAppointment()
		} else if identifier == CardIdentifier.create {
			coordinator?.navigateToChooseProvider()
		}
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = cryptoManager?.readCredential() else {
			qrMessage = nil
			showValidQR = false
			showExpiredQR = false
			validityTimer?.invalidate()
			validityTimer = nil
			return
		}

		if let sampleTimeStamp = TimeInterval(credential.sampleTime) {

			switch proofValidator.validate(sampleTimeStamp) {
				case let .valid(validUntilDate):
					let validUntilDateString = printDateFormatter.string(from: validUntilDate)
					logDebug("Proof is valid until \(validUntilDateString)")
					showQRMessageIsValid(validUntilDateString)
					startValidityTimer()

				//				case .expiring:
				//				// Needs refactoring!!!!
				//					let warningTTL = TimeInterval(configuration.getTestResultWarningTTL())
				//				if (sampleTimeStamp + validity - warningTTL) < now {
				//					logDebug("Proof is expiring soon")
				//				}
				//					showQRMessageExpiring(printDate)
				//					break
				case .expired:
					logDebug("Proof is no longer valid")
					showQRMessageIsExpired()
					validityTimer?.invalidate()
					validityTimer = nil
			}
		}
	}

	/// Show the QR message is valid
	/// - Parameter printDate: valid until time
	func showQRMessageIsValid(_ printDate: String) {

		if let message = cryptoManager?.generateQRmessage() {
			qrMessage = message
			qrValidUntilTitle = String(format: .holderDashboardQRMessage, printDate)
			showValidQR = true
			showExpiredQR = false
		}
		if let birthdate = proofManager?.getBirthDate() {
			qrSubTitle = printBirthDateFormatter.string(from: birthdate)
		}
	}

//	/// Show the QR message is valid
//	/// - Parameter printDate: valid until time
//	func showQRMessageExpiring(_ printDate: String) {
//
//		if let message = self.cryptoManager?.generateQRmessage() {
//			qrMessage = message
//			qrSubTitle = String(format: .holderDashboardQRExpiring, printDate)
//			// Todo, calculate the time remaining
//			showValidQR = true
//			showExpiredQR = false
//		}
//	}

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

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getQRTTL() - 10), // 10 second earlier, to prevent last second mismatches.
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	/// User wants to see the large QR
	func navigateToEnlargedQR() {

		coordinator?.navigateToEnlargedQR()
	}

	/// User wants to close the expired QR
	func closeExpiredRQ() {

		cryptoManager?.removeCredential()
		checkQRValidity()
	}

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "CET")
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "E d MMMM HH:mm"
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printBirthDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()
}

// MARK: - capturedDidChangeNotification

extension HolderDashboardViewModel {

	/// Add an observer for the capturedDidChangeNotification
	func addObserver() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIScreen.capturedDidChangeNotification,
			object: nil
		)
	}

	/// Prevent screen capture
	@objc func preventScreenCapture() {

		if UIScreen.main.isCaptured {
			hideForCapture = true
			self.logWarning("Screen capture in progress")
		} else {
			hideForCapture = false
		}
	}
}
