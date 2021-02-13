/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct ListResultItem {

	let identifier: String
	let date: String
}

class ListResultsViewModel: Logging {

	var loggingCategory: String = "ListResultsViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	weak var proofManager: ProofManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String
	@Bindable private(set) var recentHeader: String
	@Bindable private(set) var tooltip: String
	@Bindable private(set) var showAlert: Bool = false
	@Bindable private(set) var listItem: ListResultItem?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(coordinator: HolderCoordinatorDelegate, proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager

		self.title = .holderTestResultsNoResultsTitle
		self.message = .holderTestResultsNoResultsText
		self.buttonTitle = .holderTestResultsBackToMenuButton
		self.recentHeader = .holderTestResultsRecent
		self.tooltip = .holderTestResultsDisclaimer
		self.listItem = nil
		checkResult()
	}

	/// The te test result
	func checkResult() {
		
		if let wrapper = proofManager?.getTestWrapper() {
			switch wrapper.status {
				case .complete:
					if let result = wrapper.result, result.negativeResult {
						reportTestResult(result)
					} else {
						reportNoTestResult()
					}
				case .pending:
					reportPendingResult()
				default:
					break
			}
		}
	}

	/// Show the screen for pending results
	private func reportPendingResult() {

		title = .holderTestResultsPendingTitle
		message = .holderTestResultsPendingText
		buttonTitle = .holderTestResultsBackToMenuButton
		self.listItem = nil
	}

	/// Show the scene for no negative restults
	private func reportNoTestResult() {

		self.title = .holderTestResultsNoResultsTitle
		self.message = .holderTestResultsNoResultsText
		self.buttonTitle = .holderTestResultsBackToMenuButton
		self.listItem = nil
	}

	/// Show the screen for negative restults
	/// - Parameter result: the negative result
	private func reportTestResult(_ result: TestResult) {

		self.title = .holderTestResultsResultsTitle
		self.message = .holderTestResultsResultsText
		self.buttonTitle = .holderTestResultsResultsButton
		let date = parseDateFormatter.date(from: result.sampleDate)
		let dateString = printDateFormatter.string(from: date!)

		self.listItem = ListResultItem(
			identifier: result.unique,
			date: dateString
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
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()

	func buttonClick() {

		if listItem != nil {
			// Works for now with just one result
			coordinator?.navigateToCreateProof()
		} else {
			doDismiss()
		}
	}

	func dismiss() {

		if listItem != nil {
			showAlert = true
		} else {
			doDismiss()
		}
	}

	func doDismiss() {

		coordinator?.navigateBackToStart()
	}
}
