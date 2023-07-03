/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import CTR
@testable import Transport
@testable import Shared
import ReusableViews
import TestingShared
import Persistence
@testable import Managers
@testable import Resources

class ListStoredEventsViewModelRemovalTests: XCTestCase {
	
	/// Subject under test
	private var sut: ListStoredEventsViewModel!
	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = false
		
		coordinatorSpy = HolderCoordinatorDelegateSpy()
	}
	
	func setupSut() {
		
		sut = ListStoredEventsViewModel(coordinator: coordinatorSpy)
	}
}

// MARK: - Removal

extension ListStoredEventsViewModelRemovalTests {
	
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
		expect(self.sut.alert) != nil
		expect(self.sut.alert?.title) == L.holder_storedEvent_alert_removeEvents_title()
		expect(self.sut.alert?.subTitle) == L.holder_storedEvent_alert_removeEvents_message()
	}
}

// MARK: - Database Error

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_databaseError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .failure(NSError(domain: "test error", code: 0))
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1110 000 062")
	}
}

// MARK: - prepare issue

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_failedToParsePrepareIssue() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToParsePrepareIssue), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1170 000 053")
	}
	
	func test_removalVaccination_prepareIssue_invalidSignature() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1170 000 020")
	}
	
	func test_removalVaccination_prepareIssue_serverError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateServerMessage("i 1170 000 500 99702")
	}
	
	func test_removalVaccination_prepareIssue_serverBusy() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: 429, response: nil, error: .serverBusy))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.generalNetworkwasbusyTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalNetworkwasbusyErrorcode("i 1170 000 429")
	}
	
	func test_removalVaccination_prepareIssue_serverUnreachable() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalErrorServerUnreachableErrorCode("i 1170 000 004")
	}
}

// MARK: - Commit Message

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_failedToGenerateCommitmentMessage() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1170 000 054")
	}
	
}
// MARK: - Signer

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_signer_invalidSignature() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1180 000 020")
	}
	
	func test_removalVaccination_signer_serverError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateServerMessage("i 1180 000 500 99702")
	}
	
	func test_removalVaccination_signer_serverBusy() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: 429, response: nil, error: .serverBusy))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.generalNetworkwasbusyTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalNetworkwasbusyErrorcode("i 1180 000 429")
	}
	
	func test_removalVaccination_signer_serverUnreachable() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.generalErrorServerUnreachableErrorCode("i 1180 000 004")
	}
}

// MARK: - Save GreenCards

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_failedToSaveGreenCards() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToSaveGreenCards), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1190 000 055")
	}
}

// MARK: - Mismatching Identity

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_mismatchedIdentity() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		let serverResponse = ServerResponse(status: "error", code: 99790, context: ServerResponseContext(matchingBlobIds: [["123"]]))
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
		(.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: serverResponse, error: .serverError))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedHandleMismatchedIdentityError).toEventually(beTrue())
	}
}

// MARK: - No internet

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_noInternet() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .noInternetConnection))), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
	}
}

// MARK: - Success

extension ListStoredEventsViewModelRemovalTests {
	
	func test_removalVaccination_success() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
	}
	
	func test_removalVaccination_noEvents() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.walletManagerSpy.stubbedRemoveEventGroupResult = .success(())
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.noSignedEvents), ())
		setupSut()
		guard case let .listEvents(content: _, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		let group = try XCTUnwrap(groups.first)
		group.action?()
		sut.alert?.okAction.action?(UIAlertAction())
		
		// Then
		expect(self.coordinatorSpy.invokedPresentError).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
	}
}

// MARK: - Helpers

extension ListStoredEventsViewModelRemovalTests {
	
	func createEventGroup(wrapper: EventFlow.EventResultWrapper) -> EventGroup? {
		
		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
			let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = environmentSpies.dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroup(
						type: EventMode.recovery,
						providerIdentifier: "CoronaCheck",
						expiryDate: nil,
						jsonData: jsonData,
						wallet: wallet,
						isDraft: false,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}
}
