/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Transport
import OpenIDConnect

enum AuthenticationMode {
	case manyAuthenticationExchange // TVS - Digid (many authentication exchange)
	case patientAuthenticationProvider // GGD GHOR Portal (patient authentication provider)
	
	var configuration: OpenIDConnectConfiguration {
		switch self {
			case .manyAuthenticationExchange:
				return MaxConfig()
			case .patientAuthenticationProvider:
				return PapConfig()
		}
	}
	
	var step: ErrorCode.Step {
		switch self {
			case .manyAuthenticationExchange:
				return .max
			case .patientAuthenticationProvider:
				return .pap
		}
	}
}

class AuthenticationViewModel {

	private weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?
	private weak var openIdManager: OpenIDConnectManaging? = Current.openIdManager

	private var openIDConnectState: OpenIDConnectState?
	private var eventMode: EventMode
	private let authenticationMode: AuthenticationMode
	
	@Bindable internal var content: Content

	@Bindable private(set) var shouldShowProgress: Bool = false

	init(
		coordinator: (EventCoordinatorDelegate & OpenUrlProtocol),
		eventMode: EventMode,
		authenticationMode: AuthenticationMode,
		openIDConnectState: OpenIDConnectState? = UIApplication.shared.delegate as? OpenIDConnectState) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.openIDConnectState = openIDConnectState
		self.authenticationMode = authenticationMode

		content = Content(title: L.holder_fetchRemoteEvents_title())
	}

	func cancel() {

		self.coordinator?.authenticationScreenDidFinish(.back(eventMode: eventMode))
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
			issuerConfiguration: authenticationMode.configuration,
			// use the internal browser for pap,
			// use the external browser for tvs (because the Digid app redirects to external browser)
			presentingViewController: authenticationMode == .patientAuthenticationProvider ? presentingViewController : nil,
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
	
	func handleToken(_ token: OpenIDConnectToken) {
		
		switch authenticationMode {
			case .manyAuthenticationExchange:
				
				guard let idToken = token.idToken else {
					self.handleError(NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.idTokenParsingError.rawValue))
					return
				}
				
				self.coordinator?.authenticationScreenDidFinish(.didLogin(token: idToken, authenticationMode: .manyAuthenticationExchange, eventMode: self.eventMode))
				
			case .patientAuthenticationProvider:
				
				guard let accessToken = token.accessToken else {
					self.handleError(NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.idTokenParsingError.rawValue))
					return
				}
				
				self.coordinator?.authenticationScreenDidFinish(.didLogin(token: accessToken, authenticationMode: .patientAuthenticationProvider, eventMode: self.eventMode))
		}
	}
}

// MARK: Error States

extension AuthenticationViewModel {

	func handleError(_ error: Error?) {

		logError("Authentication error: \(error?.localizedDescription ?? "Unknown error")")
		
		let clientCode = OpenIdErrorMapper().mapError(error)

		if let error {
			if  error.localizedDescription.contains("login_required") {
				logDebug("Server busy")
				displayServerBusy(
					errorCode: ErrorCode(
						flow: eventMode.flow,
						step: authenticationMode.step,
						errorCode: "429"
					)
				)
				return
			} else if error.localizedDescription.contains("saml_authn_failed") ||
						error.localizedDescription.contains("cancelled:") ||
						clientCode == ErrorCode.ClientCode.openIDGeneralUserCancelledFlow {
				logDebug("User cancelled")
				userCancelled()
				return
			} else if case let ServerError.error(_, _, networkError) = error {
				switch networkError {
					case .serverUnreachableTimedOut, .serverUnreachableConnectionLost, .serverUnreachableInvalidHost:

						let errorCode = ErrorCode(
							flow: eventMode.flow,
							step: authenticationMode.step,
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
			step: authenticationMode.step,
			clientCode: clientCode ?? ErrorCode.ClientCode(value: "000")
		)
		self.displayErrorCode(errorCode: errorCode)
	}

	func userCancelled() {

		self.coordinator?.authenticationScreenDidFinish(
			.errorRequiringRestart(
				eventMode: eventMode,
				authenticationMode: self.authenticationMode
			)
		)
	}
	
	func didBecomeActive() {
		
		guard openIDConnectState?.currentAuthorizationFlow != nil else { return }
		guard authenticationMode == .manyAuthenticationExchange else {
			// When we receive the didBecomeActive notification:
			// - For manyAuthenticationExchange that means the user returned to the app, canceling the login
			// - For patientAuthenticationProvider that means the user accepted the popup to login to the GGD.
			//   That should not lead to a cancel action.
			return
		}
		userCancelled()
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
				self?.coordinator?.authenticationScreenDidFinish(.stop)
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		self.coordinator?.authenticationScreenDidFinish(.error(content: content, backAction: cancel))
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
				self?.coordinator?.authenticationScreenDidFinish(.stop)
			},
			secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
			secondaryAction: { [weak self] in
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
					return
				}

				self?.coordinator?.openUrl(url, inApp: true)
			}
		)
		self.coordinator?.authenticationScreenDidFinish(.error(content: content, backAction: cancel))
	}
}
