/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length
// swiftlint:disable type_body_length

import UIKit

class TokenEntryViewModel {

	/// There are four "modes" for user entry
	/// that determine which fields (if any) should be shown at one time.
	fileprivate enum InputMode {
		case none // hide all fields
		case inputToken
		case inputTokenWithVerificationCode
		case inputVerificationCode
		case error
	}

	fileprivate enum InitializationMode: Equatable {
		case regular
		case withRequestTokenProvided(originalRequestToken: RequestToken)
		case error(serverError: ServerError)
	}

	// MARK: - Bindable Strings

	/// The navbar title
	@Bindable private(set) var title: String = ""

	/// The description label underneath the navbar title
	@Bindable private(set) var message: String?
	@Bindable private(set) var tokenEntryHeaderTitle = ""
	@Bindable private(set) var tokenEntryPlaceholder = ""
	@Bindable private(set) var verificationEntryHeaderTitle = ""
	@Bindable private(set) var verificationInfo = ""
	@Bindable private(set) var verificationPlaceholder = ""
	@Bindable private(set) var primaryTitle = ""
	@Bindable private(set) var fieldErrorMessage: String?
	@Bindable private(set) var userNeedsATokenButtonTitle: String?
	@Bindable private(set) var resendVerificationButtonTitle: String?
	@Bindable private(set) var confirmResendVerificationAlertTitle: String?
	@Bindable private(set) var confirmResendVerificationAlertMessage: String?
	@Bindable private(set) var confirmResendVerificationAlertOkayButton: String?
	@Bindable private(set) var confirmResendVerificationAlertCancelButton: String?

	// MARK: - Bindable Boolean state

	/// Do not set directly. Instead, increment or decrement `var inProgressCount: Int`.
	@Bindable private(set) var shouldShowProgress: Bool = false {
		didSet {
			recalculateAndUpdateUI(tokenValidityIndicator: requestToken != nil)
			shouldEnableNextButton = nextButtonEnabledState(
				allowEnablingOfNextButton: allowEnablingOfNextButton,
				shouldShowProgress: shouldShowProgress,
				screenHasCompleted: screenHasCompleted
			)
		}
	}
	/// Do not set directly. Instead, see `preventEnablingOfNextButton`.
	@Bindable private(set) var shouldEnableNextButton: Bool = false {
		didSet {
			recalculateAndUpdateUI(tokenValidityIndicator: requestToken != nil)
		}
	}

	@Bindable private(set) var shouldShowTokenEntryField: Bool = false
	@Bindable private(set) var shouldShowVerificationEntryField: Bool = false
	@Bindable private(set) var shouldShowNextButton: Bool = true
	@Bindable private(set) var shouldShowUserNeedsATokenButton: Bool = true
	@Bindable private(set) var shouldShowResendVerificationButton: Bool = false

	// MARK: - Bindables, other

	@Bindable private(set) var networkErrorAlert: AlertContent?

	// MARK: - Private Dependencies:

	private weak var coordinator: HolderCoordinatorDelegate?
	private let networkManager: NetworkManaging?
	private let tokenValidator: TokenValidatorProtocol

	// MARK: - Private State:

	private var requestToken: RequestToken? {
		didSet {
			if requestToken == nil {
				verificationCodeIsKnownToBeRequired = false
				allowEnablingOfNextButton = false
			}
		}
	}
	private var initializationMode: InitializationMode
	private var hasEverMadeFieldsVisible: Bool = false

