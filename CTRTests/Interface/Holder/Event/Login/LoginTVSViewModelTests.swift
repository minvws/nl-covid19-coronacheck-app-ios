/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble
import AppAuth

class LoginTVSViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: LoginTVSViewModel!

	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var openIDSpy: OpenIdManagerSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		openIDSpy = OpenIdManagerSpy()

		Services.use(openIDSpy)
	}

	func test_loadingState_vaccinationMode() {

		// Given

		// When
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.content.title) == L.holderVaccinationListTitle()
		expect(self.sut.content.subTitle).to(beNil())
		expect(self.sut.content.primaryAction).to(beNil())
		expect(self.sut.content.primaryActionTitle).to(beNil())
		expect(self.sut.content.secondaryAction).to(beNil())
		expect(self.sut.content.secondaryActionTitle).to(beNil())
	}

	func test_loadingState_recoveryMode() {

		// Given

		// When
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery
		)

		// Then
		expect(self.sut.content.title) == L.holderRecoveryListTitle()
		expect(self.sut.content.subTitle).to(beNil())
		expect(self.sut.content.primaryAction).to(beNil())
		expect(self.sut.content.primaryActionTitle).to(beNil())
		expect(self.sut.content.secondaryAction).to(beNil())
		expect(self.sut.content.secondaryActionTitle).to(beNil())
	}

	func test_loadingState_testMode() {

		// Given

		// When
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test
		)

		// Then
		expect(self.sut.content.title) == L.holderTestListTitle()
		expect(self.sut.content.subTitle).to(beNil())
		expect(self.sut.content.primaryAction).to(beNil())
		expect(self.sut.content.primaryActionTitle).to(beNil())
		expect(self.sut.content.secondaryAction).to(beNil())
		expect(self.sut.content.secondaryActionTitle).to(beNil())
	}

	func test_loadingState_hkviMode() {

		// Given

		// When
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow
		)

		// Then
		expect(self.sut.content.title) == L.holderDccListTitle()
		expect(self.sut.content.subTitle).to(beNil())
		expect(self.sut.content.primaryAction).to(beNil())
		expect(self.sut.content.primaryActionTitle).to(beNil())
		expect(self.sut.content.secondaryAction).to(beNil())
		expect(self.sut.content.secondaryActionTitle).to(beNil())
	}

	func test_cancel() {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)

		// When
		sut.cancel()

		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .vaccination)
	}

	func test_openID_success_accessToken_ok() {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
		openIDSpy.stubbedRequestAccessTokenOnCompletionResult = ("test", ())

		// When
		sut.login()

		// Then
		expect(self.sut.content.title) == L.holderVaccinationListTitle()
		expect(self.sut.content.subTitle).to(beNil())
		expect(self.sut.content.primaryAction).toNot(beNil())
		expect(self.sut.content.primaryActionTitle) == L.generalClose()
		expect(self.sut.content.secondaryAction).to(beNil())
		expect(self.sut.content.secondaryActionTitle).to(beNil())

		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.continue(value: "test", eventMode: .vaccination)
	}

	func test_openID_success_accessToken_nil() {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
		openIDSpy.stubbedRequestAccessTokenOnCompletionResult = (nil, ())

		// When
		sut.login()

		// Then
		expect(self.sut.content.title) == L.holderVaccinationListTitle()
		expect(self.sut.content.subTitle).to(beNil())
		expect(self.sut.content.primaryAction).toNot(beNil())
		expect(self.sut.content.primaryActionTitle) == L.generalClose()
		expect(self.sut.content.secondaryAction).to(beNil())
		expect(self.sut.content.secondaryActionTitle).to(beNil())

		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorTechnicalText()
		expect(self.sut.alert?.cancelAction).to(beNil())
		expect(self.sut.alert?.cancelTitle).to(beNil())
		expect(self.sut.alert?.okAction).to(beNil())
		expect(self.sut.alert?.okTitle) == L.generalOk()
	}

	func test_openID_error_serverbusy() throws {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
		openIDSpy.stubbedRequestAccessTokenOnErrorResult =
			(NSError(domain: "LoginTVS", code: 429, userInfo: [NSLocalizedDescriptionKey: "login_required"]), ())

		// When
		sut.login()

		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.generalNetworkwasbusyTitle()
			expect(content.subTitle) == L.generalNetworkwasbusyErrorcode("i 210 000 429")
			expect(content.primaryAction).toNot(beNil())
			expect(content.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(content.secondaryAction).to(beNil())
			expect(content.secondaryActionTitle).to(beNil())
		} else {
			fail("Invalid state")
		}
	}

	func test_openID_error_userCancelled() {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
		openIDSpy.stubbedRequestAccessTokenOnErrorResult =
			(NSError(domain: "LoginTVS", code: 200, userInfo: [NSLocalizedDescriptionKey: "saml_authn_failed"]), ())

		// When
		sut.login()

		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.errorRequiringRestart(eventMode: .vaccination)
	}

	func test_openID_error_userCancelled_OIDErrorCode() {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
		openIDSpy.stubbedRequestAccessTokenOnErrorResult = (NSError(domain: OIDGeneralErrorDomain, code: OIDErrorCode.userCanceledAuthorizationFlow.rawValue, userInfo: nil), ())

		// When
		sut.login()

		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.errorRequiringRestart(eventMode: .vaccination)
	}

	func test_openID_error_generalError() throws {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
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
			openIDSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDGeneralErrorDomain, code: code, userInfo: nil), ())
			sut.login()

			// Then
			expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.subTitle) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction).toNot(beNil())
				expect(content.primaryActionTitle) == L.holderErrorstateOverviewAction()
				expect(content.secondaryAction).toNot(beNil())
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}

	func test_openID_error_AuthAuthorizationError() throws {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
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
			openIDSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDOAuthAuthorizationErrorDomain, code: code, userInfo: nil), ())
			sut.login()

			// Then
			expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.subTitle) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction).toNot(beNil())
				expect(content.primaryActionTitle) == L.holderErrorstateOverviewAction()
				expect(content.secondaryAction).toNot(beNil())
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}

	func test_openID_error_AuthTokenError() throws {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)

		let cases: [Int: ErrorCode.ClientCode] = [
			OIDErrorCodeOAuthToken.invalidRequest.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidRequest,
			OIDErrorCodeOAuthToken.invalidClient.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidClient,
			OIDErrorCodeOAuthToken.invalidGrant.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidGrant,
			OIDErrorCodeOAuthToken.unauthorizedClient.rawValue: ErrorCode.ClientCode.openIDOAuthTokenUnauthorizedClient,
			OIDErrorCodeOAuthToken.unsupportedGrantType.rawValue: ErrorCode.ClientCode.openIDOAuthTokenUnsupportedGrantType,
			OIDErrorCodeOAuthToken.invalidScope.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidScope,
			OIDErrorCodeOAuthToken.clientError.rawValue: ErrorCode.ClientCode.openIDOAuthTokenInvalidClient,
			OIDErrorCodeOAuthToken.other.rawValue: ErrorCode.ClientCode.openIDOAuthTokenUnknownError
		]

		for (code, clientcode) in cases {

			// When
			openIDSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDOAuthTokenErrorDomain, code: code, userInfo: nil), ())
			sut.login()

			// Then
			expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.subTitle) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction).toNot(beNil())
				expect(content.primaryActionTitle) == L.holderErrorstateOverviewAction()
				expect(content.secondaryAction).toNot(beNil())
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}

	func test_openID_error_ResourceServerAuthorizationError() throws {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)

		// When
		openIDSpy.stubbedRequestAccessTokenOnErrorResult =
			(NSError(domain: OIDResourceServerAuthorizationErrorDomain, code: 123, userInfo: nil), ())
		sut.login()

		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.subTitle) == L.holderErrorstateClientMessage("i 210 000 \(ErrorCode.ClientCode.openIDResourceError.value)")
			expect(content.primaryAction).toNot(beNil())
			expect(content.primaryActionTitle) == L.holderErrorstateOverviewAction()
			expect(content.secondaryAction).toNot(beNil())
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_openID_error_AuthRegistrationError() throws {

		// Given
		sut = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
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
			openIDSpy.stubbedRequestAccessTokenOnErrorResult =
				(NSError(domain: OIDOAuthRegistrationErrorDomain, code: code, userInfo: nil), ())
			sut.login()

			// Then
			expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
			let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
			if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
				expect(content.title) == L.holderErrorstateTitle()
				expect(content.subTitle) == L.holderErrorstateClientMessage("i 210 000 \(clientcode.value)")
				expect(content.primaryAction).toNot(beNil())
				expect(content.primaryActionTitle) == L.holderErrorstateOverviewAction()
				expect(content.secondaryAction).toNot(beNil())
				expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			} else {
				fail("Invalid state")
			}
		}
	}
}
