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

	/// The configuration
	var configuration: ConfigurationGeneralProtocol

	/// The proof manager
	weak var proofManager: ProofManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String
	@Bindable private(set) var recentHeader: String
	@Bindable private(set) var tooltip: String
	@Bindable private(set) var showAlert: Bool = false
	@Bindable private(set) var showError: String?
	@Bindable var listItem: ListResultItem?
	@Bindable private(set) var showProgress: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - configuration: the configuration
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.configuration = configuration

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
						investigate(result)
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

	/// Investigate the result
	/// - Parameter testResult: the test result
	private func investigate(_ testResult: TestResult) {

		var valid = false
		let now = Date().timeIntervalSince1970
		let validity = TimeInterval(configuration.getTestResultTTL())
		if let sampleDate = parseDateFormatter.date(from: testResult.sampleDate) {
			let sampleTimeStamp = sampleDate.timeIntervalSince1970
			if (sampleTimeStamp + validity) > now && sampleTimeStamp < now {
				valid = true
				reportTestResult(testResult)
			}
		}

		if !valid {
			reportNoTestResult()
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

	/// Show the scene when the test is already handled
	private func reportAlreadyDone() {

		self.title = .holderTestResultsAlreadyHandledTitle
		self.message = .holderTestResultsAlreadyHandledText
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

	func buttonTapped() {

		if listItem != nil {
			// Works for now with just one result
			createProofStepOne()
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

	// Create the proof
	func createProofStepOne() {

		showProgress = true

		// Step 1: Fetch the nonce and stoken
		proofManager?.fetchNonce(
			oncompletion: { [weak self] in
				self?.createProofStepTwo()
			}, onError: { [weak self] error in
				self?.showProgress = false
				self?.showError = "Can't fetch the nonce: \(error.localizedDescription)"
				self?.logError("Can't fetch the nonce: \(error.localizedDescription)")
			}
		)
	}

	/// Fetch the proof
	func createProofStepTwo() {

		proofManager?.fetchSignedTestResult(
			oncompletion: { [weak self] state in
				self?.showProgress = false
				self?.handleTestProofsResponse(state)
			}, onError: { [weak self] error in
				self?.showProgress = false
				self?.showError = "Can't fetch the signed test result: \(error.localizedDescription)"
			}
		)
	}

	/// Handle the results of step 2
	/// - Parameter state: the signed test result state
	private func handleTestProofsResponse(_ state: SignedTestResultState) {

		switch state {
			case .valid:
				coordinator?.navigateToCreateProof()
			case .alreadySigned:
				reportAlreadyDone()
			case .notNegative, .tooOld, .tooNew:
				reportNoTestResult()
			default:
				showError = "unknown server error"
		}
	}
}
