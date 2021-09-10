/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AppAuth

class LoginTVSViewModel: Logging {

	private weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?
	private weak var openIdManager: OpenIdManaging? = Services.openIdManager

	private var eventMode: EventMode

	@Bindable internal var viewState: LoginTVSViewController.State

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable private(set) var alert: AlertContent?

	init(
		coordinator: (EventCoordinatorDelegate & OpenUrlProtocol),
		eventMode: EventMode) {

		self.coordinator = coordinator
		self.eventMode = eventMode

		viewState = .login(
			content: Content(
				title: {
					switch eventMode {
						case .recovery:
							return L.holderRecoveryListTitle()
						case .paperflow:
							return L.holderDccListTitle()
						case .test:
							return L.holderTestListTitle()
						case .vaccination:
							return L.holderVaccinationListTitle()
					}
				}(),
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	func cancel() {

		self.coordinator?.loginTVSScreenDidFinish(.back(eventMode: eventMode))
	}

	/// Login at the GGD
	func login() {

		shouldShowProgress = true
		viewState = .login(
			content: Content(
				title: {
					switch eventMode {
						case .recovery:
							return L.holderRecoveryListTitle()
						case .paperflow:
							return L.holderDccListTitle()
						case .test:
							return L.holderTestListTitle()
						case .vaccination:
							return L.holderVaccinationListTitle()
					}
				}(),
				subTitle: nil,
				primaryActionTitle: L.generalClose(),
				primaryAction: { [weak self] in
					self?.cancel()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)

		openIdManager?.requestAccessToken() { accessToken in

			self.shouldShowProgress = false

			if let token = accessToken {
				self.coordinator?.loginTVSScreenDidFinish(.continue(value: token, eventMode: self.eventMode))
			} else {
				self.alert = AlertContent(
					title: L.generalErrorTitle(),
					subTitle: L.generalErrorTechnicalText(),
					cancelAction: nil,
					cancelTitle: nil,
					okAction: nil,
					okTitle: L.generalOk()
				)
			}
		} onError: { error in
			self.shouldShowProgress = false
			self.handleError(error)
		}
	}
}

// MARK: Error States

extension LoginTVSViewModel {

	func handleError(_ error: Error?) {

		self.logError("TVS error: \(error?.localizedDescription ?? "Unknown error")")
		let clientCode = mapError(error)

		if let error = error, error.localizedDescription.contains("login_required") {
			logDebug("Server busy")
			displayServerBusy()
			return
		}
		if let error = error, error.localizedDescription.contains("saml_authn_failed") || clientCode == ErrorCode.ClientCode.openIDGeneralUserCancelledFlow {
			logDebug("User cancelled")
			userCancelled()
			return
		}

		let errorCode = ErrorCode(flow: flow, step: .tvs, clientCode: clientCode ?? ErrorCode.ClientCode(value: "000"))
		self.displayErrorCode(errorCode: errorCode)
	}

	func userCancelled() {

		self.coordinator?.loginTVSScreenDidFinish(.errorRequiringRestart(eventMode: self.eventMode))
	}

	func displayErrorCode(errorCode: ErrorCode) {

		viewState = .feedback(
			content: Content(
				title: L.holderErrorstateTitle(),
				subTitle: L.holderErrorstateClientMessage("\(errorCode)"),
				primaryActionTitle: L.holderErrorstateOverviewAction(),
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
		)
	}

	func displayServerBusy() {

		viewState = .feedback(
			content: Content(
				title: L.generalNetworkwasbusyTitle(),
				subTitle: L.generalNetworkwasbusyText(),
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	func mapError(_ error: Error?) -> ErrorCode.ClientCode? {

		guard let error = error else {
			return nil
		}
		let nsError = error as NSError

		switch nsError.domain {
			case OIDGeneralErrorDomain:
				return mapGeneralError(nsError)

			case OIDOAuthAuthorizationErrorDomain:
				return mapAuthAutorizationError(nsError)

			case OIDOAuthTokenErrorDomain:
				return mapAuthTokenError(nsError)

			case OIDResourceServerAuthorizationErrorDomain:
				return ErrorCode.ClientCode.openIDResourceError

			case OIDOAuthRegistrationErrorDomain:
				return mapAuthRegistrationError(nsError)

			default:
				return nil
		}
	}

	private func mapGeneralError(_ error: NSError) -> ErrorCode.ClientCode? {

		switch error.code {
			case OIDErrorCode.invalidDiscoveryDocument.rawValue:
				return ErrorCode.ClientCode.openIDGeneralInvalidDiscoveryDocument

			case OIDErrorCode.userCanceledAuthorizationFlow.rawValue:
				return ErrorCode.ClientCode.openIDGeneralUserCancelledFlow

			case OIDErrorCode.programCanceledAuthorizationFlow.rawValue:
				return ErrorCode.ClientCode.openIDGeneralFlowCancelledProgrammatically

			case OIDErrorCode.networkError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralNetworkError

			case OIDErrorCode.serverError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralServerError

			case OIDErrorCode.jsonDeserializationError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralJSONDeserializationError

			case OIDErrorCode.tokenResponseConstructionError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralTokenResponseConstructionError

			case OIDErrorCode.safariOpenError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralSafariOpenError

			case OIDErrorCode.browserOpenError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralBrowserOpenError

			case OIDErrorCode.tokenRefreshError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralTokenRefreshError

			case OIDErrorCode.registrationResponseConstructionError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralInvalidRegistrationResponse

			case OIDErrorCode.jsonSerializationError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralJSONSerializationError

			case OIDErrorCode.idTokenParsingError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralUnableToParseIDToken

			case OIDErrorCode.idTokenFailedValidationError.rawValue:
				return ErrorCode.ClientCode.openIDGeneralInvalidIDToken
			default:
				return nil
		}
	}

	private func mapAuthAutorizationError(_ error: NSError) -> ErrorCode.ClientCode? {

		switch error.code {
			case OIDErrorCodeOAuthAuthorization.invalidRequest.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationInvalidRequest

			case OIDErrorCodeOAuthAuthorization.unauthorizedClient.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationUnauthorizedClient

			case OIDErrorCodeOAuthAuthorization.accessDenied.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationAccessDenied

			case OIDErrorCodeOAuthAuthorization.unsupportedResponseType.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationUnsupportedResponseType

			case OIDErrorCodeOAuthAuthorization.authorizationInvalidScope.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationInvalidScope

			case OIDErrorCodeOAuthAuthorization.serverError.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationServerError

			case OIDErrorCodeOAuthAuthorization.temporarilyUnavailable.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationTemporarilyUnavailable

			case OIDErrorCodeOAuthAuthorization.clientError.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationClientError

			case OIDErrorCodeOAuthAuthorization.other.rawValue:
				return ErrorCode.ClientCode.openIDAuthorizationUnknownError

			default:
				return nil
		}
	}

	private func mapAuthTokenError(_ error: NSError) -> ErrorCode.ClientCode? {

		switch error.code {
			case OIDErrorCodeOAuthToken.invalidRequest.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenInvalidRequest

			case OIDErrorCodeOAuthToken.invalidClient.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenInvalidClient

			case OIDErrorCodeOAuthToken.invalidGrant.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenInvalidGrant

			case OIDErrorCodeOAuthToken.unauthorizedClient.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenUnauthorizedClient

			case OIDErrorCodeOAuthToken.unsupportedGrantType.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenUnsupportedGrantType

			case OIDErrorCodeOAuthToken.invalidScope.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenInvalidScope

			case OIDErrorCodeOAuthToken.clientError.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenInvalidClient

			case OIDErrorCodeOAuthToken.other.rawValue:
				return ErrorCode.ClientCode.openIDOAuthTokenUnknownError

			default:
				return nil
		}
	}

	private func mapAuthRegistrationError(_ error: NSError) -> ErrorCode.ClientCode? {

		switch error.code {
			case OIDErrorCodeOAuthRegistration.invalidRequest.rawValue:
				return ErrorCode.ClientCode.openIOAuthRegistrationInvalidRequest

			case OIDErrorCodeOAuthRegistration.invalidRedirectURI.rawValue:
				return ErrorCode.ClientCode.openIOAuthRegistrationInvalidRedirectUri

			case OIDErrorCodeOAuthRegistration.invalidClientMetadata.rawValue:
				return ErrorCode.ClientCode.openIOAuthRegistrationInvalidClientMetaData

			case OIDErrorCodeOAuthRegistration.clientError.rawValue:
				return ErrorCode.ClientCode.openIOAuthRegistrationClientError

			case OIDErrorCodeOAuthRegistration.other.rawValue:
				return ErrorCode.ClientCode.openIOAuthRegistrationUnknownError

			default:
				return nil
		}
	}

	private var flow: ErrorCode.Flow {

		switch eventMode {
			case .vaccination:
				return .vaccination
			case .paperflow:
				return .hkvi
			case .recovery:
				return .recovery
			case .test:
				return .ggdTest
		}
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let openIDGeneralInvalidDiscoveryDocument = ErrorCode.ClientCode(value: "070-0")
	static let openIDGeneralUserCancelledFlow = ErrorCode.ClientCode(value: "070-1")
	static let openIDGeneralFlowCancelledProgrammatically = ErrorCode.ClientCode(value: "070-2")
	static let openIDGeneralNetworkError = ErrorCode.ClientCode(value: "070-3")
	static let openIDGeneralServerError = ErrorCode.ClientCode(value: "070-4")
	static let openIDGeneralJSONDeserializationError = ErrorCode.ClientCode(value: "070-5")
	static let openIDGeneralTokenResponseConstructionError = ErrorCode.ClientCode(value: "070-6")
	static let openIDGeneralInvalidRegistrationResponse = ErrorCode.ClientCode(value: "070-7")
	static let openIDGeneralUnableToParseIDToken = ErrorCode.ClientCode(value: "070-8")
	static let openIDGeneralInvalidIDToken = ErrorCode.ClientCode(value: "070-9")
	static let openIDGeneralSafariOpenError = ErrorCode.ClientCode(value: "070-10")
	static let openIDGeneralBrowserOpenError = ErrorCode.ClientCode(value: "070-11")
	static let openIDGeneralTokenRefreshError = ErrorCode.ClientCode(value: "070-12")
	static let openIDGeneralJSONSerializationError = ErrorCode.ClientCode(value: "070-13")

	static let openIDAuthorizationInvalidRequest = ErrorCode.ClientCode(value: "071-1000")
	static let openIDAuthorizationUnauthorizedClient = ErrorCode.ClientCode(value: "071-1001")
	static let openIDAuthorizationAccessDenied = ErrorCode.ClientCode(value: "071-1002")
	static let openIDAuthorizationUnsupportedResponseType = ErrorCode.ClientCode(value: "071-1003")
	static let openIDAuthorizationInvalidScope = ErrorCode.ClientCode(value: "071-1004")
	static let openIDAuthorizationServerError = ErrorCode.ClientCode(value: "071-1005")
	static let openIDAuthorizationTemporarilyUnavailable = ErrorCode.ClientCode(value: "071-1006")
	static let openIDAuthorizationClientError = ErrorCode.ClientCode(value: "071-1007")
	static let openIDAuthorizationUnknownError = ErrorCode.ClientCode(value: "071-1008")

	static let openIDOAuthTokenInvalidRequest = ErrorCode.ClientCode(value: "072-2000")
	static let openIDOAuthTokenInvalidClient = ErrorCode.ClientCode(value: "072-2001")
	static let openIDOAuthTokenInvalidGrant = ErrorCode.ClientCode(value: "072-2002")
	static let openIDOAuthTokenUnauthorizedClient = ErrorCode.ClientCode(value: "072-2003")
	static let openIDOAuthTokenUnsupportedGrantType = ErrorCode.ClientCode(value: "072-2004")
	static let openIDOAuthTokenInvalidScope = ErrorCode.ClientCode(value: "072-2005")
	static let openIDOAuthTokenClientError = ErrorCode.ClientCode(value: "072-2006")
	static let openIDOAuthTokenUnknownError = ErrorCode.ClientCode(value: "072-2007")

	static let openIDResourceError = ErrorCode.ClientCode(value: "073")

	static let openIOAuthRegistrationInvalidRequest = ErrorCode.ClientCode(value: "074-4000")
	static let openIOAuthRegistrationInvalidRedirectUri = ErrorCode.ClientCode(value: "074-4001")
	static let openIOAuthRegistrationInvalidClientMetaData = ErrorCode.ClientCode(value: "074-4002")
	static let openIOAuthRegistrationClientError = ErrorCode.ClientCode(value: "074-4003")
	static let openIOAuthRegistrationUnknownError = ErrorCode.ClientCode(value: "074-4004")
}
