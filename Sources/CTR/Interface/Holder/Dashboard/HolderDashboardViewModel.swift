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

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The introduction message of the scene
	@Bindable private(set) var message: String

	/// The title of the QR card
	@Bindable private(set) var qrTitle: String

	/// The message below the QR card
	@Bindable private(set) var qrSubTitle: String?

	/// The encrypted test proof
	@Bindable private(set) var qrMessage: String?

	/// The appointment Card information
	@Bindable private(set) var appointmentCard: CardInfo

	/// The create QR Card information
	@Bindable private(set) var createCard: CardInfo

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	init(coordinator: HolderCoordinatorDelegate, cryptoManager: CryptoManaging, proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.title = .holderDashboardTitle
		self.message = .holderDashboardIntro
		self.qrTitle = .holderDashboardQRTitle
		self.qrMessage = nil
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
		generateQRMessage()
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

	/// Check the QR Message
	func checkQRMessage() {

		generateQRMessage()
	}

	/// Generate the qr message from proof and crypto
	private func generateQRMessage() {

		if let message = self.cryptoManager?.generateQRmessage() {
			self.qrMessage = message

			// Max Brightness
			UIScreen.main.brightness = 1

			// Calculate valid until
			if let wrapper = proofManager?.getTestWrapper(),
			   let dateString = wrapper.result?.sampleDate,
			   let date = parseDateFormatter.date(from: dateString) {

				var comp = DateComponents()
				comp.second = Configuration().getTestResultTTL()
				if let extendedDate = Calendar.current.date(byAdding: comp, to: date) {
					let printDate = printDateFormatter.string(from: extendedDate)
					qrSubTitle = String(format: .holderDashboardQRMessage, printDate)
					self.logDebug("Proof is valid until \(printDate)")
				}
			}
		} else {
			self.qrMessage = nil
		}
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
