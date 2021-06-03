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
	var coordinatorSpy: VaccinationCoordinatorDelegateSpy!
	var networkSpy: NetworkSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = VaccinationCoordinatorDelegateSpy()
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
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinishParameters?.0) == EventScreenResult.back
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
		let eventWrapper = Vaccination.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: identity,
			status: .complete,
			events: [
				Vaccination.Event(
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
		let eventWrapper = Vaccination.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: identity,
			status: .complete,
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
		expect(self.coordinatorSpy.invokedFetchEventsScreenDidFinish).toEventually(beTrue())
	}

	// MARK: Default values

	let accessToken = Vaccination.AccessToken(
		providerIdentifier: "CC",
		unomiAccessToken: "unomi test",
		eventAccessToken: "event test"
	)

	let provider = Vaccination.EventProvider(
		identifier: "CC",
		name: "CoronaCheck",
		unomiURL: URL(string: "https://coronacheck.nl"),
		eventURL: URL(string: "https://coronacheck.nl"),
		cmsCertificate: "test",
		tlsCertificate: "test",
		accessToken: nil,
		eventInformationAvailable: nil
	)

	let eventInformationAvailable = Vaccination.EventInformationAvailable(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		informationAvailable: true
	)

	let identity = Vaccination.Identity(
		infix: "",
		firstName: "Corona",
		lastName: "Check",
		birthDateString: "2021-05-16"
	)

	let vaccinationEvent = Vaccination.VaccinationEvent(
		dateString: "2021-05-16",
		hpkCode: nil,
		type: nil,
		manufacturer: nil,
		brand: nil,
		completedByMedicalStatement: false,
		completedByPersonalStatement: false,
		doseNumber: 1,
		totalDoses: 2,
		country: "NLD"
	)

	let signedResponse = SignedResponse(
		payload: "payload",
		signature: "signature"
	)
}
