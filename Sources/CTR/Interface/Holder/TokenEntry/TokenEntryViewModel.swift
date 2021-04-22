/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryViewModel {

    fileprivate enum InputMode {
        case none // hide all fields
        case inputToken
        case inputTokenWithVerificationCode
        case inputVerificationCode
    }

    private var verificationCodeIsKnownToBeRequired = false {
        didSet {
            update(
                inputMode: calculateInputMode(
                    tokenValidityIndicator: true,
                    wasInitialisedWithARefreshToken: wasInitializedWithARequestToken,
                    verificationCodeIsKnownToBeRequired: verificationCodeIsKnownToBeRequired,
                    isInProgress: shouldShowProgress,
                    hasEverPressedNextButton: hasEverPressedNextButton,
                    screenHasCompleted: screenHasCompleted
                )
            )
        }
    }

    // Applies the outcome of a decision about the new InputMode
    // i.e. does not make any decisions
    private func update(inputMode newInputMode: InputMode) {
        switch newInputMode {
            case .none:
                shouldShowTokenEntryField = false
                shouldShowVerificationEntryField = false
                shouldShowNextButton = false
                title = "Testresultaat ophalen" // TODO
                message = nil
                
            case .inputToken:
                shouldShowTokenEntryField = true
                shouldShowVerificationEntryField = false
                shouldShowNextButton = true
                title = .holderTokenEntryTitle
                message = .holderTokenEntryText

            case .inputTokenWithVerificationCode:
                shouldShowTokenEntryField = true
                shouldShowVerificationEntryField = true
                shouldShowNextButton = true
                title = .holderTokenEntryTitle
                message = .holderTokenEntryText

            case .inputVerificationCode:
                shouldShowTokenEntryField = false
                shouldShowVerificationEntryField = true
                shouldShowNextButton = true

                if wasInitializedWithARequestToken {
                    title = "Testresultaat ophalen" // TODO
                    message = "Vul jouw verficatie code in.." // TODO
                } else {
                    title = .holderTokenEntryTitle
                    message = .holderTokenEntryText
                }
        }
    }

	// MARK: - Bindables

    @Bindable private(set) var title: String
    @Bindable private(set) var message: String?
    @Bindable private(set) var shouldShowProgress: Bool = false {
        didSet {
            update(
                inputMode: calculateInputMode(
                    tokenValidityIndicator: nil,
                    wasInitialisedWithARefreshToken: wasInitializedWithARequestToken,
                    verificationCodeIsKnownToBeRequired: verificationCodeIsKnownToBeRequired,
                    isInProgress: shouldShowProgress,
                    hasEverPressedNextButton: hasEverPressedNextButton,
                    screenHasCompleted: screenHasCompleted
                )
            )
        }
    }
    @Bindable private(set) var shouldShowTokenEntryField: Bool = false
    @Bindable private(set) var shouldShowVerificationEntryField: Bool = false

    @Bindable private(set) var shouldShowNextButton: Bool = true

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

    /// Indicates that the screen originated in a QR or Universal Link flow.
    private let wasInitializedWithARequestToken: Bool

    private var hasEverPressedNextButton: Bool = false

    // Hopefully can remove this after a refactor.
    // Indicates that we've forwarded to the coordinator and there's nothing left to do
    private var screenHasCompleted: Bool = false {
        didSet {
            update(
                inputMode: calculateInputMode(
                    tokenValidityIndicator: true,
                    wasInitialisedWithARefreshToken: wasInitializedWithARequestToken,
                    verificationCodeIsKnownToBeRequired: verificationCodeIsKnownToBeRequired,
                    isInProgress: shouldShowProgress,
                    hasEverPressedNextButton: hasEverPressedNextButton,
                    screenHasCompleted: screenHasCompleted
                )
            )
        }
    }

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
        self.message = nil
        self.title = ""

		if let unwrappedToken = requestToken {
            self.wasInitializedWithARequestToken = true
            self.fetchProviders(unwrappedToken)
		} else {
            self.wasInitializedWithARequestToken = false

            update(
                inputMode: calculateInputMode(
                    tokenValidityIndicator: nil,
                    wasInitialisedWithARefreshToken: false,
                    verificationCodeIsKnownToBeRequired: false,
                    isInProgress: false,
                    hasEverPressedNextButton: hasEverPressedNextButton,
                    screenHasCompleted: screenHasCompleted
                )
            )
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

		if !tokenInput.isEmpty {

			let validToken = tokenValidator.validate(tokenInput)
			enableNextButton = validToken

            update(
                inputMode: calculateInputMode(
                    tokenValidityIndicator: validToken,
                    wasInitialisedWithARefreshToken: wasInitializedWithARequestToken,
                    verificationCodeIsKnownToBeRequired: verificationCodeIsKnownToBeRequired,
                    isInProgress: shouldShowProgress,
                    hasEverPressedNextButton: hasEverPressedNextButton,
                    screenHasCompleted: screenHasCompleted
                )
            )
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
        hasEverPressedNextButton = true

        if wasInitializedWithARequestToken {
            nextButtonPressedDuringInitialRequestTokenFlow(verificationInput: verificationInput)
        } else {
            nextButtonPressedDuringRegularFlow(tokenInput, verificationInput: verificationInput)
        }
	}

    private func nextButtonPressedDuringRegularFlow(_ tokenInput: String?, verificationInput: String?) {
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

    private func nextButtonPressedDuringInitialRequestTokenFlow(verificationInput: String?) {
        errorMessage = nil

        guard let requestToken = requestToken else {
            fatalError("shouldn't go here") // TODO remove
            return
        }

        if let verification = verificationInput, !verification.isEmpty {
            verificationCode = verification.uppercased()
            errorMessage = nil
            fetchProviders(requestToken)
        }
    }

    /// tokenInput can be nil in the case of `wasInitializedWithARequestToken`
    func sendVerificationAgainButtonPressed(tokenInput: String?) {

        if wasInitializedWithARequestToken {
            if let unwrappedToken = requestToken {
                self.fetchProviders(unwrappedToken)
            }
        } else {
            if let tokenInput = tokenInput {
                // TODO: rename this function or something
                nextButtonPressedDuringRegularFlow(tokenInput, verificationInput: nil)
            }
        }
    }

	/// Fetch the providers
	/// - Parameter requestToken: the request token
	private func fetchProviders(_ requestToken: RequestToken) {

        shouldShowProgress = true

        proofManager?.fetchCoronaTestProviders(
			onCompletion: { [weak self] in

				self?.shouldShowProgress = false
				self?.fetchResult(requestToken)

			}, onError: { [weak self] error in

				self?.shouldShowProgress = false
				self?.showError = true
			}
		)
	}

	/// Fetch a test result
	/// - Parameter requestToken: the request token
	private func fetchResult(_ requestToken: RequestToken) {
		guard let provider = proofManager?.getTestProvider(requestToken) else {
            shouldShowProgress = false
			errorMessage = .holderTokenEntryErrorInvalidCode

            update(inputMode: calculateInputMode(
                    tokenValidityIndicator: true,
                    wasInitialisedWithARefreshToken: wasInitializedWithARequestToken,
                    verificationCodeIsKnownToBeRequired: verificationCodeIsKnownToBeRequired,
                    isInProgress: false,
                    hasEverPressedNextButton: hasEverPressedNextButton,
                    screenHasCompleted: screenHasCompleted)
            )
            self.enableNextButton = true

			return
		}

        shouldShowProgress = true
		proofManager?.fetchTestResult(
			requestToken,
			code: verificationCode,
			provider: provider) {  [weak self] response in

			self?.shouldShowProgress = false
			self?.errorMessage = nil

			switch response {
				case let .success(wrapper):
					switch wrapper.status {
						case .complete, .pending:
                            self?.screenHasCompleted = true
                            self?.coordinator?.navigateToListResults()
						case .verificationRequired:
							self?.handleVerificationRequired()
						case .invalid:
							self?.errorMessage = .holderTokenEntryErrorInvalidCode
                            self?.enableNextButton = true
						default:
							self?.logDebug("Unhandled test result status: \(wrapper.status)")
							self?.errorMessage = "Unhandled: \(wrapper.status)"
                            self?.enableNextButton = true
					}
				case let .failure(error):

					if let castedError = error as? ProofError, castedError == .invalidUrl {
						self?.errorMessage = .holderTokenEntryErrorInvalidCode
					} else {
						// For now, display the network error.
						self?.errorMessage = error.localizedDescription
						self?.showError = true
					}
                    self?.enableNextButton = true
            }
        }
	}

	/// Handle the verification required response
	private func handleVerificationRequired() {

		if let code = verificationCode, !code.isEmpty {
			// We are showing the verification entry, so this is a wrong verification code
			errorMessage = .holderTokenEntryErrorInvalidCode
            enableNextButton = true
        } else {
            enableNextButton = false
        }
		resetCountdownCounter()
		startResendTimer()
        verificationCodeIsKnownToBeRequired = true

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

private func calculateInputMode(
    tokenValidityIndicator: Bool?, // IF we've validated the token, then provide the result here.
    wasInitialisedWithARefreshToken: Bool,
    verificationCodeIsKnownToBeRequired: Bool,
    isInProgress: Bool,
    hasEverPressedNextButton: Bool,
    screenHasCompleted: Bool
) -> TokenEntryViewModel.InputMode {

    if wasInitialisedWithARefreshToken {
        if hasEverPressedNextButton {
            return .inputVerificationCode
        } else {
            if isInProgress || screenHasCompleted {
                return .none
            } else {
                return .inputVerificationCode
            }
        }
    } else {
        if tokenValidityIndicator == true && verificationCodeIsKnownToBeRequired {
            return .inputTokenWithVerificationCode
        } else {
            return .inputToken
        }
    }
}
