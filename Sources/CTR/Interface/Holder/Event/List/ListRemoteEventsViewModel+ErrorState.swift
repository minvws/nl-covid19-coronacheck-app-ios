/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListRemoteEventsViewModel {

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

	internal func showEventError() {

		alert = AlertContent(
			title: L.generalErrorTitle(),
			subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationErrorClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR()
			},
			okTitle: L.holderVaccinationErrorAgain(),
			okActionIsPreferred: true
		)
	}

	internal func showNoInternet() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR()
			},
			okTitle: L.generalRetry(),
			okActionIsPreferred: true
		)
	}
	
	internal func handleStorageError() {
		
		let errorCode = ErrorCode(flow: determineErrorCodeFlow(), step: .storingEvents, clientCode: .storingEvents)
		displayError(title: L.holderErrorstateTitle(), message: L.holderErrorstateClientMessage("\(errorCode)"))
	}
	
	internal func displayError(title: String, message: String) {
		
		let content = Content(
			title: title,
			body: message,
			primaryActionTitle: L.general_toMyOverview(),
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

	func determineErrorCodeFlow() -> ErrorCode.Flow {

		switch eventMode {
			case .vaccinationassessment: return ErrorCode.Flow.visitorPass
			case .vaccination: return ErrorCode.Flow.vaccination
			case .paperflow: return ErrorCode.Flow.paperproof
			case .vaccinationAndPositiveTest: return ErrorCode.Flow.vaccinationAndPositiveTest
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

	func displaySomeResultsMightBeMissing() {

		alert = AlertContent(
			title: L.holderErrorstateSomeresultTitle(),
			subTitle: L.holderErrorstateSomeresultMessage(),
			okAction: nil,
			okTitle: L.generalOk()
		)
	}
}
