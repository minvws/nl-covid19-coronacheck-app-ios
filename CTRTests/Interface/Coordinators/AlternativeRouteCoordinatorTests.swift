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

class AlternativeRouteCoordinatorTests: XCTestCase {
	
	var window = UIWindow()
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (AlternativeRouteCoordinator, NavigationControllerSpy, AlternativeRouteFlowDelegateSpy, EnvironmentSpies) {
		
		let environmentSpies = setupEnvironmentSpies()
		let navigationSpy = NavigationControllerSpy()
		let alternativeRouteFlowDelegateSpy = AlternativeRouteFlowDelegateSpy()
		let sut = AlternativeRouteCoordinator(
			navigationController: navigationSpy,
			delegate: alternativeRouteFlowDelegateSpy,
			eventMode: .vaccination
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, alternativeRouteFlowDelegateSpy, environmentSpies)
	}
	
	// MARK: - Tests
	
	func test_start() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is CheckForDigidViewController) == true
	}
	
	func test_consumeLink() {
		
		// Given
		let (sut, _, _, _) = makeSUT()
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
	
	func test_userWishesToCheckForBSN() {
		
		// Given
		let (sut, navigationSpy, alternativeRouteFlowDelegateSpy, _) = makeSUT()
		
		// When
		sut.userWishesToCheckForBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel is CheckForBSNViewModel) == true
		expect(alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(alternativeRouteFlowDelegateSpy.invokedBackToMyOverview) == false
	}
	
	func test_userWishesToCheckForDigid() {
		
		// Given
		let (sut, navigationSpy, alternativeRouteFlowDelegateSpy, _) = makeSUT()
		
		// When
		sut.userWishesToCheckForDigiD()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is CheckForDigidViewController) == true
		expect((navigationSpy.viewControllers.last as? CheckForDigidViewController)?.viewModel is CheckForDigidViewModel) == true
		expect(alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(alternativeRouteFlowDelegateSpy.invokedBackToMyOverview) == false
	}
	
	func test_userWishesToContactHelpDeksWithBSN() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "<a href=\"tel:TEST\">TEST</a>"
		environmentSpies.contactInformationSpy.stubbedPhoneNumberAbroadLink = "<a href=\"tel:TEST 2\">TEST 2</a>"
		environmentSpies.contactInformationSpy.stubbedOpeningDays = "maandag t/m vrijdag"
		environmentSpies.contactInformationSpy.stubbedStartHour = "08:00"
		environmentSpies.contactInformationSpy.stubbedEndHour = "18:00"
		
		// When
		sut.userWishesToContactHelpDeksWithBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == "Vraag je coronabewijs aan via de helpdesk"
		expect(viewModel.content.value.body) == "<p>Vraag je bewijs aan bij de CoronaCheck helpdesk. Die kun je maandag t/m vrijdag tussen 08:00 en 18:00 uur bellen op: <a href=\"tel:TEST\">TEST</a> (gratis, gesloten op feestdagen).</p>\n<p>Of als je vanuit het buitenland belt: <a href=\"tel:TEST 2\">TEST 2</a>. Kies in het keuzemenu voor “een bewijs aanvragen”.</p>Geef het volgende door:<ul><li>je burgerservicenummer (BSN)</li><li>je postcode</li></ul><p>Je bewijs met QR-code wordt per post opgestuurd. Dit kan maximaal 7 werkdagen duren.</p>"
	}
	
	func test_userHasNoBSN_portalDisabled_vaccinationFlow() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.holder_contactProviderHelpdesk_vaccinationFlow_title()
		expect(viewModel.content.value.body) == L.holder_contactProviderHelpdesk_vaccinationFlow_message()
	}
	
	func test_userHasNoBSN_portalDisabled_vaccinationAndPositiveTestFlow() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		sut.eventMode = .vaccinationAndPositiveTest
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.holder_contactProviderHelpdesk_vaccinationFlow_title()
		expect(viewModel.content.value.body) == L.holder_contactProviderHelpdesk_vaccinationFlow_message()
	}
	
	func test_userHasNoBSN_portalDisabled_recoveryFlow() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		sut.eventMode = .recovery
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.holder_contactProviderHelpdesk_testFlow_title()
		expect(viewModel.content.value.body) == L.holder_contactProviderHelpdesk_testFlow_message()
	}
	
	func test_userHasNoBSN_portalDisabled_testFlow() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		sut.eventMode = .test(.ggd)
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.holder_contactProviderHelpdesk_testFlow_title()
		expect(viewModel.content.value.body) == L.holder_contactProviderHelpdesk_testFlow_message()
	}
	
	func test_userHasNoBSN_portalEnabled_vaccinationFlow() throws {
		
		// Given
		let (sut, navigationSpy, alternativeRouteFlowDelegateSpy, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect((navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel is ChooseEventLocationViewModel) == true
		expect(alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(alternativeRouteFlowDelegateSpy.invokedContinueToPap) == false
	}
	
	func test_userHasNoBSN_portalEnabled_vaccinationAndPositiveTestFlow() throws {
		
		// Given
		let (sut, navigationSpy, alternativeRouteFlowDelegateSpy, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		sut.eventMode = .vaccinationAndPositiveTest
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect((navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel is ChooseEventLocationViewModel) == true
		expect(alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(alternativeRouteFlowDelegateSpy.invokedContinueToPap) == false
	}
	
	func test_userHasNoBSN_portalEnabled_recoveryFlow() throws {
		
		// Given
		let (sut, _, alternativeRouteFlowDelegateSpy, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		sut.eventMode = .recovery
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(alternativeRouteFlowDelegateSpy.invokedContinueToPap) == true
	}
	
	func test_userHasNoBSN_portalEnabled_testFlow() throws {
		
		// Given
		let (sut, _, alternativeRouteFlowDelegateSpy, environmentSpies) = makeSUT()
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		sut.eventMode = .test(.ggd)
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(alternativeRouteFlowDelegateSpy.invokedContinueToPap) == true
	}
	
	func test_userWishesToContactProviderHelpDeskWhilePortalEnabled() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.userWishesToContactProviderHelpDeskWhilePortalEnabled()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.holder_contactProviderHelpdesk_vaccinationFlow_title()
		expect(viewModel.content.value.body) == L.holder_contactProviderHelpdesk_message_ggdPortalEnabled()
	}
	
	func test_userWishedToGoToGGDPortal() {
		
		// Given
		let (sut, _, alternativeRouteFlowDelegateSpy, _) = makeSUT()
		
		// When
		sut.userWishedToGoToGGDPortal()
		
		// Then
		expect(alternativeRouteFlowDelegateSpy.invokedContinueToPap) == true
	}
}
