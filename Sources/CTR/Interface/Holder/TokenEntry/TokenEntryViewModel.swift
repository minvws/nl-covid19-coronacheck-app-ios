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

	fileprivate enum InitializationMode: Equatable {
		case regular
		case withRequestTokenProvided(originalRequestToken: RequestToken)
	}

	// MARK: - Bindables

	/// The navbar title
	@Bindable private(set) var title: String

	/// The description label underneath the navbar title
	@Bindable private(set) var message: String?

	@Bindable private(set) var tokenEntryHeaderTitle: String
	@Bindable private(set) var tokenEntryPlaceholder: String
	@Bindable private(set) var verificationEntryHeaderTitle: String
	@Bindable private(set) var verificationInfo: String
	@Bindable private(set) var verificationPlaceholder: String
	@Bindable private(set) var primaryTitle: String

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
	@Bindable private(set) var resendVerificationButtonEnabled: Bool = true
	@Bindable private(set) var shouldShowResendVerificationButton: Bool = false

	/// Show internet error
	@Bindable private(set) var showTechnicalErrorAlert: Bool = false

	// MARK: - Private vars

	private weak var coordinator: HolderCoordinatorDelegate?
	private let proofManager: ProofManaging?
	private var requestToken: RequestToken?
	private let tokenValidator: TokenValidatorProtocol

	/// The most recent user-submitted verification code
	private var verificationCode: String?

	// Counter that tracks the countdown before the SMS can be resent
	private var resendCountdownCounter = 10

	private let initializationMode: InitializationMode

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
			self.initializationMode = .withRequestTokenProvided(originalRequestToken: unwrappedToken)
		} else {
			self.initializationMode = .regular
		}

		self.title = Strings.holderTokenEntryTitle(forMode: initializationMode)
		self.tokenEntryHeaderTitle = Strings.tokenEntryHeaderTitle(forMode: initializationMode)
		self.tokenEntryPlaceholder = Strings.tokenEntryPlaceholder(forMode: initializationMode)
		self.verificationEntryHeaderTitle = Strings.verificationEntryHeaderTitle(forMode: initializationMode)
		self.verificationInfo = Strings.verificationInfo(forMode: initializationMode)
		self.verificationPlaceholder = Strings.verificationPlaceholder(forMode: initializationMode)
		self.primaryTitle = Strings.primaryTitle(forMode: initializationMode)
		self.resendVerificationButtonTitle = Strings.holderTokenEntryRetryTitle(forMode: initializationMode)

		if let unwrappedToken = requestToken {
			self.fetchProviders(unwrappedToken)
		}
		recalculateAndUpdateUI(tokenValidityIndicator: nil)
	}

	// MARK: Handling user input

	/// Check the next button state
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func handleInput(_ tokenInput: String?, verificationInput: String?) {

		fieldErrorMessage = nil

		let sanitizedTokenInput = tokenInput.map({ sanitize($0) })
		let sanitizedVerificationInput = verificationInput.map({ sanitize($0) })
		let receivedNonemptyVerificationInput = !(sanitizedVerificationInput ?? "").isEmpty

		switch initializationMode {
			case .regular:
				guard let sanitizedTokenInput = sanitizedTokenInput, !sanitizedTokenInput.isEmpty else {
					enableNextButton = false
					return
				}
				let validToken = tokenValidator.validate(sanitizedTokenInput)

				if verificationCodeIsKnownToBeRequired {
					enableNextButton = validToken && receivedNonemptyVerificationInput
				} else {
					enableNextButton = validToken
				}

				recalculateAndUpdateUI(tokenValidityIndicator: validToken)
				return

			case .withRequestTokenProvided:
				// Then we don't care about the tokenInput parameter, because it's hidden
				guard verificationCodeIsKnownToBeRequired else {
					logWarning("Input in `withRequestTokenProvided` mode without `verificationCodeIsKnownToBeRequired` being set, is unexpected.")
					return
				}

				enableNextButton = receivedNonemptyVerificationInput
				return
		}
	}

	/// User tapped the next button
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func nextButtonPressed(_ tokenInput: String?, verificationInput: String?) {

		switch initializationMode {
			case .regular:
				handleNextButtonPressedDuringRegularFlow(tokenInput, verificationInput: verificationInput)
			case .withRequestTokenProvided:
				handleNextButtonPressedDuringInitialRequestTokenFlow(verificationInput: verificationInput)
		}
	}

	/// tokenInput can be nil in the case of `wasInitializedWithARequestToken`
	func sendVerificationAgainButtonPressed(tokenInput: String?) {

		switch initializationMode {
			case .regular:
				if let tokenInput = tokenInput {
					handleNextButtonPressedDuringRegularFlow(tokenInput, verificationInput: nil)
				}
			case .withRequestTokenProvided:
				if let unwrappedToken = requestToken {
					self.fetchProviders(unwrappedToken)
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
				fieldErrorMessage = Strings.holderTokenEntryErrorInvalidCode(forMode: initializationMode)
			}
		}
	}

	private func handleNextButtonPressedDuringInitialRequestTokenFlow(verificationInput: String?) {
		fieldErrorMessage = nil

		guard let requestToken = requestToken else { return }

		if let sanitizedVerification = verificationInput.map({ sanitize($0) }),
		   !sanitizedVerification.isEmpty {
			verificationCode = sanitizedVerification
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
			fieldErrorMessage = Strings.holderTokenEntryErrorInvalidCode(forMode: initializationMode)

			recalculateAndUpdateUI(tokenValidityIndicator: true)

			self.enableNextButton = true

			return
		}

		incrementProgressCount()

		proofManager?.fetchTestResult(
			requestToken,
			code: verificationCode,
			provider: provider) {  [weak self] response in
			guard let self = self else { return }

			self.fieldErrorMessage = nil

			switch response {
				case let .success(wrapper):
					switch wrapper.status {
						case .complete, .pending:
							self.screenHasCompleted = true
							self.coordinator?.navigateToListResults()
						case .verificationRequired:
							self.handleVerificationRequired()
						case .invalid:
							self.fieldErrorMessage = Strings.holderTokenEntryErrorInvalidCode(forMode: self.initializationMode)
							self.enableNextButton = true
						default:
							self.logDebug("Unhandled test result status: \(wrapper.status)")
							self.fieldErrorMessage = "Unhandled: \(wrapper.status)"
							self.enableNextButton = true
					}
				case let .failure(error):

					if let castedError = error as? ProofError, castedError == .invalidUrl {
						self.fieldErrorMessage = Strings.holderTokenEntryErrorInvalidCode(forMode: self.initializationMode)
					} else {
						// For now, display the network error.
						self.fieldErrorMessage = error.localizedDescription
						self.showTechnicalErrorAlert = true
					}
					self.enableNextButton = true
			}

			self.decrementProgressCount()
		}
	}

	/// Handle the verification required response
	private func handleVerificationRequired() {

		if let code = verificationCode, !code.isEmpty {
			// We are showing the verification entry, so this is a wrong verification code
			fieldErrorMessage = Strings.holderTokenEntryErrorInvalidCode(forMode: initializationMode)
		}
		enableNextButton = false
		verificationCodeIsKnownToBeRequired = true
	}


	/// Calls `calculateInputMode()` with the correct values, passing result to `update(inputMode:)`.
	private func recalculateAndUpdateUI(tokenValidityIndicator: Bool?) {
		update(inputMode: TokenEntryViewModel.calculateInputMode(
				tokenValidityIndicator: tokenValidityIndicator,
				initializationMode: initializationMode,
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
				shouldShowResendVerificationButton = false

			case .inputToken:
				shouldShowTokenEntryField = true
				shouldShowVerificationEntryField = false
				shouldShowNextButton = true
				shouldShowResendVerificationButton = false

			case .inputTokenWithVerificationCode:
				shouldShowTokenEntryField = true
				shouldShowVerificationEntryField = true
				shouldShowNextButton = true
				shouldShowResendVerificationButton = true

			case .inputVerificationCode:
				shouldShowTokenEntryField = false
				shouldShowVerificationEntryField = true
				shouldShowNextButton = true
				shouldShowResendVerificationButton = true
		}

		message = Strings.holderTokenEntryText(forMode: initializationMode, inputMode: newInputMode)
	}

	private static func calculateInputMode(
		tokenValidityIndicator: Bool?, // IF we've validated the token, then provide the result here.
		initializationMode: InitializationMode,
		verificationCodeIsKnownToBeRequired: Bool,
		isInProgress: Bool,
		hasEverMadeFieldsVisible: Bool,
		screenHasCompleted: Bool
	) -> TokenEntryViewModel.InputMode {

		switch initializationMode {
			case .regular:
				if tokenValidityIndicator == true && verificationCodeIsKnownToBeRequired {
					return .inputTokenWithVerificationCode
				} else {
					return .inputToken
				}
			case .withRequestTokenProvided:
				if hasEverMadeFieldsVisible {
					return .inputVerificationCode
				} else {
					if isInProgress || screenHasCompleted {
						return .none
					} else {
						return .inputVerificationCode
					}
				}
		}
	}

	/// Sanitize userInput of token & validation
	private func sanitize(_ input: String) -> String {

		return input
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
			.uppercased()
	}
}

