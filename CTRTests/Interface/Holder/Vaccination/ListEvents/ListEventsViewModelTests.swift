/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class ListEventsViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ListEventsViewModel!
	var coordinatorSpy: VaccinationCoordinatorDelegateSpy!
	var networkSpy: NetworkSpy!
	var walletSpy: WalletManagerSpy!
	var cryptoSpy: CryptoManagerSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = VaccinationCoordinatorDelegateSpy()
		walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))
		networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		cryptoSpy = CryptoManagerSpy()
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy,
			cryptoManager: cryptoSpy
		)
	}

	func test_backButtonTapped_loadingState() {

		// Given
		sut.viewState = .loading(
			content: defaultContent
		)

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_backButtonTapped_emptyState() {

		// Given
		sut.viewState = .emptyEvents(
			content: defaultContent
		)

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == EventScreenResult.back
	}

	func test_backButtonTapped_listState() {

		// Given
		sut.viewState = .listEvents(
			content: defaultContent,
			rows: []
		)

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_warnBeforeGoBack() {

		// Given

		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_vaccinationrow_actionTapped() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy
		)

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == .holderEventAboutTitle
			} else {
				fail("wrong information")
			}

		} else {
			fail("wrong state")
		}
	}

	func test_somethingIsWrong_tapped() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy
		)

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.secondaryAction?()

			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == .moreInformation(title: .holderVaccinationWrongTitle, body: .holderVaccinationWrongBody)
		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupError() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy
		)

		walletSpy.stubbedStoreEventGroupResult = false

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
			expect(self.networkSpy.invokedFetchGreencards) == false
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
			expect(self.sut.alert).toNot(beNil())

		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		networkSpy.stubbedPrepareIssueCompletionResult = (.failure(NetworkError.invalidResponse), ())
		networkSpy.stubbedFetchGreencardsCompletionResult = (.failure(NetworkError.invalidResponse), ())

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
			expect(self.networkSpy.invokedPrepareIssue).toEventually(beTrue())
			expect(self.networkSpy.invokedFetchGreencards).toEventually(beFalse())
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())

		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy,
			cryptoManager: cryptoSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		networkSpy.stubbedFetchGreencardsCompletionResult = (.failure(NetworkError.invalidResponse), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
			expect(self.networkSpy.invokedPrepareIssue).toEventually(beTrue())
			expect(self.networkSpy.invokedFetchGreencards).toEventually(beTrue())
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
			expect(self.sut.alert).toEventuallyNot(beNil())

		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveEUGreencardError() {

		// Todo: Fix EU greencards.

//		// Given
//		sut = ListEventsViewModel(
//			coordinator: coordinatorSpy,
//			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
//			networkManager: networkSpy,
//			walletManager: walletSpy,
//			cryptoManager: cryptoSpy
//		)
//
//		walletSpy.stubbedStoreEventGroupResult = true
//		walletSpy.stubbedStoreEuGreenCardResult = false
//		walletSpy.stubbedStoreDomesticGreenCardResult = true
//		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
//		networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCards), ())
//		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
//		cryptoSpy.stubbedGetStokenResult = "test"
//
//		if case let .listEvents(content: content, rows: _) = sut.viewState {
//
//			// When
//			content.primaryAction?()
//
//			// Then
//			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
//			expect(self.networkSpy.invokedPrepareIssue).toEventually(beTrue())
//			expect(self.networkSpy.invokedFetchGreencards).toEventually(beTrue())
//			expect(self.walletSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
//			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
//			expect(self.sut.alert).toEventuallyNot(beNil())
//
//		} else {
//			fail("wrong state")
//		}
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveDomesticGreencardError() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy,
			cryptoManager: cryptoSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedStoreEuGreenCardResult = true
		walletSpy.stubbedStoreDomesticGreenCardResult = false
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCards), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
			expect(self.networkSpy.invokedFetchGreencards).toEventually(beTrue())
			expect(self.networkSpy.invokedPrepareIssue).toEventually(beTrue())
			expect(self.walletSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
			expect(self.sut.alert).toEventuallyNot(beNil())

		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencard_noOrigins() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy,
			cryptoManager: cryptoSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedStoreEuGreenCardResult = true
		walletSpy.stubbedStoreDomesticGreenCardResult = true
		walletSpy.stubbedListOriginsResult = []
		networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCards), ())
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
			expect(self.networkSpy.invokedFetchGreencards).toEventually(beTrue())
			expect(self.walletSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
			expect(self.walletSpy.invokedStoreEuGreenCard).toEventually(beTrue())
			expect(self.walletSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
			expect(self.sut.alert).toEventually(beNil())
		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteVaccinationEvents: [defaultremoteVaccinationEvent()],
			remoteTestEvents: [],
			networkManager: networkSpy,
			walletManager: walletSpy,
			cryptoManager: cryptoSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedStoreEuGreenCardResult = true
		walletSpy.stubbedStoreDomesticGreenCardResult = true
		walletSpy.stubbedListOriginsResult = [Origin()]
			networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCards), ())
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == true
			expect(self.networkSpy.invokedFetchGreencards).toEventually(beTrue())
			expect(self.walletSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
			expect(self.walletSpy.invokedStoreEuGreenCard).toEventually(beTrue())
			expect(self.walletSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0).toEventually(equal(EventScreenResult.continue(value: nil, eventMode: .test)))
			expect(self.sut.alert).toEventually(beNil())
		} else {
			fail("wrong state")
		}
	}

	// MARK: Default values

	private func defaultremoteVaccinationEvent() -> RemoteVaccinationEvent {
		return RemoteVaccinationEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: identity,
				status: .complete,
				events: [
					EventFlow.Event(
						type: "vaccination",
						unique: "1234",
						isSpecimen: false,
						vaccination: vaccinationEvent,
						negativeTest: nil
					)
				]
			),
			signedResponse: signedResponse
		)
	}

	private let defaultContent = ListEventsViewController.Content(
		title: "test",
		subTitle: nil,
		primaryActionTitle: nil,
		primaryAction: nil,
		secondaryActionTitle: nil,
		secondaryAction: nil
	)

	private let identity = EventFlow.Identity(
		infix: "",
		firstName: "Corona",
		lastName: "Check",
		birthDateString: "2021-05-16"
	)

	private let vaccinationEvent = EventFlow.VaccinationEvent(
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

	private let signedResponse = SignedResponse(
		payload: "payload",
		signature: "signature"
	)

	private let remoteGreenCards = RemoteGreenCards.Response(
		domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
			origins: [
				RemoteGreenCards.Origin(
					type: "vaccination",
					eventTime: Date(),
					expirationTime: Date(),
					validFrom: Date()
				)
			],
			createCredentialMessages: "test"
		),
		euGreenCards: [
			RemoteGreenCards.EuGreenCard(
				origins: [
					RemoteGreenCards.Origin(
						type: "vaccination",
						eventTime: Date(),
						expirationTime: Date(),
						validFrom: Date()
					)
				],
				credential: "test credential"
			)
		]
	)
}
