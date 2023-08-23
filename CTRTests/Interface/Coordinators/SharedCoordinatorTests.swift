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

class SharedCoordinatorTests: XCTestCase {
	
	private var window = UIWindow()
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (SharedCoordinator, OnboardingFactorySpy, NewFeaturesFactorySpy, EnvironmentSpies) {
		
		let environmentSpies = setupEnvironmentSpies()
		let onboardingFactorySpy = OnboardingFactorySpy()
		let newFeaturesFactorySpy = NewFeaturesFactorySpy()
		newFeaturesFactorySpy.stubbedInformation = NewFeatureInformation(pages: [], version: 0)
		let sut = SharedCoordinator(
			navigationController: NavigationControllerSpy(),
			window: window
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, onboardingFactorySpy, newFeaturesFactorySpy, environmentSpies)
	}
	
	// MARK: - Tests
	
	func test_needsOnboarding() {
		
		// Given
		let (sut, onboardingFactorySpy, newFeaturesFactorySpy, environmentSpies) = makeSUT()
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		
		var completed = false
		
		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			newFeaturesFactory: newFeaturesFactorySpy
		) {
			completed = true
		}
		
		// Then
		expect(completed) == false
		expect(sut.childCoordinators).to(haveCount(1))
	}
	
	func test_needsConsent() {
		
		// Given
		let (sut, onboardingFactorySpy, newFeaturesFactorySpy, environmentSpies) = makeSUT()
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		
		var completed = false
		
		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			newFeaturesFactory: newFeaturesFactorySpy
		) {
			completed = true
		}
		
		// Then
		expect(completed) == false
		expect(sut.childCoordinators).to(haveCount(1))
	}
	
	func test_doesNotNeedOnboarding() {
		
		// Given
		let (sut, onboardingFactorySpy, newFeaturesFactorySpy, environmentSpies) = makeSUT()
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		var completed = false
		
		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			newFeaturesFactory: newFeaturesFactorySpy
		) {
			completed = true
		}
		// Then
		expect(completed).toEventually(beTrue())
		expect(sut.childCoordinators).to(haveCount(0))
	}
	
	func test_needsNewFeatures() {
		
		// Given
		let (sut, onboardingFactorySpy, newFeaturesFactorySpy, environmentSpies) = makeSUT()
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = [PagedAnnoucementItem(
			title: "",
			content: "",
			imageBackgroundColor: C.white(),
			tagline: "",
			step: 0
		)]
		
		var completed = false
		
		// When
		sut.handleOnboarding(
			onboardingFactory: onboardingFactorySpy,
			newFeaturesFactory: newFeaturesFactorySpy
		) {
			completed = true
		}
		
		// Then
		expect(completed) == false
		expect(sut.childCoordinators).to(haveCount(1))
	}
	
	func test_consentGiven_updates_dependents() {
		
		// Arrange
		let (sut, _, _, environmentSpies) = makeSUT()
		
		// Act
		sut.consentGiven()
		
		// Assert
		
		expect(environmentSpies.onboardingManagerSpy.invokedConsentGivenCount) == 1
		expect(environmentSpies.newFeaturesManagerSpy.invokedUserHasViewedNewFeatureIntroCount) == 1
	}
}
