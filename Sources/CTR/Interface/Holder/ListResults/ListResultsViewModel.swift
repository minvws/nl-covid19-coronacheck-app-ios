/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct ListResultItem {

	let identifier: String
	let date: String?
	let holder: String
}

class ListResultsViewModel: Logging {

	var loggingCategory: String = "ListResultsViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	var maxValidity: Int

	/// The proof manager
	weak var proofManager: ProofManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String
	@Bindable private(set) var recentHeader: String
	@Bindable var showAlert: Bool = false
	@Bindable var showError: Bool = false
	@Bindable var errorMessage: String?
	@Bindable var listItem: ListResultItem?
	@Bindable private(set) var shouldShowProgress: Bool = false

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - maxValidity: the maximum validity of a test result
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		maxValidity: Int) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.maxValidity = maxValidity

		self.title = .holderTestResultsNoResultsTitle
		self.message = String(format: .holderTestResultsNoResultsText, String(maxValidity))
		self.buttonTitle = .holderTestResultsBackToMenuButton
		self.recentHeader = .holderTestResultsRecent
		self.listItem = nil
	}
//
//	/// The te test result
//	func checkResult() {
//
//		if let wrapper = proofManager?.getTestWrapper() {
//			switch wrapper.status {
//				case .complete:
//					if let result = wrapper.result, result.negativeResult {
//						reportTestResult(result)
//					} else {
//						reportNoTestResult()
//					}
//				case .pending:
//					reportPendingResult()
//				default:
//					break
//			}
//		} else {
//			reportNoTestResult()
//		}
//	}
//
//	/// Show the screen for pending results
//	internal func reportPendingResult() {
//
//		title = .holderTestResultsPendingTitle
//		message = .holderTestResultsPendingText
//		buttonTitle = .holderTestResultsBackToMenuButton
//		self.listItem = nil
//	}
//
//	/// Show the scene for no negative restults
//	internal func reportNoTestResult() {
//
//		self.title = .holderTestResultsNoResultsTitle
//		self.message = String(format: .holderTestResultsNoResultsText, String(maxValidity))
//		self.buttonTitle = .holderTestResultsBackToMenuButton
//		self.listItem = nil
//	}
//
//	/// Show the scene when the test is already handled
//	internal func reportAlreadyDone() {
//
//		self.title = .holderTestResultsAlreadyHandledTitle
//		self.message = .holderTestResultsAlreadyHandledText
//		self.buttonTitle = .holderTestResultsBackToMenuButton
//		self.listItem = nil
//	}
//
//	/// Show the screen for negative results
//	/// - Parameter result: the negative result
//	internal func reportTestResult(_ result: TestResult) {
//
//		self.title = .holderTestResultsResultsTitle
//		self.message = .holderTestResultsResultsText
//		self.buttonTitle = .holderTestResultsResultsButton
//
//		let printDate: String? = Formatter.getDateFrom(dateString8601: result.sampleDate)
//			.map {
//				printDateFormatter.string(from: $0).capitalizingFirstLetter()
//			}
//		self.listItem = ListResultItem(
//			identifier: result.unique,
//			date: printDate,
//			holder: String(format: .holderTestResultsIdentity, getDisplayIdentity(result.holder))
//		)
//	}
//
//	/// Formatter to print
//	private lazy var printDateFormatter: DateFormatter = {
//
//		let dateFormatter = DateFormatter()
//		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
//		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
//		return dateFormatter
//	}()
//
//	func buttonTapped() {
//
//		if listItem != nil {
//			// Works for now with just one result
//			createProofStepOne()
//		} else {
//			doDismiss()
//		}
//	}
//
//	func dismiss() {
//
//		if listItem != nil {
//			showAlert = true
//		} else {
//			doDismiss()
//		}
//	}
//
//	func doDismiss() {
//
//		coordinator?.navigateBackToStart()
//	}
//
//	func disclaimerTapped() {
//
//		coordinator?.navigateToAboutTestResult()
//	}
//
//	// Create the proof
//	func createProofStepOne() {
//
//		progressIndicationCounter.increment()
//
//		// Step 1: Fetch the public keys
//		proofManager?.fetchIssuerPublicKeys(
//			onCompletion: { [weak self] in
//				self?.progressIndicationCounter.decrement()
//				self?.createProofStepTwo()
//			}, onError: { [weak self] error in
//				self?.progressIndicationCounter.decrement()
//				self?.showError = true
//				self?.logError("Can't fetch the keys: \(error.localizedDescription)")
//			}
//		)
//	}
//
//	// Create the proof
//	func createProofStepTwo() {
//
//		progressIndicationCounter.increment()
//
//		// Step 2: Fetch the nonce and stoken
//		proofManager?.fetchNonce(
//			onCompletion: { [weak self] in
//				self?.progressIndicationCounter.decrement()
//				self?.createProofStepThree()
//			}, onError: { [weak self] error in
//				self?.progressIndicationCounter.decrement()
//				self?.showError = true
//				self?.logError("Can't fetch the nonce: \(error.localizedDescription)")
//			}
//		)
//	}
//
//	/// Fetch the proof
//	func createProofStepThree() {
//
//		progressIndicationCounter.increment()
//
//		// Step 3: Fetch the signed result
//		proofManager?.fetchSignedTestResult(
//			onCompletion: { [weak self] state in
//				self?.progressIndicationCounter.decrement()
//				self?.handleTestProofsResponse(state)
//			}, onError: { [weak self] error in
//				self?.progressIndicationCounter.decrement()
//				self?.showError = true
//				self?.logError("Can't fetch the ism: \(error.localizedDescription)")
//			}
//		)
//	}
//
//	/// Handle the results of step 2
//	/// - Parameter state: the signed test result state
//	private func handleTestProofsResponse(_ state: SignedTestResultState) {
//
//		switch state {
//			case .valid:
//
//				coordinator?.navigateBackToStart()
//			case .alreadySigned:
//
//				reportAlreadyDone()
//			case .notNegative:
//
//				reportNoTestResult()
//
//			case let .tooOld(signedTestResultErrorResponse):
//				errorMessage = String(format: .technicalErrorCustom, "\(signedTestResultErrorResponse.code)")
//
//			case let .tooNew(signedTestResultErrorResponse):
//				errorMessage = String(format: .technicalErrorCustom, "\(signedTestResultErrorResponse.code)")
//
//			case let .unknown(signedTestResultErrorResponse):
//				errorMessage = String(format: .technicalErrorCustom, "\(signedTestResultErrorResponse.code) \(signedTestResultErrorResponse.status)")
//		}
//	}
//
//	/// Get a display version of the holder identity
//	/// - Parameter holder: the holder identity
//	/// - Returns: the display version
//	func getDisplayIdentity(_ holder: TestHolderIdentity?) -> String {
//
//		guard let holder = holder else {
//			return ""
//		}
//
//		let parts = holder.mapIdentity(months: String.shortMonths)
//		var output = ""
//		for part in parts {
//			output.append(part)
//			output.append(" ")
//		}
//		return output.trimmingCharacters(in: .whitespaces)
//	}
}
