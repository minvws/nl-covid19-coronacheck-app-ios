/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum CardIdentifier {
	case appointment
	case create
}

struct CardInfo {

	let identifier: CardIdentifier
	let title: String
	let message: String
	let actionTitle: String
	let image: UIImage?
}

class HolderDashboardViewModel: Logging {

	var loggingCategory: String = "HolderDashboardViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?
	weak var cryptoManager: CryptoManagerProtocol?

	/// The proof manager
	weak var proofManager: ProofManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var qrTitle: String
	@Bindable private(set) var qrSubTitle: String?
	@Bindable private(set) var qrMessage: String?
	@Bindable private(set) var appointmentCard: CardInfo
	@Bindable private(set) var createCard: CardInfo

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate

	init(coordinator: HolderCoordinatorDelegate, cryptoManager: CryptoManagerProtocol, proofManager: ProofManaging) {

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

	func cardClicked(_ identifier: CardIdentifier) {

		if identifier == CardIdentifier.appointment {
			coordinator?.navigateToAppointment()
		} else if identifier == CardIdentifier.create {
			coordinator?.navigateToChooseProvider()
		}
	}

	func checkQRMessage() {

		generateQRMessage()
	}

	private func generateQRMessage() {

		if let message = self.cryptoManager?.generateQRmessage() {
			self.qrMessage = message

			// Date
			if let wrapper = proofManager?.getTestWrapper(),
			   let dateString = wrapper.result?.sampleDate,
			   let date = parseDateFormatter.date(from: dateString) {

				var comp = DateComponents()
				comp.second = Configuration().getTestResultTTL()
				if let extendedDate = Calendar.current.date(byAdding: comp, to: date) {
					let printDate = printDateFormatter.string(from: extendedDate)
					qrSubTitle = String(format: .holderDashboardQRMessage, printDate)
					self.logDebug("Valid until \(printDate)")
				}
			}
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