	/// Instead of updating `shouldEnableNextButton` directly, internal logic
	/// should toggle `preventEnablingOfNextButton` to indicate its preference.
	/// The actual state of `shouldEnableNextButton` is also dependent on `shouldShowProgress`.
	private var allowEnablingOfNextButton = false {
		didSet {
			shouldEnableNextButton = nextButtonEnabledState(
				allowEnablingOfNextButton: allowEnablingOfNextButton,
				shouldShowProgress: shouldShowProgress,
				screenHasCompleted: screenHasCompleted
			)
		}
	}

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

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - requestToken: an optional existing request token
	init(
		coordinator: HolderCoordinatorDelegate,
		networkManager: NetworkManaging,
		requestToken: RequestToken?,
		tokenValidator: TokenValidatorProtocol = TokenValidator()) {

		self.coordinator = coordinator
		self.networkManager = networkManager
		self.requestToken = requestToken
		self.tokenValidator = tokenValidator
		self.message = nil

		if let unwrappedToken = requestToken {
			self.initializationMode = .withRequestTokenProvided(originalRequestToken: unwrappedToken)
		} else {
			self.initializationMode = .regular
		}

		if let unwrappedToken = requestToken {
			self.fetchProviders(unwrappedToken, verificationCode: nil)
		}
		recalculateAndUpdateUI(tokenValidityIndicator: nil)
	}

	// MARK: Handling user input

	func userDidUpdateTokenField(rawTokenInput: String?, currentValueOfVerificationInput: String?) {

		guard currentInputMode != .inputTokenWithVerificationCode else {
			// User has changed the token field, this is not permitted during the `.inputTokenWithVerificationCode` mode,
			// so abort and reset back to `.inputToken`
			requestToken = nil
			return
		}

		handleInput(rawTokenInput, verificationInput: currentValueOfVerificationInput)
	}

	func userDidUpdateVerificationField(rawVerificationInput: String?, currentValueOfTokenInput: String?) {
		handleInput(currentValueOfTokenInput, verificationInput: rawVerificationInput)
	}

	/// Check the next button state
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	private func handleInput(_ tokenInput: String?, verificationInput: String?) {

		fieldErrorMessage = nil

		let sanitizedTokenInput = tokenInput.map({ sanitize($0) })
		let sanitizedVerificationInput = verificationInput.map({ sanitize($0) })
		let receivedNonemptyVerificationInput = !(sanitizedVerificationInput ?? "").isEmpty

		switch initializationMode {
			case .regular:
				guard let sanitizedTokenInput = sanitizedTokenInput, !sanitizedTokenInput.isEmpty else {
					requestToken = nil
					return
				}

				allowEnablingOfNextButton = {
					let validToken = tokenValidator.validate(sanitizedTokenInput)

					if verificationCodeIsKnownToBeRequired {
						return validToken && receivedNonemptyVerificationInput
					} else {
						return validToken
					}
				}()

			case .withRequestTokenProvided:
				// Then we don't care about the tokenInput parameter, because it's hidden
				guard verificationCodeIsKnownToBeRequired else {
					logWarning("Input in `withRequestTokenProvided` mode without `verificationCodeIsKnownToBeRequired` being set, is unexpected.")
					return
				}

				allowEnablingOfNextButton = receivedNonemptyVerificationInput
			case .error:
				allowEnablingOfNextButton = true
		}
	}

	/// User tapped the next button
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func nextButtonTapped(_ tokenInput: String?, verificationInput: String?) {

		guard progressIndicationCounter.isInactive else { return }

		switch initializationMode {
			case .regular:
				handleNextButtonPressedDuringRegularFlow(tokenInput, verificationInput: verificationInput)
			case .withRequestTokenProvided:
				handleNextButtonPressedDuringInitialRequestTokenFlow(verificationInput: verificationInput)
			case .error:
				coordinator?.navigateBackToStart()
		}
	}

	/// tokenInput can be nil in the case of `wasInitializedWithARequestToken`
	func resendVerificationCodeButtonTapped() {
		guard progressIndicationCounter.isInactive else { return }

		fieldErrorMessage = nil

		if let requestToken = requestToken {
			self.fetchProviders(requestToken, verificationCode: nil)
		}
	}

