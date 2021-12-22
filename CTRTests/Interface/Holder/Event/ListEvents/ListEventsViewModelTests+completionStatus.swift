/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class ListEventsViewModelCompletionStatusTests: XCTestCase {

	/// Subject under test
	private var sut: ListEventsViewModel!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var networkSpy: NetworkSpy!
	private var walletSpy: WalletManagerSpy!
	private var cryptoSpy: CryptoManagerSpy!
	private var greenCardLoader: GreenCardLoader!
	private var remoteConfigSpy: RemoteConfigManagingSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))
		networkSpy = NetworkSpy(configuration: .development)
		cryptoSpy = CryptoManagerSpy()
		remoteConfigSpy = RemoteConfigManagingSpy()
		remoteConfigSpy.stubbedStoredConfiguration = .default
		remoteConfigSpy.stubbedAppendReloadObserverResult = UUID()
		remoteConfigSpy.stubbedAppendUpdateObserverResult = UUID()

		/// Not using a GreenCardLoader Spy here because all its dependencies are already spies here.
		greenCardLoader = GreenCardLoader(networkManager: networkSpy, cryptoManager: cryptoSpy, walletManager: walletSpy)

		Services.use(greenCardLoader)
		Services.use(walletSpy)
		Services.use(remoteConfigSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	func setupSut() {
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: []
		)
	}

	func test_vaccinationrow_completionStatus_unknown() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: nil,
			completedByPersonalStatement: nil,
			completionReason: nil
		)
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		
		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value).to(beNil())
	}
	
	func test_vaccinationrow_completionStatus_unknown_withCompletionReason() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: nil,
			completedByPersonalStatement: nil,
			completionReason: .recovery
		)
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value).to(beNil())
	}
	
	func test_vaccinationrow_completionStatus_incomplete_withMedicalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: false,
			completedByPersonalStatement: nil,
			completionReason: nil
		)
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value).to(beNil())
	}
	
	func test_vaccinationrow_completionStatus_incomplete_withPersonalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: nil, completedByPersonalStatement: false, completionReason: nil)
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value).to(beNil())
	}
	
	func test_vaccinationrow_completionStatus_complete_noReason() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: true,
			completedByPersonalStatement: nil,
			completionReason: EventFlow.VaccinationEvent.CompletionReason.none
		)
		let completionStatus = L.holderVaccinationStatusComplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)
		
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		
		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value) == completionStatus
	}
	
	func test_vaccinationrow_completionStatus_complete_fromRecovery() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: true,
			completedByPersonalStatement: nil,
			completionReason: .recovery
		)
		let completionStatus = L.holderVaccinationStatusCompleteRecovery()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value) == completionStatus
	}
	
	func test_vaccinationrow_completionStatus_complete_fromPriorEvent() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: true,
			completedByPersonalStatement: nil,
			completionReason: .priorEvent
		)
		let completionStatus = L.holderVaccinationStatusCompletePriorevent()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value) == completionStatus
	}
	
	func test_vaccinationrow_completionStatus_complete_withMedicalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: true,
			completedByPersonalStatement: false,
			completionReason: nil
		)
		let completionStatus = L.holderVaccinationStatusComplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value) == completionStatus
	}
	
	func test_vaccinationrow_completionStatus_complete_withPersonalStatement() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: false,
			completedByPersonalStatement: true,
			completionReason: nil
		)
		let completionStatus = L.holderVaccinationStatusComplete()
		
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent]
		)

		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true

		guard case let .showEventDetails(title, details, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		guard let completionReason = details.first(where: { $0.field.displayTitle == L.holderEventAboutVaccinationCompletionreason() }) else {
			fail("no event details")
			return
		}
		
		expect(title) == L.holderEventAboutTitle()
		expect(completionReason.value) == completionStatus
	}
	
	// MARK: Helper
	
	func remoteVaccinationEvent(
		completedByMedicalStatement: Bool?,
		completedByPersonalStatement: Bool?,
		completionReason: EventFlow.VaccinationEvent.CompletionReason?) -> RemoteEvent {
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
				identity: EventFlow.Identity.fakeIdentity,
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
			),
			signedResponse: SignedResponse.fakeResponse
		)
	}
}
