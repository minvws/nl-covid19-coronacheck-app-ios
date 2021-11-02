/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

final class ExtendRecoveryValidityViewModel: Logging {

	enum Mode {
		case extend
		case reinstate
	}

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var isLoading: Bool = false
	@Bindable private(set) var alert: AlertContent?

	weak var coordinator: HolderCoordinatorDelegate?

	private let mode: Mode
	private var backbuttonAction: () -> Void
	private let greencardLoader: GreenCardLoading
	private let userSettings: UserSettingsProtocol
	
	init(mode: Mode, backAction: @escaping () -> Void, greencardLoader: GreenCardLoading, userSettings: UserSettingsProtocol) {
		self.mode = mode
		self.greencardLoader = greencardLoader
		self.userSettings = userSettings
        
        switch mode {
            case .extend:
                self.title = L.holderRecoveryvalidityextensionExtensionavailableTitle()
                self.message = L.holderRecoveryvalidityextensionExtensionavailableDescription()
                self.primaryButtonTitle = L.holderRecoveryvalidityextensionExtensionavailableButtonSubmit()
            case .reinstate:
                self.title = L.holderRecoveryvalidityextensionReinstationavailableTitle()
                self.message = L.holderRecoveryvalidityextensionReinstationavailableDescription()
                self.primaryButtonTitle = L.holderRecoveryvalidityextensionReinstationavailableButtonSubmit()
        }
		self.backbuttonAction = backAction
	}

	func primaryButtonTapped() {
		load()
	}

	func backButtonTapped() {
		backbuttonAction()
	}

	private func load() {
		guard !isLoading else { return }
		isLoading = true

		greencardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: nil) { [weak self] result in
			guard let self = self else { return }
			self.isLoading = false
			self.handleGreenCardResult(result, onSuccess: {
				self.coordinator?.extendRecoveryValidityDidComplete()
			})
		}
	}

	private func handleGreenCardResult(
		_ result: Result<Void, Error>,
		onSuccess: @escaping () -> Void) {

			switch result {
				case .success:
					// Call back to the coordinator to dismiss this view
					onSuccess()

				case .failure(GreenCardLoader.Error.failedToParsePrepareIssue):
					self.handleClientSideError(clientCode: .failedToParsePrepareIssue, for: .nonce)

				case .failure(GreenCardLoader.Error.preparingIssue(let serverError)):
					self.handleServerError(serverError, for: .nonce)

				case .failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage):
					self.handleClientSideError(clientCode: .failedToGenerateCommitmentMessage, for: .nonce)

				case .failure(GreenCardLoader.Error.credentials(let serverError)):
					self.handleServerError(serverError, for: .signer)

				case .failure(GreenCardLoader.Error.failedToSaveGreenCards):
					self.handleClientSideError(clientCode: .failedToSaveGreenCards, for: .storingCredentials)

				case .failure(let error):
					self.logError("upgradeEUVaccinationViewModel - unhandled: \(error)")
					fallthrough

				default:
					self.handleClientSideError(clientCode: .unhandled, for: .signer) // todo: `for: .signer` is this right?
			}
		}
}

// Future: there is a ticket to deduplicate this as it is taken from ListEventsViewModel.
// Taiga task: 2072

extension ExtendRecoveryValidityViewModel {

	// MARK: Errors

	func handleClientSideError(clientCode: ErrorCode.ClientCode, for step: ErrorCode.Step) {

		let errorCode = ErrorCode(
			flow: .upgradeEUVaccination,
			step: step,
			errorCode: clientCode.value
		)
		logDebug("errorCode: \(errorCode)")
		displayClientErrorCode(errorCode)
	}

	func handleServerError(_ serverError: ServerError, for step: ErrorCode.Step) {

		if case let ServerError.error(statusCode, serverResponse, error) = serverError {
			self.logDebug("handleServerError \(serverError)")

			switch error {
				case .serverBusy:
					displayServerTooBusyError(errorCode: ErrorCode(flow: .upgradeEUVaccination, step: step, errorCode: "429"))

				case .serverUnreachableTimedOut, .serverUnreachableInvalidHost, .serverUnreachableConnectionLost:
					displayServerUnreachable(ErrorCode(flow: .upgradeEUVaccination, step: step, clientCode: error.getClientErrorCode() ?? .unhandled))

				case .noInternetConnection:
					presentNoInternet()

				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(
						flow: .upgradeEUVaccination,
						step: step,
						errorCode: "\(statusCode ?? 000)",
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					displayServerErrorCode(errorCode)

				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
					// Client side
					let errorCode = ErrorCode(
						flow: .upgradeEUVaccination,
						step: step,
						clientCode: error.getClientErrorCode() ?? .unhandled,
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					displayClientErrorCode(errorCode)
			}
		}
	}

	// MARK: - Presenting Error dialogs

	fileprivate func presentNoInternet() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				self?.load()
			},
			okTitle: L.generalRetry()
		)
	}

	// MARK: - Navigating to Error screens

	fileprivate func displayServerTooBusyError(errorCode: ErrorCode) {

		let content = Content(
			title: L.generalNetworkwasbusyTitle(),
			subTitle: L.generalNetworkwasbusyErrorcode("\(errorCode)"),
			primaryActionTitle: L.generalNetworkwasbusyButton(),
			primaryAction: { [weak self] in
				self?.coordinator?.navigateBackToStart()
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)

		coordinator?.displayError(content: content, backAction: { self.coordinator?.navigateBackToStart() })
	}

	fileprivate func displayServerUnreachable(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.generalErrorServerUnreachableErrorCode("\(errorCode)"))
	}

	fileprivate func displayClientErrorCode(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateClientMessage("\(errorCode)"))
	}

	fileprivate func displayServerErrorCode(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateServerMessage("\(errorCode)"))
	}

	private func displayErrorCode(title: String, message: String) {

		let content = Content(
			title: title,
			subTitle: message,
			primaryActionTitle: L.generalNetworkwasbusyButton(),
			primaryAction: { [weak self] in
				self?.coordinator?.navigateBackToStart()
			},
			secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
			secondaryAction: { [weak self] in
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
					return
				}

				self?.coordinator?.openUrl(url, inApp: true)
			}
		)
		coordinator?.displayError(content: content, backAction: {
			self.coordinator?.navigateBackToStart()
		})
	}
}