	func userHasNoTokenButtonTapped() {

		guard progressIndicationCounter.isInactive else { return }

		switch initializationMode {
			case .regular, .withRequestTokenProvided:
				coordinator?.presentInformationPage(
					title: L.holderTokenentryModalNotokenTitle(),
					body: L.holderTokenentryModalNotokenDetails(),
					hideBodyForScreenCapture: false,
					openURLsInApp: true
				)
			case .error:
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
					return
				}
				coordinator?.openUrl(url, inApp: true)
		}
	}

	// MARK: - Private tap handlers:

	private func handleNextButtonPressedDuringRegularFlow(_ tokenInput: String?, verificationInput: String?) {
		fieldErrorMessage = nil

		guard let tokenInput = tokenInput else { return }

		if currentInputMode == .inputVerificationCode || currentInputMode == .inputTokenWithVerificationCode,
		   let verification = verificationInput, !verification.isEmpty {
			fieldErrorMessage = nil
			if let token = requestToken {
				fetchProviders(token, verificationCode: sanitize(verification))
			}
		} else {
			if let requestToken = RequestToken(input: sanitize(tokenInput), tokenValidator: tokenValidator) {
				self.requestToken = requestToken
				fetchProviders(requestToken, verificationCode: nil)
			} else {
				fieldErrorMessage = Strings.errorInvalidCode(forMode: initializationMode)
			}
		}
	}

	private func handleNextButtonPressedDuringInitialRequestTokenFlow(verificationInput: String?) {
		fieldErrorMessage = nil

		guard let requestToken = requestToken else { return }

		if let sanitizedVerification = verificationInput.map({ sanitize($0) }),
		   !sanitizedVerification.isEmpty {

			fieldErrorMessage = nil
			fetchProviders(requestToken, verificationCode: sanitizedVerification)
		}
	}

	// MARK: - Networking:

	/// Fetch the providers
	/// - Parameter requestToken: the request token
	private func fetchProviders(_ requestToken: RequestToken, verificationCode: String?) {

		progressIndicationCounter.increment()

		networkManager?.fetchTestProviders { [weak self] (result: Result<[TestProvider], ServerError>) in

			guard let self = self else { return }

			switch result {
				case let .success(providers):
					self.fetchResult(requestToken, verificationCode: verificationCode, providers: providers)
					self.progressIndicationCounter.decrement()
				case let .failure(serverError):
					if case let .error(_, _, error) = serverError {
						switch error {
							case .noInternetConnection:
								self.displayNoInternet(requestToken, verificationCode: verificationCode)
							case .serverUnreachable:
								self.displayServerUnreachable(requestToken, verificationCode: verificationCode)
							default:
								self.initializationMode = .error(serverError: serverError)
						}
					}
					self.progressIndicationCounter.decrement()
					self.decideWhetherToAbortRequestTokenProvidedMode()
			}
		}
	}

	/// Fetch a test result
	/// - Parameter requestToken: the request token
	private func fetchResult(_ requestToken: RequestToken, verificationCode: String?, providers: [TestProvider]) {

		let provider = providers.filter { $0.identifier.lowercased() == requestToken.providerIdentifier.lowercased() }
		guard let provider = provider.first else {
			fieldErrorMessage = Strings.errorInvalidCode(forMode: initializationMode)
			self.decideWhetherToAbortRequestTokenProvidedMode()
			return
		}
		logVerbose("fetching result with \(provider.resultURLString)")

		if provider.resultURL == nil {
			fieldErrorMessage = Strings.errorInvalidCode(forMode: self.initializationMode)
			self.decideWhetherToAbortRequestTokenProvidedMode()
			return
		}

		progressIndicationCounter.increment()

		networkManager?.fetchTestResult(
			provider: provider,
			token: requestToken,
			code: verificationCode,
			completion: { [weak self] (result: Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) in

				guard let self = self else { return }
				self.fieldErrorMessage = nil

				switch result {
					case let .success(remoteEvent):
						switch remoteEvent.0.status {
							case .complete, .pending:
								self.screenHasCompleted = true
								self.coordinator?.userWishesToMakeQRFromNegativeTest(remoteEvent)
							case .verificationRequired:
								if self.verificationCodeIsKnownToBeRequired && verificationCode != nil {
									// the user has just submitted a wrong verification code & should see an error message
									self.fieldErrorMessage = Strings.errorInvalidCode(forMode: self.initializationMode)
								}
								self.allowEnablingOfNextButton = false
								self.verificationCodeIsKnownToBeRequired = true

							case .invalid:
								self.fieldErrorMessage = Strings.errorInvalidCode(forMode: self.initializationMode)
								self.decideWhetherToAbortRequestTokenProvidedMode() // TODO: write tests //swiftlint:disable:this todo

							default:
								self.logDebug("Unhandled test result status: \(remoteEvent.0.status)")
								self.fieldErrorMessage = "Unhandled: \(remoteEvent.0.status)"
								self.decideWhetherToAbortRequestTokenProvidedMode() // TODO: write tests //swiftlint:disable:this todo
						}

					case let .failure(serverError):
						switch serverError {
							case let .error(_, _, error), let .provider(_, _, _, error):
								switch error {
									case .noInternetConnection:
										self.displayNoInternet(requestToken, verificationCode: verificationCode)
									case .serverUnreachable:
										self.displayServerUnreachable(requestToken, verificationCode: verificationCode)
									case .invalidRequest:
										self.fieldErrorMessage = Strings.errorInvalidCode(forMode: self.initializationMode)
									default:
										if case let .error(statusCode, serverResponse, networkError) = serverError {
											self.initializationMode = .error(
												serverError: ServerError.provider(
													provider: provider.identifier,
													statusCode: statusCode,
													response: serverResponse,
													error: networkError
												)
											)
										} else {
											self.initializationMode = .error(serverError: serverError)
										}
								}
								self.decideWhetherToAbortRequestTokenProvidedMode()
						}
				}
				self.progressIndicationCounter.decrement()
			}
		)
	}

	/// If the path where `.withRequestTokenProvided` fails due to networking,
	/// we want to reset back to `.regular` mode, where the tokenEntry field is shown again
	private func decideWhetherToAbortRequestTokenProvidedMode() {
		switch self.initializationMode {
			case .regular, .error:
				// There must have been a token already entered, so this can be assumed:
				self.allowEnablingOfNextButton = true
			case .withRequestTokenProvided:
				if verificationCodeIsKnownToBeRequired {
					// in this situation, we know we definitely loaded a requestToken successfully the
					// first time, so no need to exit `.withRequestTokenProvided` mode.
					self.allowEnablingOfNextButton = true
				} else {
					// The `.withRequestTokenProvided` mode failed at some point
					// during `init`, so abort & reset to `.regular` mode.
					self.initializationMode = .regular
					self.allowEnablingOfNextButton = false
				}
		}
	}

	/// Calls `calculateInputMode()` with the correct values, passing result to `update(inputMode:)`.
	private func recalculateAndUpdateUI(tokenValidityIndicator: Bool?) {
		update(inputMode: initializationMode.calculateInputMode(
				tokenValidityIndicator: tokenValidityIndicator,
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
				shouldShowUserNeedsATokenButton = false

			case .inputToken:
				shouldShowTokenEntryField = true
				shouldShowVerificationEntryField = false
				shouldShowNextButton = true
				shouldShowResendVerificationButton = false
				shouldShowUserNeedsATokenButton = true

			case .inputTokenWithVerificationCode:
				shouldShowTokenEntryField = true
				shouldShowVerificationEntryField = true
				shouldShowNextButton = true
				shouldShowResendVerificationButton = true
				shouldShowUserNeedsATokenButton = false

			case .inputVerificationCode:
				shouldShowTokenEntryField = false
				shouldShowVerificationEntryField = true
				shouldShowNextButton = true
				shouldShowResendVerificationButton = true
				shouldShowUserNeedsATokenButton = false

			case .error:
				shouldShowTokenEntryField = false
				shouldShowVerificationEntryField = false
				shouldShowNextButton = true
				shouldShowResendVerificationButton = false
				shouldShowUserNeedsATokenButton = true
		}

		message = Strings.text(forMode: initializationMode, inputMode: newInputMode)
		title = Strings.title(forMode: initializationMode)
		tokenEntryHeaderTitle = Strings.tokenEntryHeaderTitle(forMode: initializationMode)
		tokenEntryPlaceholder = Strings.tokenEntryPlaceholder(forMode: initializationMode)
		verificationEntryHeaderTitle = Strings.verificationEntryHeaderTitle(forMode: initializationMode)
		verificationInfo = Strings.verificationInfo(forMode: initializationMode)
		verificationPlaceholder = Strings.verificationPlaceholder(forMode: initializationMode)
		primaryTitle = Strings.primaryTitle(forMode: initializationMode)
		resendVerificationButtonTitle = Strings.resendVerificationButtonTitle(forMode: initializationMode)
		userNeedsATokenButtonTitle = Strings.userNeedsATokenButtonTitle(forMode: initializationMode)
		confirmResendVerificationAlertTitle = Strings.confirmResendVerificationAlertTitle(forMode: initializationMode)
		confirmResendVerificationAlertMessage = Strings.confirmResendVerificationAlertMessage(forMode: initializationMode)
		confirmResendVerificationAlertOkayButton = Strings.confirmResendVerificationAlertOkayButton(forMode: initializationMode)
		confirmResendVerificationAlertCancelButton = Strings.confirmResendVerificationAlertCancelButton(forMode: initializationMode)
	}

	// MARK: - Static private functions

	/// Sanitize userInput of token & validation
	private func sanitize(_ input: String) -> String {

		return input.strippingWhitespace().uppercased()
	}
}

