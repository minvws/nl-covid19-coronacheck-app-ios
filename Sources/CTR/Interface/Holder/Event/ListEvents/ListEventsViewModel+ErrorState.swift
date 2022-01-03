/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListEventsViewModel {

	// MARK: Errors

	internal func showIdentityMismatch(onReplace: @escaping () -> Void) {

		alert = AlertContent(
			title: L.holderEventIdentityAlertTitle(),
			subTitle: L.holderEventIdentityAlertMessage(),
			cancelAction: { [weak self] _ in
				self?.coordinator?.listEventsScreenDidFinish(.stop)
			},
			cancelTitle: L.holderEventIdentityAlertCancel(),
			okAction: { _ in
				onReplace()
			},
			okTitle: L.holderEventIdentityAlertOk(),
			okActionIsDestructive: true,
			okActionIsPreferred: true
		)
	}

	internal func showEventError(remoteEvents: [RemoteEvent]) {

		alert = AlertContent(
			title: L.generalErrorTitle(),
			subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationErrorClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
					if !success {
						self?.showEventError(remoteEvents: remoteEvents)
					}
				}
			},
			okTitle: L.holderVaccinationErrorAgain(),
			okActionIsPreferred: true
		)
	}

	internal func showServerTooBusyError(errorCode: ErrorCode) {

		let content = Content(
			title: L.generalNetworkwasbusyTitle(),
			subTitle: L.generalNetworkwasbusyErrorcode("\(errorCode)"),
			primaryActionTitle: L.generalNetworkwasbusyButton(),
			primaryAction: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(.stop)
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)

		coordinator?.listEventsScreenDidFinish(.error(content: content, backAction: goBack))
	}

	internal func showNoInternet(remoteEvents: [RemoteEvent]) {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
					if !success {
						self?.showEventError(remoteEvents: remoteEvents)
					}
				}
			},
			okTitle: L.generalRetry(),
			okActionIsPreferred: true
		)
	}

	internal func showServerUnreachable(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.generalErrorServerUnreachableErrorCode("\(errorCode)"))
	}

	internal func displayClientErrorCode(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateClientMessage("\(errorCode)"))
	}

	internal func displayServerErrorCode(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateServerMessage("\(errorCode)"))
	}

	private func displayErrorCode(title: String, message: String) {

		let content = Content(
			title: title,
			subTitle: message,
			primaryActionTitle: L.generalNetworkwasbusyButton(),
			primaryAction: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(.stop)
			},
			secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
			secondaryAction: { [weak self] in
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
					return
				}

				self?.coordinator?.openUrl(url, inApp: true)
			}
		)
		coordinator?.listEventsScreenDidFinish(.error(content: content, backAction: goBack))
	}

	func determineErrorCodeFlow(remoteEvents: [RemoteEvent]) -> ErrorCode.Flow {

		switch eventMode {
			case .vaccinationassessment: return ErrorCode.Flow.visitorPass
			case .vaccination: return ErrorCode.Flow.vaccination
			case .paperflow: return ErrorCode.Flow.hkvi
			case .positiveTest: return ErrorCode.Flow.positiveTest
			case .recovery: return ErrorCode.Flow.recovery
			case .test:

				if let identifier = remoteEvents.first?.wrapper.providerIdentifier {
					if identifier.lowercased() == "ggd" {
						return .ggdTest
					} else {
						return.commercialTest
					}
				}
				return ErrorCode.Flow(value: "")
		}
	}

	func determineErrorCodeProvider(remoteEvents: [RemoteEvent]) -> String? {

		var identifiers = [String]()
		remoteEvents.forEach { remoteEvent in
			if !identifiers.contains(remoteEvent.wrapper.providerIdentifier) {
				identifiers.append(remoteEvent.wrapper.providerIdentifier)
			}
		}
		if identifiers.count == 1 {
			return identifiers.first
		} else {
			return nil
		}
	}

	func displaySomeResultsMightBeMissing() {

		alert = AlertContent(
			title: L.holderErrorstateSomeresultTitle(),
			subTitle: L.holderErrorstateSomeresultMessage(),
			okAction: nil,
			okTitle: L.generalOk()
		)
	}
}
