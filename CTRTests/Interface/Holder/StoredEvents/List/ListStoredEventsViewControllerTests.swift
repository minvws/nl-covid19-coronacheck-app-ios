/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

class ListStoredEventsViewControllerTests: XCTestCase {

	private var sut: ListStoredEventsViewController!
	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	var window = UIWindow()
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = HolderCoordinatorDelegateSpy()
		window = UIWindow()
	}

	func setupSut() {
		
		sut = ListStoredEventsViewController(
			viewModel: ListStoredEventsViewModel(
				coordinator: coordinatorSpy
			)
		)
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_content_noEvents() {

		// Given
		setupSut()

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}

	func test_content_negativeTestEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeNegativeTestResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}
	
	func test_content_negativeTestDCCEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createDCCEventGroup())
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeTest
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}
	
	func test_content_positiveTestEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakePositiveTestResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}
	
	func test_content_recoveryEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeRecoveryResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}

	func test_content_recoveryDCCEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createDCCEventGroup())
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeRecovery
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}

	func test_content_multipleVaccinationEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeMultipleVaccinationResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}
	
	func test_content_vaccinationDCCEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createDCCEventGroup())
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}

	func test_content_vaccinationAssessmentEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationAssessmentResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
	}
	
	func test_content_combinedEvents() throws {
		
		// Given
		let assessmentGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeVaccinationAssessmentResultWrapper))
		let multipleVaccinationsGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeMultipleVaccinationResultWrapper))
		let postiviteTestGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakePositiveTestResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [postiviteTestGroup, assessmentGroup, multipleVaccinationsGroup]
		setupSut()

		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_storedEvents_title()
		expect(self.sut.sceneView.message) == L.holder_storedEvents_message()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_storedEvents_button_handleData()

		sut.assertImage()
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
					jsonData: jsonData,
					wallet: wallet,
					managedContext: context
				)
			}
		}
		return eventGroup
	}
}
