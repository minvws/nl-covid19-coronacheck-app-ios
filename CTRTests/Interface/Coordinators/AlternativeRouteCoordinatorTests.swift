/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import ReusableViews

class AlternativeRouteCoordinatorTests: XCTestCase {

	private var sut: AlternativeRouteCoordinator!

	private var navigationSpy: NavigationControllerSpy!
	private var alternativeRouteFlowDelegateSpy: AlternativeRouteFlowDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		navigationSpy = NavigationControllerSpy()
		alternativeRouteFlowDelegateSpy = AlternativeRouteFlowDelegateSpy()
		sut = AlternativeRouteCoordinator(
			navigationController: navigationSpy,
			delegate: alternativeRouteFlowDelegateSpy,
			eventMode: .vaccination
		)
	}

	// MARK: - Tests

	func test_start() {
		// Given
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is CheckForDigidViewController) == true
	}

	func test_consumeLink() {
		
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
	
	func test_userWishesToCheckForBSN() {
		
		// Given
		
		// When
		sut.userWishesToCheckForBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel is CheckForBSNViewModel) == true
		expect(self.alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(self.alternativeRouteFlowDelegateSpy.invokedBackToMyOverview) == false
	}
	
	func test_userWishesToCheckForDigid() {
		
		// Given
		
		// When
		sut.userWishesToCheckForDigiD()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is CheckForDigidViewController) == true
		expect((self.navigationSpy.viewControllers.last as? CheckForDigidViewController)?.viewModel is CheckForDigidViewModel) == true
		expect(self.alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(self.alternativeRouteFlowDelegateSpy.invokedBackToMyOverview) == false
	}
	
	func test_userWishesToRequestADigiD() {
		
		// Given
		
		// When
		sut.userWishesToRequestADigiD()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_userWishesToContactHelpDeksWithBSN() throws {

		// Given
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "<a href=\"tel:TEST\">TEST</a>"
		environmentSpies.contactInformationSpy.stubbedPhoneNumberAbroadLink = "<a href=\"tel:TEST 2\">TEST 2</a>"
		environmentSpies.contactInformationSpy.stubbedOpeningDays = "maandag t/m vrijdag"
		environmentSpies.contactInformationSpy.stubbedStartHour = "08:00"
		environmentSpies.contactInformationSpy.stubbedEndHour = "18:00"
		
		// When
		sut.userWishesToContactHelpDeksWithBSN()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Vraag je coronabewijs aan via de helpdesk"
		expect(viewModel.content.body) == "<p>Vraag je bewijs aan bij de CoronaCheck helpdesk. Die kun je maandag t/m vrijdag tussen 08:00 en 18:00 uur bellen op: <a href=\"tel:TEST\">TEST</a> (gratis).</p>\n<p>Of als je vanuit het buitenland belt: <a href=\"tel:TEST 2\">TEST 2</a>. Kies in het keuzemenu voor “een bewijs aanvragen”.</p>Geef het volgende door:<ul><li>je burgerservicenummer (BSN)</li><li>je postcode</li></ul><p>Je bewijs met QR-code wordt per post opgestuurd. Dit kan maximaal 7 werkdagen duren.</p>"
	}
	
	func test_userHasNoBSN_portalDisabled_vaccinationFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holder_contactProviderHelpdesk_vaccinationFlow_title()
		expect(viewModel.content.body) == L.holder_contactProviderHelpdesk_vaccinationFlow_message()
	}
	
	func test_userHasNoBSN_portalDisabled_vaccinationAndPositiveTestFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		sut.eventMode = .vaccinationAndPositiveTest
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holder_contactProviderHelpdesk_vaccinationFlow_title()
		expect(viewModel.content.body) == L.holder_contactProviderHelpdesk_vaccinationFlow_message()
	}
	
	func test_userHasNoBSN_portalDisabled_recoveryFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		sut.eventMode = .recovery
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holder_contactProviderHelpdesk_testFlow_title()
		expect(viewModel.content.body) == L.holder_contactProviderHelpdesk_testFlow_message()
	}
	
	func test_userHasNoBSN_portalDisabled_testFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = false
		sut.eventMode = .test(.ggd)
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holder_contactProviderHelpdesk_testFlow_title()
		expect(viewModel.content.body) == L.holder_contactProviderHelpdesk_testFlow_message()
	}
	
	func test_userHasNoBSN_portalEnabled_vaccinationFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel is ChooseEventLocationViewModel) == true
		expect(self.alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(self.alternativeRouteFlowDelegateSpy.invokedContinueToPap) == false
	}
	
	func test_userHasNoBSN_portalEnabled_vaccinationAndPositiveTestFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		sut.eventMode = .vaccinationAndPositiveTest
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel is ChooseEventLocationViewModel) == true
		expect(self.alternativeRouteFlowDelegateSpy.invokedCanceledAlternativeRoute) == false
		expect(self.alternativeRouteFlowDelegateSpy.invokedContinueToPap) == false
	}
	
	func test_userHasNoBSN_portalEnabled_recoveryFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		sut.eventMode = .recovery
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.alternativeRouteFlowDelegateSpy.invokedContinueToPap) == true
	}
	
	func test_userHasNoBSN_portalEnabled_testFlow() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDPortalEnabledResult = true
		sut.eventMode = .test(.ggd)
		
		// When
		sut.userHasNoBSN()
		
		// Then
		expect(self.alternativeRouteFlowDelegateSpy.invokedContinueToPap) == true
	}

	func test_userWishesToContactProviderHelpDeskWhilePortalEnabled() throws {
		
		// Given

		// When
		sut.userWishesToContactProviderHelpDeskWhilePortalEnabled()

		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.holder_contactProviderHelpdesk_vaccinationFlow_title()
		expect(viewModel.content.body) == L.holder_contactProviderHelpdesk_message_ggdPortalEnabled()
	}

	func test_userWishedToGoToGGDPortal() {

		// Given

		// When
		sut.userWishedToGoToGGDPortal()

		// Then
		expect(self.alternativeRouteFlowDelegateSpy.invokedContinueToPap) == true
	}
}
