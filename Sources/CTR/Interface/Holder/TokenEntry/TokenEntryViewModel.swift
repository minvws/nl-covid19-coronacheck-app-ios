/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryViewModel {

	// MARK: - Bindables

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

    // MARK: - Private vars

	private weak var coordinator: HolderCoordinatorDelegate?

	private let proofManager: ProofManaging?

	private var requestToken: RequestToken?

	private let tokenValidator: TokenValidatorProtocol

    /// A timer to enable resending of the verification code
    private var resendTimer: Timer?

	private var verificationCode: String?

	// Counter that tracks the countdown before the SMS can be resent
	private var resendCountdownCounter = 10

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - requestToken: an optional existing request token
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		requestToken: RequestToken?,
		tokenValidator: TokenValidatorProtocol = TokenValidator()) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.requestToken = requestToken
        self.tokenValidator = tokenValidator

		if let unwrappedToken = requestToken {
			fetchProviders(unwrappedToken)
			self.token = "\(unwrappedToken.providerIdentifier)-\(unwrappedToken.token)"
		} else {
			self.token = nil
		}
	}

	// MARK: Handling user input

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
        errorMessage = nil

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
			if let requestToken = RequestToken(input: tokenInput.uppercased(), tokenValidator: tokenValidator) {
				self.requestToken = requestToken
				fetchProviders(requestToken)
			} else {
				errorMessage = .holderTokenEntryErrorInvalidCode
			}
		}
	}

	/// Fetch the providers
	/// - Parameter requestToken: the request token
	private func fetchProviders(_ requestToken: RequestToken) {

		showProgress = true
		proofManager?.fetchCoronaTestProviders(
			onCompletion: { [weak self] in

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

	/// Handle the verification required response
	private func handleVerificationRequired() {

		if let code = verificationCode, !code.isEmpty {
			// We are showing the verification entry, so this is a wrong verification code
			errorMessage = .holderTokenEntryErrorInvalidCode
		}
		resetCountdownCounter()
		startResendTimer()
		showVerification = true
		enableNextButton = false
	}

	// MARK: Resend SMS Countdown

	private func resetCountdownCounter() {
		resendCountdownCounter = 10
	}

	private func startResendTimer() {

		guard resendTimer == nil else {
			return
		}
		// Show immediately, and repeat every second
		resendTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(1),
			target: self,
			selector: (#selector(updateResendButtonState)),
			userInfo: nil,
			repeats: true
		)
		resendTimer?.fire()
	}

	@objc func updateResendButtonState() {

		if resendCountdownCounter > 0 {
			secondaryButtonTitle = String(format: .holderTokenEntryRetryCountdown, "\(resendCountdownCounter)")
			secondaryButtonEnabled = false
			resendCountdownCounter -= 1
		} else {
			resendCountdownCounter = 10
			resendTimer?.invalidate()
			resendTimer = nil
			secondaryButtonTitle = .holderTokenEntryRetryTitle
			secondaryButtonEnabled = true
		}
	}
}

extension TokenEntryViewModel: Logging {

	var loggingCategory: String {
		return "TokenEntryViewModel"
	}
}
