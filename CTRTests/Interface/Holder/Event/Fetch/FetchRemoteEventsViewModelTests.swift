/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
// swiftlint:disable file_length

@testable import CTR
import XCTest
import Nimble

class FetchRemoteEventsViewModelTests: XCTestCase {

	/// Subject under test
	var sut: FetchRemoteEventsViewModel!
	var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {
		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()

		sut = FetchRemoteEventsViewModel(coordinator: coordinatorSpy, token: "test", authenticationMode: .manyAuthenticationExchange, eventMode: .vaccination)
	}

	func test_backButtonTapped_loadingState() {

		// Given
		sut.viewState = .loading(content: Content(title: "Test"))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_warnBeforeGoBack() {

		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_goBack() {

		// When
		sut.goBack()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0) == .back(eventMode: .vaccination)
	}

	func test_accessTokenOK_providersRequestTimeOut() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 220 000 004")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenRequestTimeOut_providersOK() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 230 000 004")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenRequestTimeOut_providersRequestTimeOut() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 220 000 004<br />i 230 000 004")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenOK_providersNoInternet() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okAction.title).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenNoInternet_providersOK() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okAction.title).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenNoInternet_providersNoInternet() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okAction.title).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenOK_providersServerBusy() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 220 000 429")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessTokenServerBusy_providersServerBusy() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 220 000 429<br />i 230 000 429")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessTokenServerBusy_providersOk() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 230 000 429")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessTokenServerUnreachableTimeOut_providersOk() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 230 000 004")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenServerUnreachableConnectionLost_providersOk() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 230 000 005")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenServerUnreachableInvalidHost_providersOk() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 230 000 002")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenNoInternetConnection_providersOk() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.okAction.title).toEventually(equal(L.generalRetry()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.generalClose()))
	}

	func test_accessTokenNoBSN() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchRemoteEventsViewModel.detailedCodeNoBSN), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateNobsnTitle()
			expect(feedback.body) == L.holderErrorstateNobsnMessage()
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessToken_TVSSessionExpired_vaccination() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchRemoteEventsViewModel.detailedCodeTvsSessionExpired), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateNosessionTitle()
			expect(feedback.body) == L.holderErrorstateNosessionMessage()
			expect(feedback.primaryActionTitle) == L.holderErrorstateNosessionAction()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessToken_TVSSessionExpired_vaccinationAndPositiveTest() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchRemoteEventsViewModel.detailedCodeTvsSessionExpired), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.positiveTestProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccinationAndPositiveTest
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateNosessionTitle()
			expect(feedback.body) == L.holderErrorstateNosessionMessage()
			expect(feedback.primaryActionTitle) == L.holderErrorstateNosessionAction()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessToken_nonceExpired() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchRemoteEventsViewModel.detailedCodeNonceExpired), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateNosessionTitle()
			expect(feedback.body) == L.holderErrorstateNosessionMessage()
			expect(feedback.primaryActionTitle) == L.holderErrorstateNosessionAction()
			expect(feedback.secondaryActionTitle).to(beNil())
		}))
	}

	func test_accessTokenOtherServerError() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99000), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.holderErrorstateServerMessage("i 230 000 500 99000")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_accessTokenOtherServerError_providerOtherServerError() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99000), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99001), error: .serverError)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body).to(contain("i 230 000 500 99000"))
			expect(feedback.body).to(contain("i 220 000 500 99001"))
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_noProviderForEventMode_vaccination() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.positiveTestProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((EventFlow.EventResultWrapper.fakeVaccinationResultWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body).to(contain("i 220 000 082"))
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_noProviderForEventMode_vaccinationAndPositiveTest() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((EventFlow.EventResultWrapper.fakeVaccinationResultWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccinationAndPositiveTest
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body).to(contain("i 820 000 080"))
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_noProviderForEventMode_recovery() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((EventFlow.EventResultWrapper.fakeVaccinationResultWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .recovery
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body).to(contain("i 320 000 081"))
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_noProviderForEventMode_negativeTest() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((EventFlow.EventResultWrapper.fakeVaccinationResultWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .test
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body).to(contain("i 420 000 080"))
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_happyFlow_willInvokeCoordinator() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((EventFlow.EventResultWrapper.fakeVaccinationResultWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
	}

	func test_happyFlow_noEvents() {

		// Given
		let eventWrapper = EventFlow.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: EventFlow.Identity.fakeIdentity,
			status: .complete,
			events: []
		)

		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((eventWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue(), timeout: .seconds(5))
	}

	func test_unomiServerBusy_eventOk() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult = (.success((EventFlow.EventResultWrapper.fakeVaccinationResultWrapper, signedResponse)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.okAction.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(beNil())
	}

	func test_unomiOK_eventServerBusy() {

		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.okAction.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(beNil())
	}
	
	func test_unomiOK_eventServerError() {
		
		// Given
		environmentSpies.networkManagerSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([EventFlow.AccessToken.fakeTestToken]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventInformationCompletionResult = (.success(EventFlow.EventInformationAvailable.fakeInformationIsAvailable), ())
		environmentSpies.networkManagerSpy.stubbedFetchEventsCompletionResult =
		(.failure(ServerError.error(statusCode: 500, response: nil, error: .serverError)), ())
		
		// When
		sut = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: .manyAuthenticationExchange,
			eventMode: .vaccination
		)
		
		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0).toEventually(beEventScreenResultError(test: { feedback in
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.body) == L.holderErrorstateFetchMessage("i 250 CC 500")
			expect(feedback.primaryActionTitle) == L.general_toMyOverview()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		}))
	}

	func test_openUrl() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}

	// MARK: Default values

	let signedResponse = SignedResponse(
		payload: "payload",
		signature: "signature"
	)
}

private func beEventScreenResultError(test: @escaping (Content) -> Void = { _ in }) -> Predicate<EventScreenResult> {
	return Predicate.define("be .error with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .error(content, _) = actual {
			test(content)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
