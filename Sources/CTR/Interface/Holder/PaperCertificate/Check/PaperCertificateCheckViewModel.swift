/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class PaperCertificateCheckViewModel: Logging {

	weak var coordinator: (PaperCertificateCoordinatorDelegate & OpenUrlProtocol)?

	private let couplingManager: CouplingManaging

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: PaperCertificateCheckViewController.State

	@Bindable internal var shouldPrimaryButtonBeEnabled: Bool = true

	@Bindable private(set) var alert: AlertContent?

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: (PaperCertificateCoordinatorDelegate & OpenUrlProtocol),
		scannedDcc: String,
		couplingCode: String,
		couplingManager: CouplingManaging = Services.couplingManager
	) {

		self.coordinator = coordinator
		self.couplingManager = couplingManager

		viewState = .loading(
			content: PaperCertificateCheckViewController.Content(
				title: L.holderDccListTitle(),
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)

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
			case .accepted:
				if let wrapper = couplingManager.convert(scannedDcc, couplingCode: couplingCode) {
					let remoteEvent = RemoteEvent(wrapper: wrapper, signedResponse: nil)
					coordinator?.userWishesToSeeScannedEvent(remoteEvent)
				} else {
					let errorCode = ErrorCode(flow: .hkvi, step: .coupling, clientCode: .failedToConvertDCCToV3Event)
					displayClientErrorCode(errorCode)
				}
			case .blocked:
				viewState = .feedback(
					content: PaperCertificateCheckViewController.Content(
						title: L.holderCheckdccBlockedTitle(),
						subTitle: L.holderCheckdccBlockedMessage(),
						primaryActionTitle: L.holderCheckdccBlockedActionTitle(),
						primaryAction: { [weak self] in
							self?.coordinator?.userWantsToGoBackToDashboard()
						},
						secondaryActionTitle: nil,
						secondaryAction: nil
					)
				)
			case .expired:
				viewState = .feedback(
					content: PaperCertificateCheckViewController.Content(
						title: L.holderCheckdccExpiredTitle(),
						subTitle: L.holderCheckdccExpiredMessage(),
						primaryActionTitle: L.holderCheckdccExpiredActionTitle(),
						primaryAction: { [weak self] in
							self?.coordinator?.userWantsToGoBackToDashboard()
						},
						secondaryActionTitle: nil,
						secondaryAction: nil
					)
				)

			case .rejected:
				viewState = .feedback(
					content: PaperCertificateCheckViewController.Content(
						title: L.holderCheckdccRejectedTitle(),
						subTitle: L.holderCheckdccRejectedMessage(),
						primaryActionTitle: L.holderCheckdccRejectedActionTitle(),
						primaryAction: {[weak self] in
							self?.coordinator?.userWantsToGoBackToTokenEntry()
						},
						secondaryActionTitle: nil,
						secondaryAction: nil
					)
				)
		}
	}

	private func handleError(serverError: ServerError, scannedDcc: String, couplingCode: String) {
		logError("CouplingManager handleError: \(serverError)")
		
		if case let .error(statusCode, serverResponse, error) = serverError {
			switch error {
				case .serverBusy:
					showServerTooBusyError()
				case .noInternetConnection, .requestTimedOut:
					showNoInternet(scannedDcc: scannedDcc, couplingCode: couplingCode)
				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(flow: .hkvi, step: .coupling, errorCode: "\(statusCode ?? 000)", detailedCode: serverResponse?.code)
					displayServerErrorCode(errorCode)
				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
					// Client side
					let errorCode = ErrorCode(flow: .hkvi, step: .coupling, errorCode: error.getClientErrorCode() ?? "000", detailedCode: serverResponse?.code)
					displayClientErrorCode(errorCode)
			}
		}
	}

	// MARK: Errors

	private func showServerTooBusyError() {

		viewState = .feedback(
			content: PaperCertificateCheckViewController.Content(
				title: L.generalNetworkwasbusyTitle(),
				subTitle: L.generalNetworkwasbusyText(),
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: {[weak self] in
					self?.coordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func showNoInternet(scannedDcc: String, couplingCode: String) {

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

	private func displayServerErrorCode(_ errorCode: ErrorCode) {

		viewState = .feedback(
			content: PaperCertificateCheckViewController.Content(
				title: L.holderErrorstateTitle(),
				subTitle: L.holderErrorstateServerMessage("\(errorCode)"),
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: {[weak self] in
					self?.coordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
				secondaryAction: { [weak self] in
					guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
						return
					}

					self?.coordinator?.openUrl(url, inApp: true)
				}
			)
		)
	}

	private func displayClientErrorCode(_ errorCode: ErrorCode) {

		viewState = .feedback(
			content: PaperCertificateCheckViewController.Content(
				title: L.holderErrorstateTitle(),
				subTitle: L.holderErrorstateClientMessage("\(errorCode)"),
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: {[weak self] in
					self?.coordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
				secondaryAction: { [weak self] in
					guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
						return
					}

					self?.coordinator?.openUrl(url, inApp: true)
				}
			)
		)
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let failedToConvertDCCToV3Event = ErrorCode.ClientCode(value: "052")
}
