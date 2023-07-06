/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI
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
