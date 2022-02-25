/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
			factory: HolderOnboardingFactory()
		)
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(4))
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_verifier() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: VerifierOnboardingFactory()
		)
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(1))
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_1G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(5))
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_3G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(5))
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	func test_initializer_holder_disclosurePolicy_3GAnd1G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
		
		// When
		
		// Then
		expect(self.sut.onboardingPages).to(haveCount(5))
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	/// Test the start call
	func test_start() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
	}
	
	/// Test the finish onboarding call
	func test_finishOnboarding() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
		
		// When
		sut?.finishOnboarding()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.onboardingDelegateSpy.consentGivenCalled) == false
		expect(self.onboardingDelegateSpy.finishOnboardingCalled) == true
	}
	
	/// Test the consent given call
	func test_consentGiven() {
		
		// Given
		sut = OnboardingCoordinator(
			navigationController: navigationSpy,
			onboardingDelegate: onboardingDelegateSpy,
			factory: HolderOnboardingFactory()
		)
		
		// When
		sut?.consentGiven()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.onboardingDelegateSpy.consentGivenCalled) == true
		expect(self.onboardingDelegateSpy.finishOnboardingCalled) == false
	}
}
