/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

class OnboardingCoordinatorTests: XCTestCase {
	
	private var sut: OnboardingCoordinator!
	
	private var onboardingDelegateSpy: OnboardingDelegateSpy!
	private var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
		onboardingDelegateSpy = OnboardingDelegateSpy()
		navigationSpy = NavigationControllerSpy()
	}
	
	// MARK: Test Doubles
	
	class OnboardingDelegateSpy: OnboardingDelegate {
		
		var consentGivenCalled = false
		var finishOnboardingCalled = false
		
		func consentGiven() {
			
			consentGivenCalled = true
		}
		
		func finishOnboarding() {
			
			finishOnboardingCalled = true
		}
	}
	
	// MARK: - Tests
	
	func test_initializer_holder() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(4))
		expect(self.sut.onboardingPages[0].title) == L.holderOnboardingTitleSafely()
		expect(self.sut.onboardingPages[0].content) == L.holderOnboardingMessageSafely()
		expect(self.sut.onboardingPages[0].image) == I.onboarding.safely()
		expect(self.sut.onboardingPages[0].nextButtonTitle) == nil

		expect(self.sut.onboardingPages[1].title) == L.holderOnboardingTitleYourqr()
		expect(self.sut.onboardingPages[1].content) == L.holderOnboardingMessageYourqr()
		expect(self.sut.onboardingPages[1].image) == I.onboarding.yourQR()
		expect(self.sut.onboardingPages[1].nextButtonTitle) == nil
		
		expect(self.sut.onboardingPages[2].title) == L.holderOnboardingTitleValidity()
		expect(self.sut.onboardingPages[2].content) == L.holderOnboardingMessageValidity()
		expect(self.sut.onboardingPages[2].image) == I.onboarding.validity()
		expect(self.sut.onboardingPages[2].nextButtonTitle) == nil
		
		expect(self.sut.onboardingPages[3].title) == L.holderOnboardingTitlePrivacy()
		expect(self.sut.onboardingPages[3].content) == L.holderOnboardingMessagePrivacy()
		expect(self.sut.onboardingPages[3].image) == I.onboarding.international()
		expect(self.sut.onboardingPages[3].nextButtonTitle) == L.generalNext()

		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_verifier() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: VerifierOnboardingFactory(),
			appFlavor: .verifier
		)
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(1))
		expect(self.sut.onboardingPages[0].title) == L.verifierOnboardingTitleSafely()
		expect(self.sut.onboardingPages[0].content) == L.verifierOnboardingMessageSafely()
		expect(self.sut.onboardingPages[0].image) == I.onboarding.safely()
		expect(self.sut.onboardingPages[0].nextButtonTitle) == L.generalNext()
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_0G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(3))
		expect(self.sut.onboardingPages[0].title) == L.holder_onboarding_content_TravelSafe_0G_title()
		expect(self.sut.onboardingPages[0].content) == L.holder_onboarding_content_TravelSafe_0G_message()
		expect(self.sut.onboardingPages[0].image) == I.onboarding.zeroGInternational()
		expect(self.sut.onboardingPages[0].nextButtonTitle) == nil
		
		expect(self.sut.onboardingPages[1].title) == L.holderOnboardingTitleYourqr()
		expect(self.sut.onboardingPages[1].content) == L.holderOnboardingMessageYourqr()
		expect(self.sut.onboardingPages[1].image) == I.onboarding.yourQR()
		expect(self.sut.onboardingPages[1].nextButtonTitle) == nil
		
		expect(self.sut.onboardingPages[2].title) == L.holder_onboarding_content_onlyInternationalQR_0G_title()
		expect(self.sut.onboardingPages[2].content) == L.holder_onboarding_content_onlyInternationalQR_0G_message()
		expect(self.sut.onboardingPages[2].image) == I.onboarding.validity()
		expect(self.sut.onboardingPages[2].nextButtonTitle) == L.generalNext()
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_1G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(5))
		expect(self.sut.onboardingPages[4].title) == L.holder_onboarding_disclosurePolicyChanged_only1GAccess_title()
		expect(self.sut.onboardingPages[4].content) == L.holder_onboarding_disclosurePolicyChanged_only1GAccess_message()
		expect(self.sut.onboardingPages[4].image) == I.onboarding.disclosurePolicy()
		expect(self.sut.onboardingPages[4].nextButtonTitle) == L.generalNext()
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_3G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(5))
		expect(self.sut.onboardingPages[4].title) == L.holder_onboarding_disclosurePolicyChanged_only3GAccess_title()
		expect(self.sut.onboardingPages[4].content) == L.holder_onboarding_disclosurePolicyChanged_only3GAccess_message()
		expect(self.sut.onboardingPages[4].image) == I.onboarding.disclosurePolicy()
		expect(self.sut.onboardingPages[4].nextButtonTitle) == L.generalNext()
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_3GAnd1G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(5))
		expect(self.sut.onboardingPages[4].title) == L.holder_onboarding_disclosurePolicyChanged_3Gand1GAccess_title()
		expect(self.sut.onboardingPages[4].content) == L.holder_onboarding_disclosurePolicyChanged_3Gand1GAccess_message()
		expect(self.sut.onboardingPages[4].image) == I.onboarding.disclosurePolicy()
		expect(self.sut.onboardingPages[4].nextButtonTitle) == L.generalNext()
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	/// Test the start call
	func test_start() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.invokedSetViewController) == true
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	/// Test the finish onboarding call
	func test_holder_finishOnboarding() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		sut?.didFinishPagedAnnouncement()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
		expect(self.onboardingDelegateSpy.finishOnboardingCalled) == true
		expect(self.environmentSpies.disclosurePolicyManagingSpy.invokedSetDisclosurePolicyUpdateHasBeenSeen) == true
	}

	/// Test the finish onboarding call
	func test_verifier_finishOnboarding() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: VerifierOnboardingFactory(),
			appFlavor: .verifier
		)
		
		// When
		sut?.didFinishPagedAnnouncement()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
		expect(self.onboardingDelegateSpy.finishOnboardingCalled) == true
		expect(self.environmentSpies.disclosurePolicyManagingSpy.invokedSetDisclosurePolicyUpdateHasBeenSeen) == false
	}
	
	/// Test the consent given call
	func test_consentGiven() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory(),
			appFlavor: .holder
		)
		
		// When
		sut?.consentGiven()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == true
		expect(self.onboardingDelegateSpy.finishOnboardingCalled) == false
	}
}
