/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryViewModel {
	
	/// There are four "modes" for user entry
	/// that determine which fields (if any) should be shown at one time.
	fileprivate enum InputMode {
		case none // hide all fields
		case inputToken
		case inputTokenWithVerificationCode
		case inputVerificationCode
	}
	
	// MARK: - Bindables
	
	/// The navbar title
	@Bindable private(set) var title: String = .holderTokenEntryTitle
	
	/// The description label underneath the navbar title
	@Bindable private(set) var message: String?
	
	/// Do not set directly. Instead, increment or decrement `var inProgressCount: Int`.
	@Bindable private(set) var shouldShowProgress: Bool = false {
		didSet {
			recalculateAndUpdateUI(tokenValidityIndicator: requestToken != nil)
		}
	}
	@Bindable private(set) var shouldShowTokenEntryField: Bool = false
	@Bindable private(set) var shouldShowVerificationEntryField: Bool = false
	@Bindable private(set) var shouldShowNextButton: Bool = true
	@Bindable private(set) var enableNextButton: Bool = false
	@Bindable private(set) var fieldErrorMessage: String?
	@Bindable private(set) var resendVerificationButtonTitle: String?
	@Bindable private(set) var resendVerificationButtonEnabled: Bool = false
	
	/// Show internet error
	@Bindable private(set) var showTechnicalErrorAlert: Bool = false
	
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
	
	///
	private var hasEverMadeFieldsVisible: Bool = false
	
	// Hopefully can remove this after a refactor.
	// Indicates that we've forwarded to the coordinator and there's nothing left to do
	private var screenHasCompleted: Bool = false {
		didSet {
			recalculateAndUpdateUI(tokenValidityIndicator: true)
		}
	}
	
	private var verificationCodeIsKnownToBeRequired = false {
		didSet {
			recalculateAndUpdateUI(tokenValidityIndicator: true)
		}
	}
	
	private var inProgressCount = 0 {
		didSet {
			objc_sync_enter(self)
			defer { objc_sync_exit(self) }
			
			guard inProgressCount >= 0 else { return }
			
			let newState = inProgressCount > 0
			// Prevent multiple applications of same shouldShowProgress
			// state, showing multiple spinners..
			if shouldShowProgress != newState {
				shouldShowProgress = newState
			}
		}
	}
	
	private func incrementProgressCount() {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		inProgressCount += 1
	}
	
	private func decrementProgressCount() {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		inProgressCount -= 1
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
		
		if let unwrappedToken = requestToken {
			self.wasInitializedWithARequestToken = true
			self.fetchProviders(unwrappedToken)
			recalculateAndUpdateUI(tokenValidityIndicator: nil)
		} else {
			self.wasInitializedWithARequestToken = false
			recalculateAndUpdateUI(tokenValidityIndicator: nil)
		}
	}
	
	// MARK: Handling user input
	
	/// Check the next button state
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func handleInput(_ tokenInput: String?, verificationInput: String?) {
		
		fieldErrorMessage = nil
		guard let tokenInput = tokenInput else {
			enableNextButton = false
			return
		}
		
		if !tokenInput.isEmpty {
			
			let validToken = tokenValidator.validate(sanitize(tokenInput))
			enableNextButton = validToken
			
			recalculateAndUpdateUI(tokenValidityIndicator: validToken)
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
		
		if wasInitializedWithARequestToken {
			handleNextButtonPressedDuringInitialRequestTokenFlow(verificationInput: verificationInput)
		} else {
			handleNextButtonPressedDuringRegularFlow(tokenInput, verificationInput: verificationInput)
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
				handleNextButtonPressedDuringRegularFlow(tokenInput, verificationInput: nil)
			}
		}
	}
	
	// MARK: - Private tap handlers:
	
	private func handleNextButtonPressedDuringRegularFlow(_ tokenInput: String?, verificationInput: String?) {
		fieldErrorMessage = nil
		
		guard let tokenInput = tokenInput else {
			return
		}
		
		if let verification = verificationInput, !verification.isEmpty {
			verificationCode = sanitize(verification)
			fieldErrorMessage = nil
			if let token = requestToken {
				fetchProviders(token)
			}
		} else {
			if let requestToken = RequestToken(input: sanitize(tokenInput), tokenValidator: tokenValidator) {
				self.requestToken = requestToken
				fetchProviders(requestToken)
			} else {
				fieldErrorMessage = .holderTokenEntryErrorInvalidCode
			}
		}
	}
	
	private func handleNextButtonPressedDuringInitialRequestTokenFlow(verificationInput: String?) {
		fieldErrorMessage = nil
		
		guard let requestToken = requestToken else { return }
		
		if let verification = verificationInput, !verification.isEmpty {
			verificationCode = sanitize(verification)
			fieldErrorMessage = nil
			
			fetchProviders(requestToken)
		}
	}
	
	// MARK: - Networking:
	
	/// Fetch the providers
	/// - Parameter requestToken: the request token
	private func fetchProviders(_ requestToken: RequestToken) {
		
		incrementProgressCount()
		recalculateAndUpdateUI(tokenValidityIndicator: true)
		
		proofManager?.fetchCoronaTestProviders(
			onCompletion: { [weak self] in
				
				self?.fetchResult(requestToken)
				self?.decrementProgressCount()
				
			}, onError: { [weak self] error in
				
				self?.showTechnicalErrorAlert = true
				self?.decrementProgressCount()
			}
		)
	}
	
	/// Fetch a test result
	/// - Parameter requestToken: the request token
	private func fetchResult(_ requestToken: RequestToken) {
		guard let provider = proofManager?.getTestProvider(requestToken) else {
			fieldErrorMessage = .holderTokenEntryErrorInvalidCode
			
			recalculateAndUpdateUI(tokenValidityIndicator: true)
			
			self.enableNextButton = true
			
			return
		}
		
		incrementProgressCount()
		
		proofManager?.fetchTestResult(
			requestToken,
			code: verificationCode,
			provider: provider) {  [weak self] response in
			
			self?.fieldErrorMessage = nil
			
			switch response {
				case let .success(wrapper):
					switch wrapper.status {
						case .complete, .pending:
							self?.screenHasCompleted = true
							self?.coordinator?.navigateToListResults()
						case .verificationRequired:
							self?.handleVerificationRequired()
						case .invalid:
							self?.fieldErrorMessage = .holderTokenEntryErrorInvalidCode
							self?.enableNextButton = true
						default:
							self?.logDebug("Unhandled test result status: \(wrapper.status)")
							self?.fieldErrorMessage = "Unhandled: \(wrapper.status)"
							self?.enableNextButton = true
					}
				case let .failure(error):
					
					if let castedError = error as? ProofError, castedError == .invalidUrl {
						self?.fieldErrorMessage = .holderTokenEntryErrorInvalidCode
					} else {
						// For now, display the network error.
						self?.fieldErrorMessage = error.localizedDescription
						self?.showTechnicalErrorAlert = true
					}
					self?.enableNextButton = true
			}
			
			self?.decrementProgressCount()
		}
	}
	
	/// Handle the verification required response
	private func handleVerificationRequired() {
		
		if let code = verificationCode, !code.isEmpty {
			// We are showing the verification entry, so this is a wrong verification code
			fieldErrorMessage = .holderTokenEntryErrorInvalidCode
		}
		enableNextButton = true
		resetCountdownCounter()
		startResendTimer()
		verificationCodeIsKnownToBeRequired = true
	}
	
	// MARK: - Resend SMS Countdown
	
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
			resendVerificationButtonTitle = String(format: .holderTokenEntryRetryCountdown, "\(resendCountdownCounter)")
			resendVerificationButtonEnabled = false
			resendCountdownCounter -= 1
		} else {
			resendCountdownCounter = 10
			resendTimer?.invalidate()
			resendTimer = nil
			resendVerificationButtonTitle = .holderTokenEntryRetryTitle
			resendVerificationButtonEnabled = true
		}
	}
	
	/// Calls `calculateInputMode()` with the correct values, passing result to `update(inputMode:)`.
	private func recalculateAndUpdateUI(tokenValidityIndicator: Bool?) {
		update(inputMode: TokenEntryViewModel.calculateInputMode(
				tokenValidityIndicator: tokenValidityIndicator,
				wasInitialisedWithARefreshToken: wasInitializedWithARequestToken,
				verificationCodeIsKnownToBeRequired: verificationCodeIsKnownToBeRequired,
				isInProgress: shouldShowProgress,
				hasEverMadeFieldsVisible: hasEverMadeFieldsVisible,
				screenHasCompleted: screenHasCompleted)
		)
	}
	
	/// Retains the current applied value of InputMode, for comparison with
	/// future applications.
	private var currentInputMode: InputMode? {
		didSet {
			if currentInputMode != TokenEntryViewModel.InputMode.none {
				hasEverMadeFieldsVisible = true
			}
		}
	}
	
	// Applies a new InputMode to the UI bindables
	// Should **not** not make any decisions
	private func update(inputMode newInputMode: InputMode) {
		guard newInputMode != currentInputMode else { return }
		currentInputMode = newInputMode
		
		switch newInputMode {
			case .none:
				shouldShowTokenEntryField = false
				shouldShowVerificationEntryField = false
				shouldShowNextButton = false
				message = nil
				
			case .inputToken:
				shouldShowTokenEntryField = true
				shouldShowVerificationEntryField = false
				shouldShowNextButton = true
				message = .holderTokenEntryText
				
			case .inputTokenWithVerificationCode:
				shouldShowTokenEntryField = true
				shouldShowVerificationEntryField = true
				shouldShowNextButton = true
				message = .holderTokenEntryText
				
			case .inputVerificationCode:
				shouldShowTokenEntryField = false
				shouldShowVerificationEntryField = true
				shouldShowNextButton = true
				message = .holderTokenEntryText
		}
	}
	
	private static func calculateInputMode(
		tokenValidityIndicator: Bool?, // IF we've validated the token, then provide the result here.
		wasInitialisedWithARefreshToken: Bool,
		verificationCodeIsKnownToBeRequired: Bool,
		isInProgress: Bool,
		hasEverMadeFieldsVisible: Bool,
		screenHasCompleted: Bool
	) -> TokenEntryViewModel.InputMode {
		
		if wasInitialisedWithARefreshToken {
			if hasEverMadeFieldsVisible {
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
	
	private func sanitize(_ input: String) -> String {
		
		return input
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
			.uppercased()
	}
}

extension TokenEntryViewModel: Logging {
	
	var loggingCategory: String {
		return "TokenEntryViewModel"
	}
}
