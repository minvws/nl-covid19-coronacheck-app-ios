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

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The network manager
	var networkManager: NetworkManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String
	@Bindable private(set) var recentHeader: String
	@Bindable private(set) var tooltip: String
	@Bindable private(set) var showAlert: Bool = false
	@Bindable private(set) var showError: String?
	@Bindable private(set) var listItem: ListResultItem?
	@Bindable private(set) var showProgress: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - cryptoManager: the crypto manager
	///   - networkManager: the network manager
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		cryptoManager: CryptoManaging,
		networkManager: NetworkManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.cryptoManager = cryptoManager
		self.networkManager = networkManager

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

	func buttonClick() {

		if listItem != nil {
			// Works for now with just one result
			//
			createProof()
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
	func createProof() {

		showProgress = true

		networkManager?.getNonce { [weak self] resultwrapper in

			switch resultwrapper {
				case let .success(envelope):

					self?.cryptoManager?.setNonce(envelope.nonce)
					self?.cryptoManager?.setStoken(envelope.stoken)
					self?.fetchTestProof()
				case let .failure(networkError):
					self?.showProgress = false
					self?.showError = "Can't fetch the nonce: \(networkError.localizedDescription)"
					self?.logError("Can't fetch the nonce: \(networkError.localizedDescription)")
			}
		}
	}

	/// Fetch the proof
	func fetchTestProof() {

		if let icm = cryptoManager?.generateCommitmentMessage(),
		   let icmDictionary = icm.convertToDictionary(),
		   let stoken = cryptoManager?.getStoken(),
		   let wrapper = proofManager?.getSignedWrapper() {

			let dictionary: [String: AnyObject] = [
				"test": generateString(object: wrapper) as AnyObject,
				"stoken": stoken as AnyObject,
				"icm": icmDictionary as AnyObject
			]

			networkManager?.fetchTestResultsWithISM(dictionary: dictionary) { [weak self] resultwrapper in

				switch resultwrapper {
					case let .success(data):
						self?.handleTestProofsResponse(data)
					case let .failure(networkError):
						self?.showProgress = false
						self?.showError = "Can't fetch the ISM: \(networkError.localizedDescription)"
						self?.logError("Can't fetch the ISM: \(networkError.localizedDescription)")
				}
			}
		}
	}

	private func handleTestProofsResponse(_ data: Data?) {

		if let unwrapped = data {
			logDebug("ISM Response: \(String(decoding: unwrapped, as: UTF8.self))")
			showProgress = false

			do {
				let ismError = try JSONDecoder().decode(ISMErrorResponse.self, from: unwrapped)
				if ismError.code == 99994 {
					reportAlreadyDone()
				} else {
					showError = "Server error \(ismError.status): \(ismError.code)"
				}
			} catch {
				// not an error
				cryptoManager?.setProofs(data)
				proofManager?.removeTestWrapper()
				if let message = cryptoManager?.generateQRmessage() {
					print("message: \(message)")
				}
				coordinator?.navigateToCreateProof()
			}
		}
	}

	func generateString<T>(object: T) -> String where T: Codable {

		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .utf8) {
			print("CTR: Converted to \(convertedToString)")
			return convertedToString
		}
		return ""
	}
}

struct ISMErrorResponse: Decodable {
	let status: String
	let code: Int
}
