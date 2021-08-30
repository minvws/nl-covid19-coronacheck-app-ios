/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
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
		networkSpy = NetworkSpy(configuration: .test)
		sut = FetchEventsViewModel(coordinator: coordinatorSpy, tvsToken: "test", eventMode: .vaccination, networkManager: networkSpy)
	}

	func test_backButtonTapped_loadingState() {

		// Given
		sut.viewState = .loading(content: Content(title: "test", subTitle: nil, primaryActionTitle: nil, primaryAction: nil, secondaryActionTitle: nil, secondaryAction: nil))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_warnBeforeGoBack() {

		// Given

		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_happyFlow_willInvokeCoordinator() {

		// Given
		let eventWrapper = EventFlow.EventResultWrapper(
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

		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((eventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
	}

	func test_happyFlow_noEvents() {

		// Given
		let eventWrapper = EventFlow.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: identity,
			status: .complete,
			result: nil,
			events: []
		)

		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())
		networkSpy.stubbedFetchEventInformationCompletionResult = (.success(eventInformationAvailable), ())
		networkSpy.stubbedFetchEventsCompletionResult = (.success((eventWrapper, signedResponse)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue(), timeout: .seconds(5))
	}

	func test_accessTokenOK_providersRequestTimeOut() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .requestTimedOut)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenRequestTimeOut_providersOK() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .requestTimedOut)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenRequestTimeOut_providersRequestTimeOut() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .requestTimedOut)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .requestTimedOut)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorServerUnreachable()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal(L.generalRetry()))
	}

	func test_accessTokenOK_providersNoInternet() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult = (.success([accessToken]), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
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
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
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
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
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
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.subTitle) == L.generalNetworkwasbusyText()
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
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.subTitle) == L.generalNetworkwasbusyText()
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenServerBusy_providersOk() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
			expect(feedback.title) == L.generalNetworkwasbusyTitle()
			expect(feedback.subTitle) == L.generalNetworkwasbusyText()
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle).to(beNil())
			done()
		}
	}

	func test_accessTokenNoBSN() {

		// Given
		networkSpy.stubbedFetchEventAccessTokensCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: FetchEventsViewModel.detailedCodeNoBSN), error: .serverError)), ())
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
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
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
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
		networkSpy.stubbedFetchEventProvidersCompletionResult = (.success([provider]), ())

		// When
		sut = FetchEventsViewModel(
			coordinator: coordinatorSpy,
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
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
			tvsToken: "test",
			eventMode: .vaccination,
			networkManager: networkSpy
		)

		// Then
		waitUntil { done in
			guard case let .feedback(content: feedback) = self.sut.viewState else {
				fail("wrong state")
				return
			}
			expect(feedback.title) == L.holderErrorstateTitle()
			expect(feedback.subTitle).to(contain("i 230 000 500 99000"))
			expect(feedback.subTitle).to(contain("i 220 000 500 99001"))
			expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
			expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
			done()
		}
	}

	// MARK: Default values

	let accessToken = EventFlow.AccessToken(
		providerIdentifier: "CC",
		unomiAccessToken: "unomi test",
		eventAccessToken: "event test"
	)

	let provider = EventFlow.EventProvider(
		identifier: "CC",
		name: "CoronaCheck",
		unomiURL: URL(string: "https://coronacheck.nl"),
		eventURL: URL(string: "https://coronacheck.nl"),
		cmsCertificate: "test",
		tlsCertificate: "test",
		accessToken: nil,
		eventInformationAvailable: nil
	)

	let eventInformationAvailable = EventFlow.EventInformationAvailable(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		informationAvailable: true
	)

	let identity = EventFlow.Identity(
		infix: "",
		firstName: "Corona",
		lastName: "Check",
		birthDateString: "2021-05-16"
	)

	let vaccinationEvent = EventFlow.VaccinationEvent(
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
