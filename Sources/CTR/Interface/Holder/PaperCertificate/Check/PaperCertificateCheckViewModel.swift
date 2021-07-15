/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class PaperCertificateCheckViewModel: Logging {

	weak var coordinator: PaperCertificateCoordinatorDelegate?

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

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: PaperCertificateCoordinatorDelegate,
		scannedDcc: String? = nil,
		couplingCode: String? = nil,
		couplingManager: CouplingManaging = Services.couplingManager
	) {

		self.coordinator = coordinator
		self.couplingManager = couplingManager

		viewState = .loading(
			content: PaperCertificateCheckViewController.Content(
				title: L.holderDccListTitle(),
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil
			)
		)

		checkCouplingCode(scannedDcc: scannedDcc, couplingCode: couplingCode)
	}

	// MARK: Check Coupling Code

	private func checkCouplingCode(scannedDcc: String?, couplingCode: String?) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		if let dcc = scannedDcc, let couplingCode = couplingCode {
			// Validate coupling code
			couplingManager.checkCouplingStatus(dcc: dcc, couplingCode: couplingCode) { [weak self] result in
				// result = Result<DccCoupling.CouplingResponse, NetworkError>
				self?.progressIndicationCounter.decrement()
				self?.shouldPrimaryButtonBeEnabled = true
				switch result {
					case let .success(response):
						self?.handleSuccess(response: response, scannedDcc: dcc, couplingCode: couplingCode)
					case let .failure(error):
						self?.logError("CouplingManager validate: \(error)")
				}
			}
		}
	}

	private func handleSuccess(response: DccCoupling.CouplingResponse, scannedDcc: String, couplingCode: String) {

		logDebug("handleSuccess: \(response)")

		switch response.status {
			case .accepted:
				if let wrapper = couplingManager.convert(scannedDcc, couplingCode: couplingCode) {
					let remoteEvent = RemoteEvent(wrapper: wrapper, signedResponse: nil)
					logInfo("Todo: Pass \(remoteEvent) to list Events")
				}
			case .blocked:
				viewState = .feedback(
					content: PaperCertificateCheckViewController.Content(
						title: L.holderCheckdccBlockedTitle(),
						subTitle: L.holderCheckdccBlockedMessage(),
						primaryActionTitle: L.holderCheckdccBlockedActionTitle(),
						primaryAction: { [weak self] in
							self?.coordinator?.userWantsToGoBackToDashboard()
						}
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
						}
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
						}
					)
				)
			default:
				break
		}
	}

//
//	// MARK: Errors
//
//	internal func showEventError(remoteEvents: [RemoteEvent]) {
//
//		alert = ListEventsViewController.AlertContent(
//			title: L.generalErrorTitle(),
//			subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
//			cancelAction: nil,
//			cancelTitle: L.holderVaccinationErrorClose(),
//			okAction: { [weak self] _ in
//				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
//					if !success {
//						self?.showEventError(remoteEvents: remoteEvents)
//					}
//				}
//			},
//			okTitle: L.holderVaccinationErrorAgain()
//		)
//	}
//
//	private func showServerTooBusyError() {
//
//		alert = ListEventsViewController.AlertContent(
//			title: L.generalNetworkwasbusyTitle(),
//			subTitle: L.generalNetworkwasbusyText(),
//			cancelAction: nil,
//			cancelTitle: nil,
//			okAction: { [weak self] _ in
//				self?.coordinator?.listEventsScreenDidFinish(.stop)
//			},
//			okTitle: L.generalNetworkwasbusyButton()
//		)
//	}
//
//	private func showNoInternet(remoteEvents: [RemoteEvent]) {
//
//		// this is a retry-able situation
//		alert = ListEventsViewController.AlertContent(
//			title: L.generalErrorNointernetTitle(),
//			subTitle: L.generalErrorNointernetText(),
//			cancelAction: nil,
//			cancelTitle: L.generalClose(),
//			okAction: { [weak self] _ in
//				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
//					if !success {
//						self?.showEventError(remoteEvents: remoteEvents)
//					}
//				}
//			},
//			okTitle: L.holderVaccinationErrorAgain()
//		)
//	}
//
//	private func showTechnicalError(_ customCode: String?) {
//
//		var subTitle = L.generalErrorTechnicalText()
//		if let code = customCode {
//			subTitle = L.generalErrorTechnicalCustom(code)
//		}
//		alert = ListEventsViewController.AlertContent(
//			title: L.generalErrorTitle(),
//			subTitle: subTitle,
//			cancelAction: nil,
//			cancelTitle: nil,
//			okAction: { _ in
//				self.coordinator?.listEventsScreenDidFinish(.back(eventMode: self.eventMode))
//			},
//			okTitle: L.generalClose()
//		)
//	}
}
