/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class ListStoredEventsViewModelRemovalTests: XCTestCase {
	
	/// Subject under test
	private var sut: ListStoredEventsViewModel!
	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {

		super.setUp()

		environmentSpies = setupEnvironmentSpies()

		coordinatorSpy = HolderCoordinatorDelegateSpy()
	}

	func setupSut() {
		
		sut = ListStoredEventsViewModel(coordinator: coordinatorSpy)
	}
	
	// MARK: - Removal
	
	func test_removal_alertDialog() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		
		// Then
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.holder_storedEvent_alert_removeEvents_title()
		expect(self.sut.alert?.subTitle) == L.holder_storedEvent_alert_removeEvents_message()
	}
	
	// MARK: - Database Error

	func test_removalVaccination_databaseError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(false)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1110 000 062")
	}
	
	// MARK: - prepare issue
	
	func test_removalVaccination_failedToParsePrepareIssue() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToParsePrepareIssue), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1170 000 053")
	}
	
	func test_removalVaccination_prepareIssue_invalidSignature() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1170 000 020")
	}
	
	func test_removalVaccination_prepareIssue_serverError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateServerMessage("i 1170 000 500 99702")
	}
	
	func test_removalVaccination_prepareIssue_serverBusy() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: 429, response: nil, error: .serverBusy))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.generalNetworkwasbusyTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalNetworkwasbusyErrorcode("i 1170 000 429")
	}
	
	func test_removalVaccination_prepareIssue_serverUnreachable() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalErrorServerUnreachableErrorCode("i 1170 000 004")
	}
	
	// MARK: - Commit Message
	
	func test_removalVaccination_failedToGenerateCommitmentMessage() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1170 000 054")
	}
	
	// MARK: - Signer
	
	func test_removalVaccination_signer_invalidSignature() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1180 000 020")
	}
	
	func test_removalVaccination_signer_serverError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateServerMessage("i 1180 000 500 99702")
	}
	
	func test_removalVaccination_signer_serverBusy() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: 429, response: nil, error: .serverBusy))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.generalNetworkwasbusyTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalNetworkwasbusyErrorcode("i 1180 000 429")
	}
	
	func test_removalVaccination_signer_serverUnreachable() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalErrorServerUnreachableErrorCode("i 1180 000 004")
	}
	
	// MARK: - Save GreenCards
	
	func test_removalVaccination_failedToSaveGreenCards() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToSaveGreenCards), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1190 000 055")
	}
	
	// MARK: - No internet
	
	func test_removalVaccination_noInternet() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .noInternetConnection))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
	}
	
	// MARK: - Success
	
	func test_removalVaccination_success() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
	}
	
	func test_removalVaccination_didNotEvaluate() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.didNotEvaluate), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
	}
	
	func test_removalVaccination_noEvents() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(true)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.noSignedEvents), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
	}
	
	// MARK: - Helpers
	
	private func createEventGroup(wrapper: EventFlow.EventResultWrapper) -> EventGroup? {

		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
		   let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = environmentSpies.dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroupModel.create(
						type: EventMode.recovery,
						providerIdentifier: "CoronaCheck",
						maxIssuedAt: Date(),
						jsonData: jsonData,
						wallet: wallet,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}
}
