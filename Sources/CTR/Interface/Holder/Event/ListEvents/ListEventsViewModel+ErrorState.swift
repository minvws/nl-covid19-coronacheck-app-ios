/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListEventsViewModel {

	internal func displayClientErrorCode(_ errorCode: ErrorCode) -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: L.holderErrorstateTitle(),
				subTitle: L.holderErrorstateClientMessage("\(errorCode)"),
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
		)
	}

	internal func displayServerErrorCode(_ errorCode: ErrorCode) -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: L.holderErrorstateTitle(),
				subTitle: L.holderErrorstateServerMessage("\(errorCode)"),
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
		)
	}

	func determineErrorCodeFlow(remoteEvents: [RemoteEvent]) -> ErrorCode.Flow {

		switch eventMode {
			case .vaccination:
				return ErrorCode.Flow.vaccination
			case .paperflow:
				return ErrorCode.Flow.hkvi
			case .recovery:
				return ErrorCode.Flow.recovery
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
}
