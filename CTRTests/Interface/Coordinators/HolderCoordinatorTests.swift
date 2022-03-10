/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class HolderCoordinatorTests: XCTestCase {

	var sut: HolderCoordinator!

	var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		navigationSpy = NavigationControllerSpy()
		sut = HolderCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests

	func testStartNewFeatures() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.newFeaturesManagerSpy.stubbedGetUpdatePageResult = NewFeatureItem(
			image: nil,
			tagline: "test",
			title: "test",
			content: "test"
		)

		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).toNot(beEmpty())
		expect(self.sut.childCoordinators.first is NewFeaturesCoordinator) == true
	}

	func testFinishNewFeatures() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false

		environmentSpies.remoteConfigManagerSpy.stubbedAppendUpdateObserverResult = UUID()
		environmentSpies.remoteConfigManagerSpy.stubbedAppendReloadObserverResult = UUID()
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default

		sut.childCoordinators = [
			NewFeaturesCoordinator(
				navigationController: navigationSpy,
				newFeaturesManager: NewFeaturesManagerSpy(),
				delegate: sut
			)
		]

		// When
		sut.finishNewFeatures()

		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_handleDisclosurePolicyUpdates_needsOnboarding() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = true
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
	}
	
	func test_handleDisclosurePolicyUpdates_shouldShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = true
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G"]
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_handleDisclosurePolicyUpdates_shouldNotShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = false
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
	}
	
	// MARK: - Universal Links -
	
	func test_consume_redeemHolder() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(1))
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController).toEventually(beTrue())
		expect(self.sut.unhandledUniversalLink).to(beNil())
	}
	
	func test_consume_redeemHolder_needsOnboarding() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemHolder_needsConsent() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemHolder_needsUpdating() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemVaccinationAssessment() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(1))
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController).toEventually(beTrue())
		expect(self.sut.unhandledUniversalLink).to(beNil())
	}
	
	func test_consume_redeemVaccinationAssessment_needsOnboarding() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemVaccinationAssessment_needsConsent() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemVaccinationAssessment_needsUpdating() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_thirdPartyTicketApp() {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		let universalLink = UniversalLink.thirdPartyTicketApp(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdpartyTicketApp?.name) == "CoronaCheck"
		expect(self.sut.thirdpartyTicketApp?.returnURL) == URL(string: "https://coronacheck.nl")
	}
	
	func test_consume_thirdPartyTicketApp_domainNotAllowed() {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "oronacheck.nl", name: "CoronaCheck")]
		let universalLink = UniversalLink.thirdPartyTicketApp(returnURL: URL(string: "https://apple.com"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdpartyTicketApp).to(beNil())
	}
	
	func test_consume_tvsAuth() {
		
		// Given
		let universalLink = UniversalLink.tvsAuth(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
	}
	
	func test_consume_thirdPartyScannerApp() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
	}
	
	
}
