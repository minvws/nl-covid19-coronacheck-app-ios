/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

class ForcedInformationCoordinatorTests: XCTestCase {
	
	var sut: ForcedInformationCoordinator!
	
	var navigationSpy: NavigationControllerSpy!
	
	var forcedInformantionManagerSpy: ForcedInformationManagerSpy!
	
	var delegateSpy: ForcedInformationDelegateSpy!
	
	override func setUp() {
		
		super.setUp()
		
		navigationSpy = NavigationControllerSpy()
		forcedInformantionManagerSpy = ForcedInformationManagerSpy()
		delegateSpy = ForcedInformationDelegateSpy()
		sut = ForcedInformationCoordinator(
			navigationController: navigationSpy,
			forcedInformationManager: forcedInformantionManagerSpy,
			delegate: delegateSpy
		)
	}
	
	// MARK: - Tests
	
	/// Test the start method with update page
	func test_start_shouldInvokeFinishForcedInformation() {
		
		// Given
		forcedInformantionManagerSpy.stubbedGetUpdatePageResult = ForcedInformationPage(
			image: nil,
			tagline: "test",
			title: "test",
			content: "test"
		)
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.delegateSpy.invokedFinishForcedInformation) == false
	}
	
	/// Test the start methoud without update page
	func test_start_withoutUpdatePage() {
		
		// Given
		forcedInformantionManagerSpy.stubbedGetUpdatePageResult = nil
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(beEmpty())
		expect(self.delegateSpy.invokedFinishForcedInformation) == true
	}
	
	/// Test the start method without consent content
	func testStartWithoutConsent() {
		
		// Given
		forcedInformantionManagerSpy.stubbedGetConsentResult = nil
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(beEmpty())
		expect(self.delegateSpy.invokedFinishForcedInformation) == true
	}
	
	/// Test the did finish method with consent agreed
	func testDidFinishConsentAgreed() {
		
		// Given
		let result = ForcedInformationResult.consentAgreed
		
		// When
		sut.didFinish(result)
		
		// Then
		expect(self.forcedInformantionManagerSpy.invokedConsentGiven) == true
		expect(self.delegateSpy.invokedFinishForcedInformation) == true
	}
	
	/// Test the did finish method with consent viewed
	func testDidFinishConsentViewed() {
		
		// Given
		let result = ForcedInformationResult.consentViewed
		
		// When
		sut.didFinish(result)
		
		// Then
		expect(self.forcedInformantionManagerSpy.invokedConsentGiven) == true
		expect(self.delegateSpy.invokedFinishForcedInformation) == true
	}
}
