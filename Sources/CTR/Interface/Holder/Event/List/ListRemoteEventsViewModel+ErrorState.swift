/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import ReusableViews
import Resources

extension ListRemoteEventsViewModel {

	// MARK: Errors

	internal func showIdentityMismatch(onReplace: @escaping () -> Void) {

		alert = AlertContent(
			title: L.holderEventIdentityAlertTitle(),
			subTitle: L.holderEventIdentityAlertMessage(),
			okAction: AlertContent.Action(
				title: L.holderEventIdentityAlertOk(),
				action: { _ in
					onReplace()
				},
				isDestructive: true,
				isPreferred: true
				
			),
			cancelAction: AlertContent.Action(
				title: L.holderEventIdentityAlertCancel(),
				action: { [weak self] _ in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				}
			)
		)
	}

	internal func showEventError() {

		alert = AlertContent(
			title: L.generalErrorTitle(),
			subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
			okAction: AlertContent.Action(
				title: L.holderVaccinationErrorAgain(),
				action: { [weak self] _ in
					self?.userWantsToMakeQR()
				},
				isPreferred: true
				
			),
			cancelAction: AlertContent.Action(
				title: L.holderVaccinationErrorClose()
			)
		)
	}

	internal func showNoInternet() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			okAction: AlertContent.Action(
				title: L.generalRetry(),
				action: { [weak self] _ in
					self?.userWantsToMakeQR()
				},
				isPreferred: true
			),
			cancelAction: AlertContent.Action(
				title: L.generalClose()
			)
		)
	}
	
	internal func handleStorageError() {
		
		let errorCode = ErrorCode(flow: eventMode.flow, step: .storingEvents, clientCode: .storingEvents)
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

	func displaySomeResultsMightBeMissing() {

		alert = AlertContent(
			title: L.holderErrorstateSomeresultTitle(),
			subTitle: L.holderErrorstateSomeresultMessage(),
			okAction: AlertContent.Action.okay
		)
	}
}
