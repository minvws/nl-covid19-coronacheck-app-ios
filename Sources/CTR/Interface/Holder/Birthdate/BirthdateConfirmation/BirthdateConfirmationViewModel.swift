/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BirthdateConfirmationViewModel: Logging {

	var loggingCategory: String = "BirthdateConfirmationViewModel"

	/// Coordination Delegate
	weak var coordinator: (BirthdateCoordinatorDelegate & Dismissable)?

	/// The proof manager
	weak var proofManager: ProofManaging?

	var birthdate: Date

	/// The message on the page
	@Bindable private(set) var showDialog: Bool = false

	/// Is the primary button enabled?
	@Bindable private(set) var isButtonEnabled: Bool = false

	/// The message on the page
	@Bindable private(set) var message: NSAttributedString?

	/// The confirm message on the page
	@Bindable private(set) var confirm: String?

	/// DescriptionInitializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - date:the proposed birthdate
	init(
		coordinator: (BirthdateCoordinatorDelegate & Dismissable),
		proofManager: ProofManaging,
		date: Date
	) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.birthdate = date

		let printDate = printDateFormatter.string(from: date)
		message = .makeFromHtml(
			text: String(format: .holderBirthdayConfirmationText, printDate),
			font: Theme.fonts.body,
			textColor: Theme.colors.dark
		)
		confirm = String(format: .holderBirthdayConfirmationConfirm, printDate)
	}

	/// User tapped on the dismiss button
	func dismiss() {

		coordinator?.dismiss()
	}

	/// User tapped on the primary button
	func primaryButtonTapped() {

		showDialog = true
	}

	/// User tapped on the secondary button
	func secondaryButtonTapped() {

		coordinator?.navigateBackToBirthdayEntry()
	}

	/// User tapped on the confirm button
	func confirmButtonTapped() {

		logInfo("User confirmed his birthdate")
		// hide dialog
		showDialog = false
		// Store birthday
		proofManager?.setBirthDate(birthdate)
		// Confirm the birth date set
		coordinator?.birthdateConfirmed()
	}

	/// Formatter to print date
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "dd MMMM yyyy"
		return dateFormatter
	}()
}
