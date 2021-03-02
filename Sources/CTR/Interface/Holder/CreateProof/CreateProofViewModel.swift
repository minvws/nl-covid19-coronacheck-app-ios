/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class CreateProofViewModel: Logging {

	var loggingCategory: String = "CreateProofViewiewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The title on the page
	@Bindable private(set) var title: String

	/// The message on the page
	@Bindable private(set) var message: String?

	/// The title of the button
	@Bindable private(set) var buttonTitle: String = .next

	/// DescriptionInitializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	init(
		coordinator: HolderCoordinatorDelegate,
		cryptoManager: CryptoManaging
	) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager

		self.title = .holderCreateProofTitle
		self.buttonTitle = .holderCreateProofAction

		createMessage()
	}

	/// Create the message
	func createMessage() {

		if let credential = cryptoManager?.readCredential(),
		   let sampleTimeStamp = TimeInterval(credential.sampleTime) {
			let date = Date(timeIntervalSince1970: sampleTimeStamp)

			let printTime = printTimeFormatter.string(from: date)
			let printDate = printDateFormatter.string(from: date)
			let printOutput = "\(printDate) " + String.holderCreateProofAt + " \(printTime)"
			message = String(format: .holderCreateProofText, printOutput)
		} else {
			self.logError("Can't unwrap credential")
		}
	}

	/// User tapped on the next button
	func buttonTapped() {

		coordinator?.navigateBackToStart()
	}

	/// Formatter to print date
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "d MMMM"
		return dateFormatter
	}()

	/// Formatter to print time
	private lazy var printTimeFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter
	}()
}
