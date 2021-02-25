/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryViewModel: Logging {

	var loggingCategory: String = "TokenEntryViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The request token
	var requestToken: RequestToken?

	/// The verification code
	var verificationCode: String?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var tokenTitle: String
	@Bindable private(set) var token: String?
	@Bindable private(set) var tokenPlaceholder: String
	@Bindable private(set) var verificationCodeTitle: String
	@Bindable private(set) var verificationCodePlaceholder: String
	@Bindable private(set) var showProgress: Bool = false
	@Bindable private(set) var showVerification: Bool = false
	@Bindable private(set) var errorMessage: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - scannedToken: the scanned token
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		scannedToken: RequestToken?) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.requestToken = scannedToken

		title = .holderTokenEntryTitle
		message = .holderTokenEntryText
		tokenTitle = .holderTokenEntryTokenTitle
		tokenPlaceholder = .holderTokenEntryTokenPlaceholder
		verificationCodeTitle = .holderTokenEntryVerificationTitle
		verificationCodePlaceholder = .holderTokenEntryVerificationPlaceholder

		if let unwrappedToken = requestToken {
			fetchResult(unwrappedToken)
			self.token = "\(unwrappedToken.providerIdentifier)-\(unwrappedToken.token)"
		} else {
			self.token = nil
		}
	}

	func checkToken(_ text: String?) {

		if let input = text, !input.isEmpty {
			if let requestToken = createRequestToken(input.uppercased()) {
				self.requestToken = requestToken
				fetchResult(requestToken)
				errorMessage = nil
			} else {
				errorMessage = .holderTokenEntryErrorInvalidCode
			}
		}
	}

	func checkVerification(_ text: String?) {

		if let input = text, !input.isEmpty {
			verificationCode = input.uppercased()
			errorMessage = nil
			if let token = requestToken {
				fetchResult(token)
			}
		}
	}

	/// Fetch a test result
	/// - Parameter requestToken: the request token
	private func fetchResult(_ requestToken: RequestToken) {

		guard let provider = proofManager?.getTestProvider(requestToken) else {
			errorMessage = .holderTokenEntryErrorInvalidProvider
			return
		}

		showProgress = true
		proofManager?.fetchTestResult(
			requestToken,
			code: verificationCode,
			provider: provider) {  [weak self] response in

			self?.showProgress = false
			self?.errorMessage = nil

			switch response {
				case let .success(wrapper):
					switch wrapper.status {
						case .complete, .pending:
							self?.coordinator?.navigateToListResults()
						case .verificationRequired:
							self?.showVerification = true
						case .invalid:
							self?.errorMessage = .holderTokenEntryErrorInvalidCode
						default:
							self?.logDebug("Unhandled test result status: \(wrapper.status)")
							self?.errorMessage = "Unhandled: \(wrapper.status)"
					}
				case let .failure(error):

					if let castedError = error as? ProofError, castedError == .invalidUrl {
						self?.errorMessage = .holderTokenEntryErrorInvalidProvider
					} else {
					// For now, display the network error.
					self?.errorMessage = error.localizedDescription
					}
			}
		}
	}

	/// Create a request token from a string
	/// - Parameter token: the input string
	/// - Returns: the request token
	func createRequestToken(_ input: String) -> RequestToken? {

		let parts = input.split(separator: "-")
		if parts.count >= 2 {
			if parts[0].count == 3 {
				let identifierPart = String(parts[0])
				let tokenPart = String(parts[1])
				return RequestToken(
					token: tokenPart,
					protocolVersion: "1.0",
					providerIdentifier: identifierPart
				)
			}
		}
		return nil
	}
}