extension TokenEntryViewModel.InitializationMode {
	func calculateInputMode(
		tokenValidityIndicator: Bool?, // IF we've validated the token, then provide the result here.
		verificationCodeIsKnownToBeRequired: Bool,
		isInProgress: Bool,
		hasEverMadeFieldsVisible: Bool,
		screenHasCompleted: Bool
	) -> TokenEntryViewModel.InputMode {

		switch self {
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
			case .error:
				return .error
		}
	}
}

/// Mechanism for dynamically retrieving Strings depending on the `InitializationMode`:
extension TokenEntryViewModel {

	struct Strings {
		fileprivate static func title(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowTitle()
				case .error(serverError: let serverError):
					switch serverError {
						case let .error(_, _, error), let .provider(_, _, _, error):
							switch error {
								case .serverBusy:
									return L.generalNetworkwasbusyTitle()
								case .responseCached, .redirection, .resourceNotFound, .serverError, .invalidResponse,
									 .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
									return L.holderErrorstateTitle()
								default:
									break
							}
					}
					return ""
			}
		}

		fileprivate static func text(forMode initializationMode: InitializationMode, inputMode: InputMode) -> String? {
			switch (initializationMode, inputMode) {
				case (.error(serverError: let serverError), _):
					if case let .error(statusCode, serverResponse, error) = serverError {
						// this is an error fetching the providers
						switch error {
							case .serverBusy:
								return L.generalNetworkwasbusyText()
							case .responseCached, .redirection, .resourceNotFound, .serverError:
								let errorCode = ErrorCode(flow: .commercialTest, step: .providers, errorCode: "\(statusCode ?? 000)", detailedCode: serverResponse?.code)
								return L.holderErrorstateServerMessage("\(errorCode)")
							case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
								let errorCode = ErrorCode(flow: .commercialTest, step: .providers, errorCode: error.getClientErrorCode() ?? "000", detailedCode: serverResponse?.code)
								return L.holderErrorstateClientMessage("\(errorCode)")
							default:
								break
						}
					}
					if case let .provider(provider, statusCode, serverResponse, error) = serverError {
						// this is an error getting the test result.
						switch error {
							case .serverBusy:
								return L.generalNetworkwasbusyText()
							case .responseCached, .redirection, .resourceNotFound, .serverError:
								let errorCode = ErrorCode(flow: .commercialTest, step: .testResult, provider: provider, errorCode: "\(statusCode ?? 000)", detailedCode: serverResponse?.code)
								return L.holderErrorstateTestMessage("\(errorCode)")
							case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
								let errorCode = ErrorCode(flow: .commercialTest, step: .testResult, provider: provider, errorCode: error.getClientErrorCode() ?? "000", detailedCode: serverResponse?.code)
								return L.holderErrorstateTestMessage("\(errorCode)")
							default:
								break
						}
					}
					return ""
				case (_, .none):
					return nil
				case (.regular, _):
					return L.holderTokenentryRegularflowText()
				case (.withRequestTokenProvided, _):
					return L.holderTokenentryUniversallinkflowText()
			}
		}

