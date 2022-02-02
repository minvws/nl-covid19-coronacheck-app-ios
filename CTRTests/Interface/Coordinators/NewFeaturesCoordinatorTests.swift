/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

class NewFeaturesCoordinatorTests: XCTestCase {
	
	var sut: NewFeaturesCoordinator!
	
	var navigationSpy: NavigationControllerSpy!
	
	var newFeaturesManagerSpy: NewFeaturesManagerSpy!
	
	var delegateSpy: NewFeaturesDelegateSpy!
	
	override func setUp() {
		
		super.setUp()
		
		navigationSpy = NavigationControllerSpy()
		newFeaturesManagerSpy = NewFeaturesManagerSpy()
		delegateSpy = NewFeaturesDelegateSpy()
		sut = NewFeaturesCoordinator(
			navigationController: navigationSpy,
			newFeaturesManager: newFeaturesManagerSpy,
			delegate: delegateSpy
		)
	}
	
	// MARK: - Tests
	
	/// Test the start method with update page
	func test_start_shouldInvokeFinishNewFeatures() {
		
		// Given
		newFeaturesManagerSpy.stubbedGetUpdatePageResult = NewFeatureItem(
			image: nil,
			tagline: "test",
			title: "test",
			content: "test"
		)
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.delegateSpy.invokedFinishNewFeatures) == false
	}
	
	/// Test the start methoud without update page
	func test_start_withoutUpdatePage() {
		
		// Given
		newFeaturesManagerSpy.stubbedGetUpdatePageResult = nil
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(beEmpty())
		expect(self.delegateSpy.invokedFinishNewFeatures) == true
	}
	
	/// Test the start method without consent content
	func testStartWithoutConsent() {
		
		// Given
		newFeaturesManagerSpy.stubbedGetConsentResult = nil
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(beEmpty())
		expect(self.delegateSpy.invokedFinishNewFeatures) == true
	}
	
	/// Test the did finish method with consent agreed
	func testDidFinishConsentAgreed() {
		
		// Given
		let result = NewFeaturesScreenResult.consentAgreed
		
		// When
		sut.didFinish(result)
		
		// Then
		expect(self.newFeaturesManagerSpy.invokedConsentGiven) == true
		expect(self.delegateSpy.invokedFinishNewFeatures) == true
	}
	
	/// Test the did finish method with consent viewed
	func testDidFinishConsentViewed() {
		
		// Given
		let result = NewFeaturesScreenResult.consentViewed
		
		// When
		sut.didFinish(result)
		
		// Then
		expect(self.newFeaturesManagerSpy.invokedConsentGiven) == true
		expect(self.delegateSpy.invokedFinishNewFeatures) == true
	}
}