/// Mechanism for dynamically retrieving Strings depending on the `InitializationMode`:
extension TokenEntryViewModel {

	struct Strings {
		fileprivate static func holderTokenEntryTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowTitle
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowTitle
			}
		}

		fileprivate static func holderTokenEntryText(forMode initializationMode: InitializationMode, inputMode: InputMode) -> String? {
			switch (initializationMode, inputMode) {
				case (_, .none):
					return nil
				case (.regular, _):
					return .holderTokenEntryRegularFlowText
				case (.withRequestTokenProvided, _):
					return .holderTokenEntryUniversalLinkFlowText
			}
		}

		fileprivate static func holderTokenEntryRetryTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowRetryTitle
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowRetryTitle
			}
		}

		fileprivate static func holderTokenEntryRetryCountdown(counter: Int, forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return String(format: .holderTokenEntryRegularFlowRetryCountdown, "\(counter)")
				case .withRequestTokenProvided:
					return String(format: .holderTokenEntryUniversalLinkFlowRetryCountdown, "\(counter)")
			}
		}

		fileprivate static func holderTokenEntryErrorInvalidCode(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowErrorInvalidCode
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowErrorInvalidCode
			}
		}

		fileprivate static func tokenEntryHeaderTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowTokenTitle
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowTokenTitle
			}
		}

		fileprivate static func tokenEntryPlaceholder(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowTokenPlaceholder
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowTokenPlaceholder
			}
		}

		fileprivate static func verificationEntryHeaderTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowVerificationTitle
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowVerificationTitle
			}
		}

		fileprivate static func verificationInfo(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowVerificationInfo
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowVerificationInfo
			}
		}

		fileprivate static func verificationPlaceholder(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowVerificationPlaceholder
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowVerificationPlaceholder
			}
		}

		fileprivate static func primaryTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return .holderTokenEntryRegularFlowNext
				case .withRequestTokenProvided:
					return .holderTokenEntryUniversalLinkFlowNext
			}
		}
	}
}

extension TokenEntryViewModel: Logging {

	var loggingCategory: String {
		return "TokenEntryViewModel"
	}
}
