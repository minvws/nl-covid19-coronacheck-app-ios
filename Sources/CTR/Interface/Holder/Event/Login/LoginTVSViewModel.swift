/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AppAuth

class LoginTVSViewModel {

	private weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?
	private weak var openIdManager: OpenIdManaging? = Current.openIdManager

	private var eventMode: EventMode

	private var title: String
	
	private var appAuthState: AppAuthState?

	@Bindable internal var content: Content

	@Bindable private(set) var shouldShowProgress: Bool = false

	init(
		coordinator: (EventCoordinatorDelegate & OpenUrlProtocol),
		eventMode: EventMode,
		appAuthState: AppAuthState? = UIApplication.shared.delegate as? AppAuthState) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.appAuthState = appAuthState

		self.title = L.holder_fetchRemoteEvents_title()
		content = Content(title: L.holder_fetchRemoteEvents_title())
	}

	func cancel() {

		self.coordinator?.loginTVSScreenDidFinish(.back(eventMode: eventMode))
	}
	
	private class TVSConfig: IssuerConfiguration {
		func getIssuerURL() -> URL {
			return Configuration().getTVSURL()
		}
		
		func getClientId() -> String {
			return Configuration().getConsumerId()
		}
		
		func getRedirectUri() -> URL {
			return Configuration().getRedirectUri()
		}
	}

	/// Login at the GGD
	func login() {

		shouldShowProgress = true
		content = Content(
			title: title,
			body: nil,
			primaryActionTitle: L.generalClose(),
			primaryAction: { [weak self] in
				self?.cancel()
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)

		openIdManager?.requestAccessToken(issuerConfiguration: TVSConfig(), presentingViewController: nil) { tvsToken in

			self.shouldShowProgress = false
			
			guard let idToken = tvsToken.idToken else {
				self.handleError(NSError(domain: OIDOAuthTokenErrorDomain, code: OIDErrorCode.idTokenParsingError.rawValue))
				return
			}

			self.coordinator?.loginTVSScreenDidFinish(.didLogin(token: idToken, eventMode: self.eventMode))
		} onError: { error in
			self.shouldShowProgress = false
			self.handleError(error)
		}
	}
}

// MARK: Error States

extension LoginTVSViewModel {

	func handleError(_ error: Error?) {

		Current.logHandler.logError("TVS error: \(error?.localizedDescription ?? "Unknown error")")
		let clientCode = OpenIdErrorMapper().mapError(error)

		if let error = error {
			if  error.localizedDescription.contains("login_required") {
				Current.logHandler.logDebug("Server busy")
				displayServerBusy(
					errorCode: ErrorCode(
						flow: eventMode.flow,
						step: .tvs,
						errorCode: "429"
					)
				)
				return
			} else if error.localizedDescription.contains("saml_authn_failed") || clientCode == ErrorCode.ClientCode.openIDGeneralUserCancelledFlow {
				Current.logHandler.logDebug("User cancelled")
				userCancelled()
				return
			} else if case let ServerError.error(_, _, networkError) = error {
				switch networkError {
					case .serverUnreachableTimedOut, .serverUnreachableConnectionLost, .serverUnreachableInvalidHost:

						let errorCode = ErrorCode(
							flow: eventMode.flow,
							step: .tvs,
							clientCode: networkError.getClientErrorCode() ?? .unhandled
						)
						self.displayUnreachable(errorCode: errorCode)
						return
					default:
						break
				}
			}
		}

		let errorCode = ErrorCode(
			flow: eventMode.flow,
			step: .tvs,
			clientCode: clientCode ?? ErrorCode.ClientCode(value: "000")
		)
		self.displayErrorCode(errorCode: errorCode)
	}

	func userCancelled() {

		self.coordinator?.loginTVSScreenDidFinish(.errorRequiringRestart(eventMode: self.eventMode))
	}
	
	func cancelAuthorization() {
		
		guard appAuthState?.currentAuthorizationFlow != nil else { return }
		
		coordinator?.loginTVSScreenDidFinish(.errorRequiringRestart(eventMode: self.eventMode))
	}

	func displayErrorCode(errorCode: ErrorCode) {

		displayError(
			title: L.holderErrorstateTitle(),
			subTitle: L.holderErrorstateClientMessage("\(errorCode)"),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	func displayServerBusy(errorCode: ErrorCode) {

		let content = Content(
			title: L.generalNetworkwasbusyTitle(),
			body: L.generalNetworkwasbusyErrorcode("\(errorCode)"),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: { [weak self] in
				self?.coordinator?.loginTVSScreenDidFinish(.stop)
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		self.coordinator?.loginTVSScreenDidFinish(.error(content: content, backAction: cancel))
	}

	func displayUnreachable(errorCode: ErrorCode) {

		displayError(
			title: L.holderErrorstateTitle(),
			subTitle: L.generalErrorServerUnreachableErrorCode("\(errorCode)"),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	private func displayError(title: String, subTitle: String, primaryActionTitle: String) {

		let content = Content(
			title: title,
			body: subTitle,
			primaryActionTitle: primaryActionTitle,
			primaryAction: { [weak self] in
				self?.coordinator?.loginTVSScreenDidFinish(.stop)
			},
			secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
			secondaryAction: { [weak self] in
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
					return
				}

				self?.coordinator?.openUrl(url, inApp: true)
			}
		)
		self.coordinator?.loginTVSScreenDidFinish(.error(content: content, backAction: cancel))
	}
}
