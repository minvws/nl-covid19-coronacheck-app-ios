/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class EventCoordinatorTests: XCTestCase {

	private var sut: EventCoordinator!
	private var navigationSpy: NavigationControllerSpy!
	private var eventFlowDelegateSpy: EventFlowDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	private var window = UIWindow()
	
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		navigationSpy = NavigationControllerSpy()
		eventFlowDelegateSpy = EventFlowDelegateSpy()
		
		sut = EventCoordinator(navigationController: navigationSpy, delegate: eventFlowDelegateSpy)
	}

	// MARK: - Tests
	
	func test_start() {

		// Given
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel: RemoteEventStartViewModel? = (self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.vaccination
		expect(viewModel?.title) == L.holderVaccinationStartTitle()
	}
	
	func test_startWithVaccination() {
		
		// Given
		
		// When
		sut.startWithVaccination()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel: RemoteEventStartViewModel? = (self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.vaccination
		expect(viewModel?.title) == L.holderVaccinationStartTitle()
	}
	
	func test_startWithNegativeTest() {
		
		// Given
		
		// When
		sut.startWithNegativeTest()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel: RemoteEventStartViewModel? = (self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.test
		expect(viewModel?.title) == L.holder_negativetest_ggd_title()
	}

	func test_startWithRecovery() {
		
		// Given
		
		// When
		sut.startWithRecovery()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel: RemoteEventStartViewModel? = (self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.recovery
		expect(viewModel?.title) == L.holderRecoveryStartTitle()
	}
	
	func test_startWithListTestEvents_vaccinationAssessment() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventVaccinationAssessment
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel

		expect(viewModel?.eventMode) == EventMode.vaccinationassessment
	}

	func test_startWithListTestEvents_paperProof() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventPaperProof
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.paperflow
	}
	
	func test_startWithListTestEvents_positiveTest() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventPositiveTest
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.recovery
	}

	func test_startWithListTestEvents_negativeTest() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventNegativeTest
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.test
	}
	
	func test_startWithListTestEvents_recovery() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventRecovery
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.recovery
	}
	
	func test_startWithListTestEvents_vaccination() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventVaccination
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.vaccination
	}
	
	func test_startWithScannedEvent() {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventPaperProof
		
		// When
		sut.startWithScannedEvent(event)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel: ListRemoteEventsViewModel? = (self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel
		
		expect(viewModel?.eventMode) == EventMode.paperflow
	}
}
