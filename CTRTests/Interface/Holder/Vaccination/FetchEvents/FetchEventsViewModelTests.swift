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
		networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut = FetchEventsViewModel(coordinator: coordinatorSpy, tvsToken: "test", eventMode: .vaccination, networkManager: networkSpy)
	}

	func test_backButtonTapped_loadingState() {

		// Given
		sut.viewState = .loading(content: FetchEventsViewController.Content(title: "test", subTitle: nil, actionTitle: nil, action: nil))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == false
		expect(self.sut.navigationAlert).toNot(beNil())
	}

	func test_backButtonTapped_emptyState() {

		// Given
		sut.viewState = .emptyEvents(content: FetchEventsViewController.Content(title: "test", subTitle: nil, actionTitle: nil, action: nil))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .test)
	}

	func test_warnBeforeGoBack() {

		// Given

		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish) == false
		expect(self.sut.navigationAlert).toNot(beNil())
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
					negativeTest: nil
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

	let eventInformationAvailable = (
		EventFlow.EventInformationAvailable(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			informationAvailable: true
		),
		SignedResponse(payload: "test", signature: "test")
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
		country: "NLD"
	)

	let signedResponse = SignedResponse(
		payload: "payload",
		signature: "signature"
	)
}
