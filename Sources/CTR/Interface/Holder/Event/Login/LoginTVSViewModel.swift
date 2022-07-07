/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AppAuth

enum LoginMode {
	case tvs // TVS - Digid
	case ggdGhorPortal // GGD GHOR Portal
}

class LoginTVSViewModel {

	private weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?
	private weak var openIdManager: OpenIdManaging? = Current.openIdManager

	private var appAuthState: AppAuthState?
	private var eventMode: EventMode
	private let loginMode: LoginMode
	private let step: ErrorCode.Step
	private let issuerConfiguration: IssuerConfiguration
	
	@Bindable internal var content: Content

	@Bindable private(set) var shouldShowProgress: Bool = false

	init(
		coordinator: (EventCoordinatorDelegate & OpenUrlProtocol),
		eventMode: EventMode,
		loginMode: LoginMode,
		appAuthState: AppAuthState? = UIApplication.shared.delegate as? AppAuthState) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.appAuthState = appAuthState
		self.loginMode = loginMode
		switch loginMode {
			case .tvs:
				self.step = .tvs
				self.issuerConfiguration = TVSConfig()
			case .ggdGhorPortal:
				self.step = .ggdGhorPortal
				self.issuerConfiguration = GGDGHORConfig()
		}
		content = Content(title: L.holder_fetchRemoteEvents_title())
	}

	func cancel() {

		self.coordinator?.loginTVSScreenDidFinish(.back(eventMode: eventMode))
	}

	/// Login
	func login(presentingViewController: UIViewController) {

		shouldShowProgress = true
		content = Content(
			title: L.holder_fetchRemoteEvents_title(),
			body: nil,
			primaryActionTitle: L.generalClose(),
			primaryAction: { [weak self] in
				self?.cancel()
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		
		openIdManager?.requestAccessToken(
			issuerConfiguration: issuerConfiguration,
			// use the internal browser for GGD,
			// use the external browser for Didid (because the Digid app redirects to external browser)
			presentingViewController: loginMode == .ggdGhorPortal ? presentingViewController : nil,
			onCompletion: { token in
				
				self.shouldShowProgress = false
				self.handleToken(token)
			},
			onError: { error in
				self.shouldShowProgress = false
				self.handleError(error)
			}
		)
	}
	
	func handleToken(_ token: OpenIdManagerToken) {
		
		switch loginMode {
			case .tvs:
				
				guard let idToken = token.idToken else {
					self.handleError(NSError(domain: OIDOAuthTokenErrorDomain, code: OIDErrorCode.idTokenParsingError.rawValue))
					return
				}
				
				self.coordinator?.loginTVSScreenDidFinish(.didLogin(tvsToken: idToken, portalToken: nil, eventMode: self.eventMode))
				
			case .ggdGhorPortal:
				
				guard let accessToken = token.accessToken else {
					self.handleError(NSError(domain: OIDOAuthTokenErrorDomain, code: OIDErrorCode.idTokenParsingError.rawValue))
					return
				}
				
				self.coordinator?.loginTVSScreenDidFinish(.didLogin(tvsToken: nil, portalToken: accessToken, eventMode: self.eventMode))
		}
	}
}

// MARK: Error States

extension LoginTVSViewModel {

	func handleError(_ error: Error?) {

		Current.logHandler.logError("Login error: \(error?.localizedDescription ?? "Unknown error")")
		let clientCode = OpenIdErrorMapper().mapError(error)

		if let error = error {
			if  error.localizedDescription.contains("login_required") {
				Current.logHandler.logDebug("Server busy")
				displayServerBusy(
					errorCode: ErrorCode(
						flow: eventMode.flow,
						step: step,
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
							step: step,
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
			step: step,
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
