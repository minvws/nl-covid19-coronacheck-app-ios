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
					showTechnicalError("110, invalid DCC")
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
			default:
				logWarning("PaperCertificateCheckViewModel - Unhandled response: \(response.status)")
				showTechnicalError("110, unhandled status \(response.status)")
		}
	}

	private func handleError(serverError: ServerError, scannedDcc: String, couplingCode: String) {
		logError("CouplingManager validate: \(serverError)")
		
		if case let .error(statusCode, serverResponse, error) = serverError {
			switch error {
				case .serverBusy:
					showServerTooBusyError()
				case .noInternetConnection, .requestTimedOut:
					showNoInternet(scannedDcc: scannedDcc, couplingCode: couplingCode)
				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(flow: .hkvi, step: .coupling, errorCode: "\(statusCode ?? 000)", detailedCode: serverResponse?.code)
					displayErrorCode(errorCode)
				case .invalidRequest, .invalidSignature:

					break
				case .cannotSerialize:
					 let errorCode = ErrorCode(flow: .hkvi, step: .coupling, errorCode: "031")
					displayErrorCode(errorCode)
				case .cannotDeserialize:
					let errorCode = ErrorCode(flow: .hkvi, step: .coupling, errorCode: "030")
					displayErrorCode(errorCode)

				default:
					let errorCode = ErrorCode(flow: .hkvi, step: .coupling, errorCode: "\(statusCode ?? 000)", detailedCode: serverResponse?.code)
					displayErrorCode(errorCode)
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

	private func displayErrorCode(_ errorCode: ErrorCode) {

		viewState = .feedback(
			content: PaperCertificateCheckViewController.Content(
				title: L.holderEventErrorTitle(),
				subTitle: L.holderEventErrorMessage("\(errorCode)"),
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: {[weak self] in
					self?.coordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: L.holderEventMalfunctionsTitle(),
				secondaryAction: { [weak self] in
					guard let url = URL(string: L.holderEventMalfunctionsUrl()) else {
						return
					}

					self?.coordinator?.openUrl(url, inApp: true)
				}
			)
		)
	}

	private func showTechnicalError(_ customCode: String?) {

		var subTitle = L.generalErrorTechnicalText()
		if let code = customCode {
			subTitle = L.generalErrorTechnicalCustom(code)
		}
		alert = AlertContent(
			title: L.generalErrorTitle(),
			subTitle: subTitle,
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { [weak self] _ in self?.coordinator?.userWantsToGoBackToDashboard() },
			okTitle: L.generalClose()
		)
	}
}
