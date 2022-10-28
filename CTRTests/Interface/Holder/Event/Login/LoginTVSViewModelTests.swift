/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
  
@testable import CTR
@testable import Transport
@testable import Shared
import XCTest
import Nimble
import OpenIDConnect

class AuthenticationViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: AuthenticationViewModel!

	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var appAuthStateSpy: AppAuthStateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = EventCoordinatorDelegateSpy()
		appAuthStateSpy = AppAuthStateSpy()
	}

	func test_loadingState_vaccinationMode() {

		// Given

		// When
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		// Then
		expect(self.sut.content.title) == L.holder_fetchRemoteEvents_title()
		expect(self.sut.content.body) == nil
		expect(self.sut.content.primaryAction) == nil
		expect(self.sut.content.primaryActionTitle) == nil
		expect(self.sut.content.secondaryAction) == nil
		expect(self.sut.content.secondaryActionTitle) == nil
	}

	func test_loadingState_recoveryMode() {

		// Given

		// When
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			authenticationMode: .manyAuthenticationExchange
		)

		// Then
		expect(self.sut.content.title) == L.holder_fetchRemoteEvents_title()
		expect(self.sut.content.body) == nil
		expect(self.sut.content.primaryAction) == nil
		expect(self.sut.content.primaryActionTitle) == nil
		expect(self.sut.content.secondaryAction) == nil
		expect(self.sut.content.secondaryActionTitle) == nil
	}

	func test_loadingState_testMode() {

		// Given

		// When
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test(.ggd),
			authenticationMode: .manyAuthenticationExchange
		)

		// Then
		expect(self.sut.content.title) == L.holder_fetchRemoteEvents_title()
		expect(self.sut.content.body) == nil
		expect(self.sut.content.primaryAction) == nil
		expect(self.sut.content.primaryActionTitle) == nil
		expect(self.sut.content.secondaryAction) == nil
		expect(self.sut.content.secondaryActionTitle) == nil
	}

	func test_loadingState_paperproofMode() {

		// Given

		// When
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			authenticationMode: .manyAuthenticationExchange
		)

		// Then
		expect(self.sut.content.title) == L.holder_fetchRemoteEvents_title()
		expect(self.sut.content.body) == nil
		expect(self.sut.content.primaryAction) == nil
		expect(self.sut.content.primaryActionTitle) == nil
		expect(self.sut.content.secondaryAction) == nil
		expect(self.sut.content.secondaryActionTitle) == nil
	}

	func test_cancel() {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		// When
		sut.cancel()

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .vaccination)
	}
	
	func test_cancelAuthorization_whenRequestedAuthorizationIsFalse_shouldNotInvokeCoordinator() {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange,
			appAuthState: appAuthStateSpy
		)
		appAuthStateSpy.stubbedCurrentAuthorizationFlow = nil

		// When
		sut.didBecomeActive()

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == false
	}
	
	func test_abortAuthorization_whenRequestedAuthorization_shouldInvokeCoordinator() {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange,
			appAuthState: appAuthStateSpy
		)
		appAuthStateSpy.stubbedCurrentAuthorizationFlow = ExternalUserAgentSessionDummy()

		// When
		sut.didBecomeActive()

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinishParameters?.0) == EventScreenResult.errorRequiringRestart(eventMode: .vaccination, authenticationMode: .manyAuthenticationExchange)
	}

	func test_openID_success_accessToken_ok() {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnCompletionResult = (OpenIdManagerIdToken(), ())

		// When
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.sut.content.title) == L.holder_fetchRemoteEvents_title()
		expect(self.sut.content.body) == nil
		expect(self.sut.content.primaryAction) != nil
		expect(self.sut.content.primaryActionTitle) == L.generalClose()
		expect(self.sut.content.secondaryAction) == nil
		expect(self.sut.content.secondaryActionTitle) == nil

		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinishParameters?.0) == EventScreenResult.didLogin(token: "idToken", authenticationMode: .manyAuthenticationExchange, eventMode: .vaccination)
	}

	func test_openID_success_accessToken_invalidToken() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)
		let invalidToken = OpenIdManagerIdToken(idToken: nil, accessToken: nil)
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnCompletionResult = (invalidToken, ())

		// When
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 210 000 070-8")
			expect(content.primaryAction) != nil
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryAction) != nil
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}
	
	func test_openID_error_serverUnreachable() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
			(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut), ())

		// When
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.generalErrorServerUnreachableErrorCode("i 210 000 004")
			expect(content.primaryAction) != nil
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryAction) != nil
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_openID_error_serverbusy() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
			(NSError(domain: "Authentication", code: 429, userInfo: [NSLocalizedDescriptionKey: "login_required"]), ())

		// When
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.generalNetworkwasbusyTitle()
			expect(content.body) == L.generalNetworkwasbusyErrorcode("i 210 000 429")
			expect(content.primaryAction) != nil
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryAction) == nil
			expect(content.secondaryActionTitle) == nil
		} else {
			fail("Invalid state")
		}
	}

	func test_openID_error_userCancelled() {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
			(NSError(domain: "Authentication", code: 200, userInfo: [NSLocalizedDescriptionKey: "saml_authn_failed"]), ())

		// When
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinishParameters?.0) == EventScreenResult.errorRequiringRestart(eventMode: .vaccination, authenticationMode: .manyAuthenticationExchange)
	}

	func test_openID_error_userCancelled_OIDErrorCode() {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult = (NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.userCanceledAuthorizationFlow.rawValue, userInfo: nil), ())

		// When
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinishParameters?.0) == EventScreenResult.errorRequiringRestart(eventMode: .vaccination, authenticationMode: .manyAuthenticationExchange)
	}

	func test_openID_error_generalError() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		let cases: [Int: ErrorCode.ClientCode] = [
			OIDErrorCode.invalidDiscoveryDocument.rawValue: ErrorCode.ClientCode.openIDGeneralInvalidDiscoveryDocument,
			OIDErrorCode.programCanceledAuthorizationFlow.rawValue: ErrorCode.ClientCode.openIDGeneralFlowCancelledProgrammatically,
			OIDErrorCode.networkError.rawValue: ErrorCode.ClientCode.openIDGeneralNetworkError,
			OIDErrorCode.serverError.rawValue: ErrorCode.ClientCode.openIDGeneralServerError,
			OIDErrorCode.jsonDeserializationError.rawValue: ErrorCode.ClientCode.openIDGeneralJSONDeserializationError,
			OIDErrorCode.tokenResponseConstructionError.rawValue: ErrorCode.ClientCode.openIDGeneralTokenResponseConstructionError,
			OIDErrorCode.safariOpenError.rawValue: ErrorCode.ClientCode.openIDGeneralSafariOpenError,
			OIDErrorCode.browserOpenError.rawValue: ErrorCode.ClientCode.openIDGeneralBrowserOpenError,
			OIDErrorCode.tokenRefreshError.rawValue: ErrorCode.ClientCode.openIDGeneralTokenRefreshError,
			OIDErrorCode.registrationResponseConstructionError.rawValue: ErrorCode.ClientCode.openIDGeneralInvalidRegistrationResponse,
			OIDErrorCode.jsonSerializationError.rawValue: ErrorCode.ClientCode.openIDGeneralJSONSerializationError,
			OIDErrorCode.idTokenParsingError.rawValue: ErrorCode.ClientCode.openIDGeneralUnableToParseIDToken,
			OIDErrorCode.idTokenFailedValidationError.rawValue: ErrorCode.ClientCode.openIDGeneralInvalidIDToken
		]

		for (code, clientcode) in cases {

			// When
			environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDGeneralErrorDomain, code: code, userInfo: nil), ())
			sut.login(presentingViewController: UIViewController())

			// Then
			expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.body) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction) != nil
				expect(content.primaryActionTitle) == L.general_toMyOverview()
				expect(content.secondaryAction) != nil
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}

	func test_openID_error_AuthAuthorizationError() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		let cases: [Int: ErrorCode.ClientCode] = [
			OIDErrorCodeOAuthAuthorization.invalidRequest.rawValue: ErrorCode.ClientCode.openIDAuthorizationInvalidRequest,
			OIDErrorCodeOAuthAuthorization.unauthorizedClient.rawValue: ErrorCode.ClientCode.openIDAuthorizationUnauthorizedClient,
			OIDErrorCodeOAuthAuthorization.accessDenied.rawValue: ErrorCode.ClientCode.openIDAuthorizationAccessDenied,
			OIDErrorCodeOAuthAuthorization.unsupportedResponseType.rawValue: ErrorCode.ClientCode.openIDAuthorizationUnsupportedResponseType,
			OIDErrorCodeOAuthAuthorization.authorizationInvalidScope.rawValue: ErrorCode.ClientCode.openIDAuthorizationInvalidScope,
			OIDErrorCodeOAuthAuthorization.serverError.rawValue: ErrorCode.ClientCode.openIDAuthorizationServerError,
			OIDErrorCodeOAuthAuthorization.temporarilyUnavailable.rawValue: ErrorCode.ClientCode.openIDAuthorizationTemporarilyUnavailable,
			OIDErrorCodeOAuthAuthorization.clientError.rawValue: ErrorCode.ClientCode.openIDAuthorizationClientError,
			OIDErrorCodeOAuthAuthorization.other.rawValue: ErrorCode.ClientCode.openIDAuthorizationUnknownError
		]

		for (code, clientcode) in cases {

			// When
			environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDOAuthAuthorizationErrorDomain, code: code, userInfo: nil), ())
			sut.login(presentingViewController: UIViewController())

			// Then
			expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.body) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction) != nil
				expect(content.primaryActionTitle) == L.general_toMyOverview()
				expect(content.secondaryAction) != nil
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}

	func test_openID_error_AuthTokenError() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		let cases: [Int: ErrorCode.ClientCode] = [
			OIDErrorCodeOAuthToken.invalidRequest.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidRequest,
			OIDErrorCodeOAuthToken.invalidClient.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidClient,
			OIDErrorCodeOAuthToken.invalidGrant.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidGrant,
			OIDErrorCodeOAuthToken.unauthorizedClient.rawValue: ErrorCode.ClientCode.openIDOAuthTokenUnauthorizedClient,
			OIDErrorCodeOAuthToken.unsupportedGrantType.rawValue: ErrorCode.ClientCode.openIDOAuthTokenUnsupportedGrantType,
			OIDErrorCodeOAuthToken.invalidScope.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidScope,
			OIDErrorCodeOAuthToken.clientError.rawValue: ErrorCode.ClientCode.openIDOAuthTokenClientError,
			OIDErrorCodeOAuthToken.other.rawValue: ErrorCode.ClientCode.openIDOAuthTokenUnknownError
		]

		for (code, clientcode) in cases {

			// When
			environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDOAuthTokenErrorDomain, code: code, userInfo: nil), ())
			sut.login(presentingViewController: UIViewController())

			// Then
			expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.body) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction) != nil
				expect(content.primaryActionTitle) == L.general_toMyOverview()
				expect(content.secondaryAction) != nil
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}

	func test_openID_error_ResourceServerAuthorizationError() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		// When
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
			(NSError(domain: OIDResourceServerAuthorizationErrorDomain, code: 123, userInfo: nil), ())
		sut.login(presentingViewController: UIViewController())

		// Then
		expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 210 000 \(ErrorCode.ClientCode.openIDResourceError.value)")
			expect(content.primaryAction) != nil
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryAction) != nil
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_openID_error_AuthRegistrationError() throws {

		// Given
		sut = AuthenticationViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			authenticationMode: .manyAuthenticationExchange
		)

		let cases: [Int: ErrorCode.ClientCode] = [
			OIDErrorCodeOAuthRegistration.invalidRequest.rawValue: ErrorCode.ClientCode.openIOAuthRegistrationInvalidRequest,
			OIDErrorCodeOAuthRegistration.invalidRedirectURI.rawValue: ErrorCode.ClientCode.openIOAuthRegistrationInvalidRedirectUri,
			OIDErrorCodeOAuthRegistration.invalidClientMetadata.rawValue: ErrorCode.ClientCode.openIOAuthRegistrationInvalidClientMetaData,
			OIDErrorCodeOAuthRegistration.clientError.rawValue: ErrorCode.ClientCode.openIOAuthRegistrationClientError,
			OIDErrorCodeOAuthRegistration.other.rawValue: ErrorCode.ClientCode.openIOAuthRegistrationUnknownError
		]

		for (code, clientcode) in cases {

			// When
			environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDOAuthRegistrationErrorDomain, code: code, userInfo: nil), ())
			sut.login(presentingViewController: UIViewController())

			// Then
			expect(self.coordinatorSpy.invokedAuthenticationScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedAuthenticationScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.body) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction) != nil
				expect(content.primaryActionTitle) == L.general_toMyOverview()
				expect(content.secondaryAction) != nil
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}
}