		fileprivate static func userNeedsATokenButtonTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular, .withRequestTokenProvided:
					return L.holderTokenentryButtonNotoken()
				case .error:
					return L.holderErrorstateMalfunctionsTitle()
			}
		}

		fileprivate static func resendVerificationButtonTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowRetryTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowRetryTitle()
				case .error:
					return ""
			}
		}

		fileprivate static func errorInvalidCode(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowErrorInvalidCode()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowErrorInvalidCode()
				case .error:
					return ""
			}
		}

		fileprivate static func tokenEntryHeaderTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowTokenTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowTokenTitle()
				case .error:
					return ""
			}
		}

		fileprivate static func tokenEntryPlaceholder(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					if UIAccessibility.isVoiceOverRunning {
						return L.holderTokenentryRegularflowTokenPlaceholderScreenreader()
					} else {
						return L.holderTokenentryRegularflowTokenPlaceholder()
					}
				case .withRequestTokenProvided:
					if UIAccessibility.isVoiceOverRunning {
						return L.holderTokenentryUniversallinkflowTokenPlaceholderScreenreader()
					} else {
						return L.holderTokenentryUniversallinkflowTokenPlaceholder()
					}
				case .error:
					return ""
			}
		}

		fileprivate static func verificationEntryHeaderTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowVerificationTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowVerificationTitle()
				case .error:
					return ""
			}
		}

		fileprivate static func verificationInfo(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowVerificationInfo()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowVerificationInfo()
				case .error:
					return ""
			}
		}

		fileprivate static func verificationPlaceholder(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowVerificationPlaceholder()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowVerificationPlaceholder()
				case .error:
					return ""
			}
		}

		fileprivate static func primaryTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowNext()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowNext()
				case .error(serverError: let serverError):
					switch serverError {
						case let .error(_, _, error), let .provider(_, _, _, error):
							switch error {
								case .serverBusy:
									return L.generalNetworkwasbusyButton()
								case .responseCached, .redirection, .resourceNotFound, .serverError, .invalidResponse,
									 .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
									return L.holderErrorstateOverviewAction()
								default:
									break
							}
					}
					return ""
			}
		}

		// SMS Resend Verification Alert

		fileprivate static func confirmResendVerificationAlertTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertTitle()
				case .error:
					return ""
			}
		}

		fileprivate static func confirmResendVerificationAlertMessage(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertMessage()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertMessage()
				case .error:
					return ""
			}
		}

		fileprivate static func confirmResendVerificationAlertOkayButton(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertOkaybutton()
				case .error:
					return ""
			}
		}

		fileprivate static func confirmResendVerificationAlertCancelButton(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertCancelbutton()
				case .error:
					return ""
			}
		}
	}
}

extension TokenEntryViewModel: Logging {

	var loggingCategory: String {
		return "TokenEntryViewModel"
	}
}

/// Returns the `enabled` state to be used for `shouldEnableNextButton`
private func nextButtonEnabledState(allowEnablingOfNextButton: Bool, shouldShowProgress: Bool, screenHasCompleted: Bool) -> Bool {
	return allowEnablingOfNextButton && !shouldShowProgress && !screenHasCompleted
}

// MARK: - Error States

extension TokenEntryViewModel {

	private func displayNoInternet(_ requestToken: RequestToken, verificationCode: String?) {

		// this is a retry-able situation
		self.networkErrorAlert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in self?.fetchProviders(requestToken, verificationCode: verificationCode) },
			okTitle: L.generalRetry()
		)
	}

	private func displayServerUnreachable(_ requestToken: RequestToken, verificationCode: String?) {

		// this is a retry-able situation
		self.networkErrorAlert = AlertContent(
			title: L.holderErrorstateTitle(),
			subTitle: L.generalErrorServerUnreachable(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in self?.fetchProviders(requestToken, verificationCode: verificationCode) },
			okTitle: L.generalRetry()
		)
	}
}
