/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */
// swiftlint:disable type_body_length
// swiftlint:disable file_length

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
	
	// MARK: - Universal Link handling
	
	func test_consume_univeralLink() {
		
		// Given
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let result = sut.consume(universalLink: universalLink)
		
		// Then
		expect(result) == false
	}
	
	// MARK: - Start
	
	func test_start() throws {
		
		// Given
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.vaccination
		expect(viewModel.title) == L.holder_addVaccination_title()
	}
	
	func test_startWithVaccination() throws {
		
		// Given
		
		// When
		sut.startWithVaccination()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.vaccination
		expect(viewModel.title) == L.holder_addVaccination_title()
	}
	
	func test_startWithNegativeTest() throws {
		
		// Given
		
		// When
		sut.startWithNegativeTest()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.test
		expect(viewModel.title) == L.holder_negativetest_ggd_title()
	}
	
	func test_startWithRecovery() throws {
		
		// Given
		
		// When
		sut.startWithRecovery()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? RemoteEventStartViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.recovery
		expect(viewModel.title) == L.holderRecoveryStartTitle()
	}
	
	func test_startWithListTestEvents_vaccinationAssessment() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventVaccinationAssessment
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.vaccinationassessment
	}
	
	func test_startWithListTestEvents_paperProof() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventPaperProof
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.paperflow
	}
	
	func test_startWithListTestEvents_positiveTest() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventPositiveTest
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.recovery
	}
	
	func test_startWithListTestEvents_negativeTest() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventNegativeTest
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.test
	}
	
	func test_startWithListTestEvents_recovery() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventRecovery
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.recovery
	}
	
	func test_startWithListTestEvents_vaccination() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventVaccination
		
		// When
		sut.startWithListTestEvents([event], originalMode: .test)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.vaccination
	}
	
	func test_startWithScannedEvent() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventPaperProof
		
		// When
		sut.startWithScannedEvent(event)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.paperflow
	}
	
	// MARK: - eventStartScreenDidFinish
	
	func test_eventStartScreenDidFinish_back() {
		
		// Given
		
		// When
		sut.eventStartScreenDidFinish(.back(eventMode: .test))
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCancel) == true
	}
	
	func test_eventStartScreenDidFinish_stop() {
		
		// Given
		
		// When
		sut.eventStartScreenDidFinish(.stop)
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCancel) == true
	}
	
	func test_eventStartScreenDidFinish_backswipe() {
		
		// Given
		
		// When
		sut.eventStartScreenDidFinish(.backSwipe)
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCancel) == false
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCancelFromBackSwipe) == true
	}
	
	func test_eventStartScreenDidFinish_continue() {
		
		// Given
		
		// When
		sut.eventStartScreenDidFinish(.continue(eventMode: .vaccination))
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is AuthenticationViewController) == true
	}
	
	func test_eventStartScreenDidFinish_default() {
		
		// Given
		
		// When
		sut.eventStartScreenDidFinish(.shouldCompleteVaccinationAssessment)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
	}
	
	// MARK: - loginTVSScreenDidFinish
	
	func test_loginTVSScreenDidFinish_didLogin() {
		
		// Given
		
		// When
		sut.loginTVSScreenDidFinish(.didLogin(maxToken: "test", papToken: nil, eventMode: .vaccination))
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is FetchRemoteEventsViewController) == true
	}
	
	func test_loginTVSScreenDidFinish_errorRequiringRestart() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .test)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .test, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.errorRequiringRestart(eventMode: .test))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		expect(self.navigationSpy.invokedPresent).toEventually(beTrue())
	}
	
	func test_loginTVSScreenDidFinish_errorRequiringRestart_chooseTestLocation() {
		
		// Given
		navigationSpy.viewControllers = [
			ListOptionsViewController(viewModel: ChooseTestLocationViewModel(coordinator: HolderCoordinatorDelegateSpy())),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .test, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.errorRequiringRestart(eventMode: .test))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseTestLocationViewModel.self))
		expect(self.navigationSpy.invokedPresent).toEventually(beTrue())
	}
	
	func test_loginTVSScreenDidFinish_error() throws {
		// Given
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.loginTVSScreenDidFinish(.error(content: content, backAction: {}))
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_loginTVSScreenDidFinish_back_vaccinationAssessment() {
		
		// Given
		navigationSpy.viewControllers = [
			ListOptionsViewController(viewModel: ChooseTestLocationViewModel(coordinator: HolderCoordinatorDelegateSpy())),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .vaccinationassessment, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .vaccinationassessment))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseTestLocationViewModel.self))
	}
	
	func test_loginTVSScreenDidFinish_back_vaccinationAssessment_visitorpass() {
		
		// Given
		navigationSpy.viewControllers = [
			VisitorPassStartViewController(viewModel: VisitorPassStartViewModel(coordinator: HolderCoordinatorDelegateSpy())),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .vaccinationassessment, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .vaccinationassessment))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is VisitorPassStartViewController) == true
	}

	func test_loginTVSScreenDidFinish_back_test() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .test)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .test, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .test))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
	}

	func test_loginTVSScreenDidFinish_back_test_chooseTestLocation() {
		
		// Given
		navigationSpy.viewControllers = [
			ListOptionsViewController(viewModel: ChooseTestLocationViewModel(coordinator: HolderCoordinatorDelegateSpy())),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .test, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .test))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseTestLocationViewModel.self))
	}
	
	func test_loginTVSScreenDidFinish_back_test_ChooseProofType() {
		
		// Given
		navigationSpy.viewControllers = [
			ListOptionsViewController(viewModel: ChooseProofTypeViewModel(coordinator: HolderCoordinatorDelegateSpy())),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .test, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .test))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseProofTypeViewModel.self))
	}
	
	func test_loginTVSScreenDidFinish_back_vaccination() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .vaccination)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .vaccination, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .vaccination))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
	}
	
	func test_loginTVSScreenDidFinish_back_vaccination_noViewcontrollerStack() {
		
		// Given
		navigationSpy.viewControllers = []
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .vaccination))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
	}

	func test_loginTVSScreenDidFinish_back_vaccinationAndPositiveTest() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .vaccinationAndPositiveTest)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .vaccinationAndPositiveTest, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .vaccinationAndPositiveTest))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
	}
	
	func test_loginTVSScreenDidFinish_back_recovery() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .recovery)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .recovery, authenticationMode: .max))
		]
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .recovery))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
	}
	
	func test_loginTVSScreenDidFinish_back_vaccination_noViewControllerStack() {
		
		// Given
		navigationSpy.viewControllers = []
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .paperflow))
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCancel) == true
		expect(self.navigationSpy.invokedPopToViewController) == false
	}
	
	func test_loginTVSScreenDidFinish_back_paperflow() {
		
		// Given
		
		// When
		sut.loginTVSScreenDidFinish(.back(eventMode: .paperflow))
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCancel) == true
	}
	
	func test_loginTVSScreenDidFinish_stop() {
		
		// Given
		
		// When
		sut.loginTVSScreenDidFinish(.stop)
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == true
	}
	
	func test_loginTVSScreenDidFinish_default() {
		
		// Given
		
		// When
		sut.loginTVSScreenDidFinish(.shouldCompleteVaccinationAssessment)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
	}
	
	// MARK: - fetchEventsScreenDidFinish
	
	func test_fetchEventsScreenDidFinish_showEvents() throws {
		
		// Given
		let event = FakeRemoteEvent.fakeRemoteEventVaccination
		
		// When
		sut.fetchEventsScreenDidFinish(.showEvents(events: [event], eventMode: .vaccination, eventsMightBeMissing: false))
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ListRemoteEventsViewController)?.viewModel)
		expect(viewModel.eventMode) == EventMode.vaccination
	}
	
	func test_fetchEventsScreenDidFinish_error() throws {
		// Given
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.fetchEventsScreenDidFinish(.error(content: content, backAction: {}))
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_fetchEventsScreenDidFinish_back_vaccination() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .vaccination)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .vaccination, authenticationMode: .tvs)),
			FetchRemoteEventsViewController(viewModel: FetchRemoteEventsViewModel(coordinator: sut, maxToken: "test", papToken: nil, eventMode: .vaccination ))
		]
		
		// When
		sut.fetchEventsScreenDidFinish(.back(eventMode: .vaccination))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
	}
	
	func test_fetchEventsScreenDidFinish_stop() {
		
		// Given
		
		// When
		sut.fetchEventsScreenDidFinish(.stop)
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == true
	}
	
	func test_fetchEventsScreenDidFinish_default() {
		
		// Given
		
		// When
		sut.fetchEventsScreenDidFinish(.shouldCompleteVaccinationAssessment)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
	}
	
	// MARK: - listEventsScreenDidFinish

	func test_listEventsScreenDidFinish_stop() {
		
		// Given
		
		// When
		sut.listEventsScreenDidFinish(.stop)
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == true
	}

	func test_listEventsScreenDidFinish_continue() {
		
		// Given
		
		// When
		sut.listEventsScreenDidFinish(.continue(eventMode: .test))
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == true
	}
	
	func test_listEventsScreenDidFinish_back_vaccination() {
		
		// Given
		navigationSpy.viewControllers = [
			RemoteEventStartViewController(viewModel: RemoteEventStartViewModel(coordinator: sut, eventMode: .vaccination)),
			AuthenticationViewController(viewModel: AuthenticationViewModel(coordinator: sut, eventMode: .vaccination, authenticationMode: .tvs)),
			FetchRemoteEventsViewController(viewModel: FetchRemoteEventsViewModel(coordinator: sut, maxToken: "test", papToken: nil,  eventMode: .vaccination )),
			ListRemoteEventsViewController(
				viewModel: ListRemoteEventsViewModel(
					coordinator: sut,
					eventMode: .vaccination,
					remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
					greenCardLoader: environmentSpies.greenCardLoaderSpy
				)
			)
		]
		
		// When
		sut.listEventsScreenDidFinish(.back(eventMode: .vaccination))
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
	}
	
	func test_listEventsScreenDidFinish_error() throws {
		// Given
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.listEventsScreenDidFinish(.error(content: content, backAction: {}))
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_listEventsScreenDidFinish_moreInformation() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.listEventsScreenDidFinish(.moreInformation(title: "title", body: "body", hideBodyForScreenCapture: false))
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "title"
		expect(viewModel.content.body) == "body"
	}
	
	func test_listEventsScreenDidFinish_showEventDetails() throws {
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.negativeTestEvent
		let details = NegativeTestDetailsGenerator.getDetails(identity: identity, event: event)
		
		// When
		sut.listEventsScreenDidFinish(.showEventDetails(title: "test title", details: details, footer: "test footer"))
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? RemoteEventDetailsViewController)?.viewModel)
		expect(viewModel.title) == "test title"
		expect(viewModel.footer) == "test footer"
	}

	func test_listEventsScreenDidFinish_shouldCompleteVaccinationAssessment() {
		
		// Given
		
		// When
		sut.listEventsScreenDidFinish(.shouldCompleteVaccinationAssessment)
		
		// Then
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidCompleteButVisitorPassNeedsCompletion) == true
	}
	
	func test_listEventsScreenDidFinish_default() {
		
		// Given
		
		// When
		sut.listEventsScreenDidFinish(.backSwipe)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
	}
	
	func test_alternativeRoute() {
		
		// Given
		
		// When
		sut.eventStartScreenDidFinish(.alternativeRoute(eventMode: .vaccination))
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first).to(beAKindOf(AlternativeRouteCoordinator.self))
		expect(self.navigationSpy.viewControllers.last is CheckForDigidViewController) == true
	}
	
	func test_canceledAlternativeRoute() {
		
		// Given
		let alternativeCoordinator = AlternativeRouteCoordinator(
			navigationController: sut.navigationController,
			delegate: sut,
			eventMode: .vaccination
		)
		sut.childCoordinators = [alternativeCoordinator]
		
		// When
		sut.canceledAlternativeRoute()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == false
	}
	
	func test_canceledAlternativeRoute_otherChildCoordinatorActive_shouldNotCancel() {
		
		// Given
		let alternativeCoordinator = AlternativeRouteCoordinator(
			navigationController: sut.navigationController,
			delegate: sut,
			eventMode: .vaccination
		)
		let paperProofCoordinator = PaperProofCoordinator(
			navigationController: sut.navigationController,
			delegate: PaperProofFlowDelegateSpy()
		)
		
		sut.childCoordinators = [alternativeCoordinator, paperProofCoordinator]
		
		// When
		sut.canceledAlternativeRoute()
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(2))
		expect(self.sut.childCoordinators.first).to(beAKindOf(AlternativeRouteCoordinator.self))
		expect(self.sut.childCoordinators.last).to(beAKindOf(PaperProofCoordinator.self))
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == false
	}
	
	func test_backToMyOverview() {
		
		// Given
		let alternativeCoordinator = AlternativeRouteCoordinator(
			navigationController: sut.navigationController,
			delegate: sut,
			eventMode: .vaccination
		)
		sut.childCoordinators = [alternativeCoordinator]
		
		// When
		sut.backToMyOverview()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == true
	}
	
	func test_backToMyOverview_noAlternativeRouteCoordinator_shouldNotCallDelegate() {
		
		// Given
		sut.childCoordinators = []
		
		// When
		sut.backToMyOverview()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.eventFlowDelegateSpy.invokedEventFlowDidComplete) == false
	}
}
