/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

// swiftlint:disable:next type_name
class ListRemoteEventsViewModelCompletionStatusTests: XCTestCase {
	
	/// Subject under test
	private var sut: ListRemoteEventsViewModel!
	private var environmentSpies: EnvironmentSpies!
	private var greenCardLoader: GreenCardLoader!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.identityCheckerSpy.stubbedCompareResult = true
		coordinatorSpy = EventCoordinatorDelegateSpy()
		
		// Not using a GreenCardLoader Spy here - this is okay because all its dependencies are already spies.
		// Once GreenCardLoader has full code coverage, this can be replaced with a spy.
		greenCardLoader = GreenCardLoader(
			networkManager: environmentSpies.networkManagerSpy,
			cryptoManager: environmentSpies.cryptoManagerSpy,
			walletManager: environmentSpies.walletManagerSpy,
			secureUserSettings: environmentSpies.secureUserSettingsSpy
		)
	}
	
	func setupSut() {
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
	}
	
	func test_vaccinationrow_completionStatus_unknown() {
		
		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: nil,
			completedByPersonalStatement: nil,
			completionReason: nil
		)
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		expect(completionReason.value) == nil
	}
	
	func test_vaccinationrow_completionStatus_unknown_withCompletionReason() {
		
		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: nil,
			completedByPersonalStatement: nil,
			completionReason: .recovery
		)
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		expect(completionReason.value) == nil
	}
}

// MARK: Status Inomplete

extension ListRemoteEventsViewModelCompletionStatusTests {
	
	func test_vaccinationrow_completionStatus_incomplete_withMedicalStatement() {
		
		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: false,
			completedByPersonalStatement: nil,
			completionReason: nil
		)
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		expect(completionReason.value) == nil
	}
	
	func test_vaccinationrow_completionStatus_incomplete_withPersonalStatement() {
		
		// Given
		let remoteEvent = remoteVaccinationEvent(completedByMedicalStatement: nil, completedByPersonalStatement: false, completionReason: nil)
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		expect(completionReason.value) == nil
	}
}

// MARK: Status Complete

extension ListRemoteEventsViewModelCompletionStatusTests {
	
	func test_vaccinationrow_completionStatus_complete_noReason() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: true,
			completedByPersonalStatement: nil,
			completionReason: EventFlow.VaccinationEvent.CompletionReason.none
		)
		let completionStatus = L.holder_eventdetails_vaccinationStatus_complete()
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		let completionStatus = L.holder_eventdetails_vaccinationStatus_recovery()
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
	
	func test_vaccinationrow_completionStatus_complete_fromFirstVaccinationElsewhere() {

		// Given
		let remoteEvent = remoteVaccinationEvent(
			completedByMedicalStatement: true,
			completedByPersonalStatement: nil,
			completionReason: .firstVaccinationElsewhere
		)
		let completionStatus = L.holder_eventdetails_vaccinationStatus_firstVaccinationElsewhere()
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		let completionStatus = L.holder_eventdetails_vaccinationStatus_complete()
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
		let completionStatus = L.holder_eventdetails_vaccinationStatus_complete()
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteEvent],
			greenCardLoader: greenCardLoader
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
}

// MARK: Helper

extension ListRemoteEventsViewModelCompletionStatusTests {
	
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
