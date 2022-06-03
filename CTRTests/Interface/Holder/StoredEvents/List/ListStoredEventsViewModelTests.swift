/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import XCTest
import Nimble
@testable import CTR

class ListStoredEventsViewModelTests: XCTestCase {
	
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
	
	// MARK: Content
	
	func test_content_noEvents() {
		
		// Given
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).to(beEmpty())
	}
	
	func test_content_negativeTestEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeNegativeTestResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Opgehaald bij CoronaCheck"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_negativeTest().capitalizingFirstLetter()
		expect(row.details) == "1 juli 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_negativeTest().capitalizingFirstLetter()
	}

	func test_content_negativeTestDCCEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createDCCEventGroup())
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeTest
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Ingescand bewijs"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_negativeTest().capitalizingFirstLetter()
		expect(row.details) == "31 juli 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_negativeTest().capitalizingFirstLetter()
	}
	
	func test_content_positiveTestEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakePositiveTestResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Opgehaald bij CoronaCheck"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_positiveTest().capitalizingFirstLetter()
		expect(row.details) == "1 juli 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_positiveTest().capitalizingFirstLetter()
	}
	
	func test_content_recoveryEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeRecoveryResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Opgehaald bij CoronaCheck"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_recoverycertificate().capitalizingFirstLetter()
		expect(row.details) == "1 juli 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_recoverycertificate().capitalizingFirstLetter()
	}
	
	func test_content_recoveryDCCEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createDCCEventGroup())
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeRecovery
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Ingescand bewijs"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_recoverycertificate().capitalizingFirstLetter()
		expect(row.details) == "31 juli 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_recoverycertificate().capitalizingFirstLetter()
	}

	func test_content_vaccinationEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Opgehaald bij CoronaCheck"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_vaccination().capitalizingFirstLetter()
		expect(row.details) == "16 mei 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_vaccination().capitalizingFirstLetter()
	}
	
	func test_content_multipleVaccinationEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeMultipleVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Opgehaald bij CoronaCheck"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(2))
		let row1 = try XCTUnwrap(group.rows.first)
		expect(row1.title) == L.general_vaccination().capitalizingFirstLetter()
		expect(row1.details) == "8 januari 2022"
		let row2 = try XCTUnwrap(group.rows.last)
		expect(row2.title) == L.general_vaccination().capitalizingFirstLetter()
		expect(row2.details) == "16 mei 2021"
	}
	
	func test_content_vaccinationDCCEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createDCCEventGroup())
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Ingescand bewijs"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_vaccination().capitalizingFirstLetter()
		expect(row.details) == "1 juni 2021"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_vaccination().capitalizingFirstLetter()
	}
	
	func test_content_vaccinationAssessmentEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationAssessmentResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		setupSut()
		
		// Then
		guard case let .listEvents(content: content, groups: groups) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.title) == L.holder_storedEvents_title()
		expect(content.body) == L.holder_storedEvents_message()
		expect(content.primaryActionTitle).to(beNil())
		expect(content.primaryAction).to(beNil())
		expect(content.secondaryActionTitle) == L.holder_storedEvents_button_handleData()
		expect(content.secondaryAction).toNot(beNil())
		expect(groups).toNot(beEmpty())
		expect(groups).to(haveCount(1))
		let group = try XCTUnwrap(groups.first)
		expect(group.header) == "Opgehaald bij CoronaCheck"
		expect(group.actionTitle) == L.holder_storedEvents_button_removeEvents()
		expect(group.action).toNot(beNil())
		expect(group.rows).to(haveCount(1))
		let row = try XCTUnwrap(group.rows.first)
		expect(row.title) == L.general_vaccinationAssessment().capitalizingFirstLetter()
		expect(row.details) == "5 januari 2022"
		
		// When
		row.action?()
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetails) == true
		expect(self.coordinatorSpy.invokedUserWishesToSeeEventDetailsParameters?.title) == L.general_vaccinationAssessment().capitalizingFirstLetter()
	}
	
	// MARK: - Open URL

	func test_openUrl() throws {

		// Given
		setupSut()
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
	
	func test_openURL_throughAction() {
		
		// Given
		setupSut()
		guard case let .listEvents(content: content, groups: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		expect(content.secondaryAction).toNot(beNil())
		
		// When
		content.secondaryAction?()
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == URL(string: L.holder_storedEvents_url())
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
						expiryDate: nil,
						jsonData: jsonData,
						wallet: wallet,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}
	
	private func createDCCEventGroup() -> EventGroup? {

		var eventGroup: EventGroup?
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let jsonData = try? JSONEncoder().encode(EventFlow.DccEvent(credential: "test", couplingCode: "test")) {
				eventGroup = EventGroupModel.create(
					type: EventMode.recovery,
					providerIdentifier: "DCC",
					maxIssuedAt: Date(),
					expiryDate: nil,
					jsonData: jsonData,
					wallet: wallet,
					managedContext: context
				)
			}
		}
		return eventGroup
	}
}
