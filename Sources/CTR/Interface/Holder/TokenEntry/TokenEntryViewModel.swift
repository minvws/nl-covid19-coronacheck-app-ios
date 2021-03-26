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

	/// The token validator
	var tokenValidator: TokenValidatorProtocol = TokenValidator()

	/// The verification code
	var verificationCode: String?

	/// The current highest known protocol version
	/// 1.0: Checksum
	/// 2.0: Initials + Birthday/month
	let highestKnownProtocolVersion = "2.0"

	/// A timer to enable resending of the verification code
	var resendTimer: Timer?

	@Bindable private(set) var token: String?
	@Bindable private(set) var showProgress: Bool = false
	@Bindable private(set) var showVerification: Bool = false

	/// True if we should enable the next button
	@Bindable private(set) var enableNextButton: Bool = false

	/// An error message
	@Bindable private(set) var errorMessage: String?

	/// The title for the secondary button
	@Bindable private(set) var secondaryButtonTitle: String?

	/// Is the secondary button enabled?
	@Bindable private(set) var secondaryButtonEnabled: Bool = false

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

		if let unwrappedToken = requestToken {
			fetchProviders(unwrappedToken)
			self.token = "\(unwrappedToken.providerIdentifier)-\(unwrappedToken.token)"
		} else {
			self.token = nil
		}
	}

	/// Check the next button state
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func handleInput(_ tokenInput: String?, verificationInput: String?) {

		errorMessage = nil
		guard let tokenInput = tokenInput else {
			enableNextButton = false
			return
		}

		if !tokenInput.isEmpty { // && !showVerification {

			let validToken = tokenValidator.validate(tokenInput)
			enableNextButton = validToken
			showVerification = validToken && showVerification
			return
		}

		if let verification = verificationInput, verification.isEmpty {
			enableNextButton = false
			return
		}

		enableNextButton = true
	}

	/// User tapped the next button
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func nextButtonPressed(_ tokenInput: String?, verificationInput: String?) {

		guard let tokenInput = tokenInput else {
			return
		}

		if let verification = verificationInput, !verification.isEmpty {
			verificationCode = verification.uppercased()
			errorMessage = nil
			if let token = requestToken {
				fetchProviders(token)
			}
		} else {
			if let requestToken = createRequestToken(tokenInput.uppercased()) {
				self.requestToken = requestToken
				fetchProviders(requestToken)
				errorMessage = nil
			} else {
				errorMessage = .holderTokenEntryErrorInvalidCode
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
			showProgress = false
			errorMessage = .holderTokenEntryErrorInvalidCode
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
						self?.errorMessage = .holderTokenEntryErrorInvalidCode
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
		resetCounter()
		startTimer()
		showVerification = true
		enableNextButton = false
	}

	var counter = 10

	func resetCounter() {
		counter = 10
	}

	func startTimer() {

		guard resendTimer == nil else {
			return
		}
		// Show immediately, and repeat every second
		resendTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(1),
			target: self,
			selector: (#selector(resendButtonState)),
			userInfo: nil,
			repeats: true
		)
		resendTimer?.fire()
	}

	@objc func resendButtonState() {

		if counter > 0 {
			secondaryButtonTitle = String(format: .holderTokenEntryRetryCountdown, "\(counter)")
			secondaryButtonEnabled = false
			counter -= 1
		} else {
			counter = 10
			resendTimer?.invalidate()
			resendTimer = nil
			secondaryButtonTitle = .holderTokenEntryRetryTitle
			secondaryButtonEnabled = true
		}
	}

	/// Create a request token from a string
	/// - Parameter token: the input string
	/// - Returns: the request token
	func createRequestToken(_ input: String) -> RequestToken? {

		// Check the validity of the input
		guard tokenValidator.validate(input) else {
			return nil
		}

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
