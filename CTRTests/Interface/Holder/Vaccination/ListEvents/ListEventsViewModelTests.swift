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

class ListEventsViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ListEventsViewModel!
	var coordinatorSpy: EventCoordinatorDelegateSpy!
	var networkSpy: NetworkSpy!
	var walletSpy: WalletManagerSpy!
	var cryptoSpy: CryptoManagerSpy!
	var greenCardLoader: GreenCardLoader!
	var remoteConfigSpy: RemoteConfigManagingSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))
		networkSpy = NetworkSpy(configuration: .test)
		cryptoSpy = CryptoManagerSpy()
		remoteConfigSpy = RemoteConfigManagingSpy()

		/// Not using a GreenCardLoader Spy here because all its dependencies are already spies here.
		greenCardLoader = GreenCardLoader(networkManager: networkSpy, cryptoManager: cryptoSpy, walletManager: walletSpy)

		remoteConfigSpy.stubbedGetConfigurationResult = RemoteConfiguration.default
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .test)
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, _, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(hide) == true
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.secondaryAction?()

			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == .moreInformation(title: L.holderVaccinationWrongTitle(), body: L.holderVaccinationWrongBody(), hideBodyForScreenCapture: false)
		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupError_eventModeVaccination() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = false

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
			expect(self.networkSpy.invokedFetchGreencards) == false
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
			expect(self.sut.alert).toNot(beNil())

		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupError_eventModeRecovery() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [defaultRemoteRecoveryEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = false

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
			expect(self.networkSpy.invokedFetchGreencards) == false
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
			expect(self.sut.alert).toNot(beNil())

		} else {
			fail("wrong state")
		}
	}

	func test_makeQR_saveEventGroupError_eventModeTest() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = false

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		networkSpy.stubbedPrepareIssueCompletionResult = (.failure(NetworkError.invalidResponse), ())
		networkSpy.stubbedFetchGreencardsCompletionResult = (.failure(NetworkError.invalidResponse), ())

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedFetchSignedEventsResult = ["test"]
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		networkSpy.stubbedFetchGreencardsCompletionResult = (.failure(NetworkError.invalidResponse), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedStoreEuGreenCardResult = true
		walletSpy.stubbedStoreDomesticGreenCardResult = false
		walletSpy.stubbedFetchSignedEventsResult = ["test"]
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCards), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedStoreEuGreenCardResult = true
		walletSpy.stubbedStoreDomesticGreenCardResult = true
		walletSpy.stubbedFetchSignedEventsResult = ["test"]
		networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCardsNoOrigin), ())
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
			expect(self.networkSpy.invokedFetchGreencards).toEventually(beTrue())
			expect(self.walletSpy.invokedStoreDomesticGreenCard).toEventually(beFalse())
			expect(self.walletSpy.invokedStoreEuGreenCard).toEventually(beFalse())
			expect(self.walletSpy.invokedRemoveExistingGreenCards).toEventually(beFalse())
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
			remoteEvents: [defaultremoteVaccinationEvent()],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)

		walletSpy.stubbedStoreEventGroupResult = true
		walletSpy.stubbedStoreEuGreenCardResult = true
		walletSpy.stubbedStoreDomesticGreenCardResult = true
		walletSpy.stubbedFetchSignedEventsResult = ["test"]
			networkSpy.stubbedFetchGreencardsCompletionResult = (.success(remoteGreenCards), ())
		networkSpy.stubbedPrepareIssueCompletionResult = (.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		cryptoSpy.stubbedGenerateCommitmentMessageResult = "test"
		cryptoSpy.stubbedGetStokenResult = "test"

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.primaryAction?()

			// Then
			expect(self.walletSpy.invokedRemoveExistingEventGroups) == false
			expect(self.walletSpy.invokedRemoveExistingEventGroupsType) == true
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
	
	func test_vaccinationrow_completionStatus_unknown() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: nil, completedByPersonalStatement: nil, completionReason: nil)
		let completionStatus = L.holderVaccinationStatusUnknown()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_unknown_withCompletionReason() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: nil, completedByPersonalStatement: nil, completionReason: .recovery)
		let completionStatus = L.holderVaccinationStatusUnknown()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_incomplete_withMedicalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: false, completedByPersonalStatement: nil, completionReason: nil)
		let completionStatus = L.holderVaccinationStatusIncomplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_incomplete_withPersonalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: nil, completedByPersonalStatement: false, completionReason: nil)
		let completionStatus = L.holderVaccinationStatusIncomplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_complete_fromRecovery() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: true, completedByPersonalStatement: nil, completionReason: .recovery)
		let completionStatus = L.holderVaccinationStatusCompleteRecovery()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_complete_fromPriorEvent() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: true, completedByPersonalStatement: nil, completionReason: .priorEvent)
		let completionStatus = L.holderVaccinationStatusCompletePriorevent()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_complete_withMedicalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: true, completedByPersonalStatement: nil, completionReason: nil)
		let completionStatus = L.holderVaccinationStatusComplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}
	
	func test_vaccinationrow_completionStatus_complete_withPersonalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: nil, completedByPersonalStatement: true, completionReason: nil)
		let completionStatus = L.holderVaccinationStatusComplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader,
			walletManager: walletSpy,
			remoteConfigManager: remoteConfigSpy
		)
		let expectedBody = "<p>Deze gegevens van je vaccinatie zijn opgehaald:</p><p>Naam: <b>Check, Corona</b><br />Geboortedatum: <b>16 mei 2021</b></p><p>Ziekteverwekker: <b>COVID-19</b><br />Vaccin: <b></b><br />Type vaccin: <b></b><br />Producent: <b></b><br />Doses: <b>1 van 2</b><br />Is dit de laatste doses van je vaccinatie?<b>\(completionStatus)</b><br />Vaccinatiedatum: <b>16 mei 2021</b><br />Gevaccineerd in: <b>NLD</b><br />Uniek certificaatnummer: <b>1234</b></p>"

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

			if case let .moreInformation(title, body, hide) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 {
				expect(title) == L.holderEventAboutTitle()
				expect(body) == expectedBody
				expect(hide) == true
			} else {
				fail("wrong information")
			}
		} else {
			fail("wrong state")
		}
	}

	// MARK: Default values

	private func defaultremoteVaccinationEvent() -> RemoteEvent {
		return RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
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
						recovery: nil
					)
				]
			),
			signedResponse: signedResponse
		)
	}

	private func defaultRemoteRecoveryEvent() -> RemoteEvent {
		return RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: identity,
				status: .complete,
				result: nil,
				events: [
					EventFlow.Event(
						type: "recovery",
						unique: "1234",
						isSpecimen: false,
						vaccination: nil,
						negativeTest: nil,
						positiveTest: nil,
						recovery: recoveryEvent
					)
				]
			),
			signedResponse: signedResponse
		)
	}

	private let recoveryEvent = EventFlow.RecoveryEvent(
		sampleDate: "2021-07-01",
		validFrom: "2021-07-12",
		validUntil: "2022-12-31" // This will fail the test after 2022-12-31
	)

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
		doseNumber: 1,
		totalDoses: 2,
		country: "NLD",
		completedByMedicalStatement: nil,
		completedByPersonalStatement: nil,
		completionReason: nil
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

	private let remoteGreenCardsNoOrigin = RemoteGreenCards.Response(
		domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
			origins: [],
			createCredentialMessages: "test"
		),
		euGreenCards: [
			RemoteGreenCards.EuGreenCard(
				origins: [],
				credential: "test credential"
			)
		]
	)
	
	// MARK: Helper
	
	func remoteVaccinationEvent(completedByMedicalStatement: Bool?, completedByPersonalStatement: Bool?, completionReason: EventFlow.VaccinationEvent.CompletionReason?) -> RemoteEvent {
		let vaccinationEvent = EventFlow.VaccinationEvent(
			dateString: "2021-05-16",
			hpkCode: nil,
			type: nil,
			manufacturer: nil,
			brand: nil,
			doseNumber: 1,
			totalDoses: 2,
			country: "NLD",
			completedByMedicalStatement: completedByMedicalStatement,
			completedByPersonalStatement: completedByPersonalStatement,
			completionReason: completionReason
		)
		return RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
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
						recovery: nil
					)
				]
			),
			signedResponse: signedResponse
		)
	}
}
