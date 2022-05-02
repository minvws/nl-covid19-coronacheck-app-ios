/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class PaperProofCheckViewModel: Logging {

	weak var coordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol & Dismissable)?

	private let couplingManager: CouplingManaging = Current.couplingManager

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: PaperProofCheckViewController.State

	@Bindable internal var shouldPrimaryButtonBeEnabled: Bool = true

	@Bindable private(set) var alert: AlertContent?

	init(
		coordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol & Dismissable),
		scannedDcc: String,
		couplingCode: String
	) {

		self.coordinator = coordinator

		viewState = .loading(content: Content(title: L.holder_listRemoteEvents_paperflow_title()))
		checkCouplingCode(scannedDcc: scannedDcc, couplingCode: couplingCode)
	}

	// MARK: Check Coupling Code

	private func checkCouplingCode(scannedDcc: String, couplingCode: String) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		// Validate coupling code
		couplingManager.checkCouplingStatus(dcc: scannedDcc, couplingCode: couplingCode) { [weak self] result in
			// result = Result<DccCoupling.CouplingResponse, ServerError>
			self?.progressIndicationCounter.decrement()
			self?.shouldPrimaryButtonBeEnabled = true
			switch result {
				case let .success(response):
					self?.handleSuccess(response: response, scannedDcc: scannedDcc, couplingCode: couplingCode)
				case let .failure(error):
					self?.handleError(serverError: error, scannedDcc: scannedDcc, couplingCode: couplingCode)
			}
		}
	}

	private func handleSuccess(response: DccCoupling.CouplingResponse, scannedDcc: String, couplingCode: String) {

		switch response.status {
			case .accepted: handleAccepted(scannedDcc: scannedDcc, couplingCode: couplingCode)
			case .blocked: handleBlocked()
			case .expired: handleExpired()
			case .rejected, .unknown: handleRejected()
		}
	}

	private func handleAccepted(scannedDcc: String, couplingCode: String) {

		if let wrapper = couplingManager.convert(scannedDcc, couplingCode: couplingCode) {
			let remoteEvent = RemoteEvent(wrapper: wrapper, signedResponse: nil)
			coordinator?.userWishesToSeeScannedEvent(remoteEvent)
		} else {
			let errorCode = ErrorCode(flow: .paperproof, step: .coupling, clientCode: .failedToConvertDCCToV3Event)
			displayErrorCode(subTitle: L.holderErrorstateClientMessage("\(errorCode)"))
		}
	}

	private func handleBlocked() {

		viewState = .feedback(
			content: Content(
				title: L.holderCheckdccBlockedTitle(),
				body: L.holderCheckdccBlockedMessage(),
				primaryActionTitle: L.general_toMyOverview(),
				primaryAction: { [weak self] in
					self?.coordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func handleExpired() {

		viewState = .feedback(
			content: Content(
				title: L.holderCheckdccExpiredTitle(),
				body: L.holderCheckdccExpiredMessage(),
				primaryActionTitle: L.general_toMyOverview(),
				primaryAction: { [weak self] in
					self?.coordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func handleRejected() {

		viewState = .feedback(
			content: Content(
				title: L.holderCheckdccRejectedTitle(),
				body: L.holderCheckdccRejectedMessage(),
				primaryActionTitle: L.holderCheckdccRejectedActionTitle(),
				primaryAction: {[weak self] in
					self?.coordinator?.dismiss()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func handleError(serverError: ServerError, scannedDcc: String, couplingCode: String) {
		logError("CouplingManager handleError: \(serverError)")
		
		if case let .error(statusCode, serverResponse, error) = serverError {
			switch error {
				case .serverBusy:
					showServerTooBusyError(ErrorCode(flow: .paperproof, step: .coupling, errorCode: "429"))
				case .noInternetConnection:
					displayNoInternet(scannedDcc: scannedDcc, couplingCode: couplingCode)
				case .serverUnreachableTimedOut, .serverUnreachableInvalidHost, .serverUnreachableConnectionLost:
					let errorCode = ErrorCode(flow: .paperproof, step: .coupling, clientCode: error.getClientErrorCode() ?? .unhandled)
					displayErrorCode(subTitle: L.generalErrorServerUnreachableErrorCode("\(errorCode)"))
				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(flow: .paperproof, step: .coupling, errorCode: "\(statusCode ?? 000)", detailedCode: serverResponse?.code)
					displayErrorCode(subTitle: L.holderErrorstateServerMessage("\(errorCode)"))
				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize, .authenticationCancelled:
					// Client side
					let errorCode = ErrorCode(flow: .paperproof, step: .coupling, clientCode: error.getClientErrorCode() ?? .unhandled, detailedCode: serverResponse?.code)
					displayErrorCode(subTitle: L.holderErrorstateClientMessage("\(errorCode)"))
			}
		}
	}

	// MARK: Errors

	private func showServerTooBusyError(_ errorCode: ErrorCode) {

		let content = Content(
			title: L.generalNetworkwasbusyTitle(),
			body: L.generalNetworkwasbusyErrorcode("\(errorCode)"),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: {[weak self] in
				self?.coordinator?.userWantsToGoBackToDashboard()
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + (ProcessInfo().isUnitTesting ? 0 : 0.5)) {
			self.coordinator?.displayError(content: content) { [weak self] in
				self?.coordinator?.userWantsToGoBackToEnterToken()
			}
		}
	}

	private func displayNoInternet(scannedDcc: String, couplingCode: String) {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: { [weak self] _ in self?.coordinator?.userWantsToGoBackToDashboard() },
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in self?.checkCouplingCode(scannedDcc: scannedDcc, couplingCode: couplingCode) },
			okTitle: L.holderVaccinationErrorAgain()
		)
	}

	private func displayErrorCode(subTitle: String) {

		let content = Content(
			title: L.holderErrorstateTitle(),
			body: subTitle,
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: {[weak self] in
				self?.coordinator?.userWantsToGoBackToDashboard()
			},
			secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
			secondaryAction: { [weak self] in
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else { return }
				self?.coordinator?.openUrl(url, inApp: true)
			}
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + (ProcessInfo().isUnitTesting ? 0 : 0.5)) {
			self.coordinator?.displayError(content: content) { [weak self] in
				self?.coordinator?.userWantsToGoBackToEnterToken()
			}
		}
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let failedToConvertDCCToV3Event = ErrorCode.ClientCode(value: "052")
}
