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

	/// The current highest known protocol version
	/// 1.0: Checksum
	/// 2.0: Initials + Birthday/month
	let highestKnownProtocolVersion = "2.0"

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var tokenTitle: String
	@Bindable private(set) var token: String?
	@Bindable private(set) var tokenPlaceholder: String
	@Bindable private(set) var verificationCodeTitle: String
	@Bindable private(set) var verificationCodePlaceholder: String
	@Bindable private(set) var showProgress: Bool = false
	@Bindable private(set) var showVerification: Bool = false

	/// An error message
	@Bindable private(set) var errorMessage: String?

	/// Show internet error
	@Bindable private(set) var showError: Bool = false

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
			fetchProviders(unwrappedToken)
			self.token = "\(unwrappedToken.providerIdentifier)-\(unwrappedToken.token)"
		} else {
			self.token = nil
		}
	}

	/// Check the token
	/// - Parameter text: the request token
	func checkToken(_ text: String?) {

		if let input = text, !input.isEmpty {
			if let requestToken = createRequestToken(input.uppercased()) {
				self.requestToken = requestToken
				fetchProviders(requestToken)
				errorMessage = nil
			} else {
				errorMessage = .holderTokenEntryErrorInvalidCode
			}
		}
	}

	/// Check the verification
	/// - Parameter text: the verification text
	func checkVerification(_ text: String?) {

		if let input = text, !input.isEmpty {
			verificationCode = input.uppercased()
			errorMessage = nil
			if let token = requestToken {
				fetchProviders(token)
			}
		}
	}

	/// Fetch the providers
	/// - Parameter requestToken: the request token
	func fetchProviders(_ requestToken: RequestToken) {

		guard proofManager?.getTestProvider(requestToken) == nil else {
			// only fetch providers if we do not have it.
			fetchResult(requestToken)
			return
		}

		showProgress = true

		proofManager?.fetchCoronaTestProviders(
			oncompletion: { [weak self] in

				self?.showProgress = false
				self?.fetchResult(requestToken)

			}, onError: { [weak self] error in

				self?.showProgress = false
				self?.showError = true
			}
		)
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
							self?.handleVerificationRequired()
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
						self?.showError = true
					}
			}
		}
	}

	/// Handle the verfication required response
	func handleVerificationRequired() {

		if showVerification {
			// We are showing the verification entry, so this is a wrong verification code
			errorMessage = .holderTokenEntryErrorInvalidCode
		}
		showVerification = true
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
					protocolVersion: highestKnownProtocolVersion,
					providerIdentifier: identifierPart
				)
			}
		}
		return nil
	}
}
