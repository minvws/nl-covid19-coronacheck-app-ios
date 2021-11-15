/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

@testable import CTR
import XCTest
import Nimble

class FetchEventsViewModelTests: XCTestCase {

	/// Subject under test
	var sut: FetchEventsViewModel!
	var coordinatorSpy: EventCoordinatorDelegateSpy!
	var networkSpy: NetworkSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		networkSpy = NetworkSpy(configuration: .development)
		Services.use(networkSpy)

		sut = FetchEventsViewModel(coordinator: coordinatorSpy, tvsToken: .test, eventMode: .vaccination)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
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

	func test_backButtonTapped_feedbackState() {

		// Given
		sut.viewState = .feedback(content: Content(title: "Test"))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0) == .back(eventMode: .vaccination)
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
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 220 000 004")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenRequestTimeOut_providersOK() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 230 000 004")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenRequestTimeOut_providersRequestTimeOut() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 220 000 004<br />i 230 000 004")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenOK_providersNoInternet() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenNoInternet_providersOK() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenNoInternet_providersNoInternet() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenOK_providersServerBusy() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.subTitle) == L.generalNetworkwasbusyErrorcode("i 220 000 429")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenServerBusy_providersServerBusy() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.subTitle) == L.generalNetworkwasbusyErrorcode("i 220 000 429<br />i 230 000 429")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenServerBusy_providersOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.subTitle) == L.generalNetworkwasbusyErrorcode("i 230 000 429")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenServerUnreachableTimeOut_providersOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 230 000 004")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenServerUnreachableConnectionLost_providersOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 230 000 005")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenServerUnreachableInvalidHost_providersOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 230 000 002")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenNoInternetConnection_providersOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
	}

	func test_accessTokenNoBSN() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchEventsViewModel.detailedCodeNoBSN), error: .serverError)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateNobsnTitle()
			expect(feedback.subTitle) == L.holderErrorstateNobsnMessage()
			expect(feedback.primaryActionTitle) == L.holderErrorstateNobsnAction()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenSessionExpired() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchEventsViewModel.detailedCodeSessionExpired), error: .serverError)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateNosessionTitle()
			expect(feedback.subTitle) == L.holderErrorstateNosessionMessage()
			expect(feedback.primaryActionTitle) == L.holderErrorstateNosessionAction()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenOtherServerError() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99000), error: .serverError)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle) == L.holderErrorstateServerMessage("i 230 000 500 99000")
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_accessTokenOtherServerError_providerOtherServerError() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99000), error: .serverError)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99001), error: .serverError)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle).to(contain("i 230 000 500 99000"))
			expect(feedback.subTitle).to(contain("i 220 000 500 99001"))
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_noProviderForEventMode_vaccination() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.positiveTestProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((succesEventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle).to(contain("i 220 000 082"))
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_noProviderForEventMode_positiveTest() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((succesEventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .positiveTest
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle).to(contain("i 820 000 080"))
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_noProviderForEventMode_recovery() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((succesEventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .recovery
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle).to(contain("i 320 000 081"))
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_noProviderForEventMode_negativeTest() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((succesEventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .test
		)

		// Then
		waitUntil { done in
			guard let params = self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters else {
				fail("invalid params")
				return
			}
			guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
				fail("wrong state")
				return
			}
			expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle).to(contain("i 420 000 080"))
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	func test_happyFlow_willInvokeCoordinator() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((succesEventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
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
			identity: FetchEventsViewModelTests.identity,
			status: .complete,
			result: nil,
			events: []
		)

		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((eventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue(), timeout: .seconds(5))
	}

	func test_unomiServerBusy_eventOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((succesEventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.cancelTitle).toEventually(beNil())
	}

	func test_unomiOK_eventServerBusy() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([EventFlow.EventProvider.vaccinationProvider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: .test,
			eventMode: .vaccination
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.cancelTitle).toEventually(beNil())
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

	let accessToken = EventFlow.AccessToken(
		providerIdentifier: "CC",
		unomiAccessToken: "unomi test",
		eventAccessToken: "event test"
	)

	let eventInformationAvailable = EventFlow.EventInformationAvailable(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		informationAvailable: true
	)

	static let identity = EventFlow.Identity(
		infix: "",
		firstName: "Corona",
		lastName: "Check",
		birthDateString: "2021-05-16"
	)

	let succesEventWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: identity,
		status: .complete,
		result: nil,
		events: [
			EventFlow.Event(
				type: "vaccination",
				unique: "1234",
				isSpecimen: false,
				vaccination: vaccinationEvent,
				negativeTest: nil,
				positiveTest: nil,
				recovery: nil,
				dccEvent: nil
			)
		]
	)

	static let vaccinationEvent = EventFlow.VaccinationEvent(
		dateString: "2021-05-16",
		hpkCode: nil,
		type: nil,
		manufacturer: nil,
		brand: nil,
		doseNumber: 1,
		totalDoses: 2,
		country: "NLD",
		completedByMedicalStatement: nil,
		completedByPersonalStatement: nil,
		completionReason: nil
	)

	let signedResponse = SignedResponse(
		payload: "payload",
		signature: "signature"
	)
}
