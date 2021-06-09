/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ForcedInformationCoordinatorTests: XCTestCase {

	var sut: ForcedInformationCoordinator!

	var navigationSpy: NavigationControllerSpy!

	var managerSpy: ForcedInformationManagerSpy!

	var delegateSpy: ForcedInformationDelegateSpy!

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		managerSpy = ForcedInformationManagerSpy()
		delegateSpy = ForcedInformationDelegateSpy()
		sut = ForcedInformationCoordinator(
			navigationController: navigationSpy,
			forcedInformationManager: managerSpy,
			delegate: delegateSpy
		)
	}

	// MARK: - Tests

	/// Test the start method with update page
	func test_start_shouldInvokeFinishForcedInformation() {

		// Given
		managerSpy.stubbedGetUpdatePageResult = ForcedInformationPage(
			image: nil,
			tagline: "test",
			title: "test",
			content: "test"
		)

		// When
		sut.start()

		// Then
		XCTAssertTrue(navigationSpy.viewControllers.count == 1)
		XCTAssertFalse(delegateSpy.invokedFinishForcedInformation)
	}
	
	/// Test the start methoud without update page
	func test_start_withoutUpdatePage() {
		
		// Given
		managerSpy.stubbedGetUpdatePageResult = nil

		// When
		sut.start()

		// Then
		XCTAssertTrue(navigationSpy.viewControllers.isEmpty)
		XCTAssertTrue(delegateSpy.invokedFinishForcedInformation)
	}

	/// Test the start method without consent content
	func testStartWithoutConsent() {

		// Given
		managerSpy.stubbedGetConsentResult = nil

		// When
		sut.start()

		// Then
		XCTAssertTrue(navigationSpy.viewControllers.isEmpty)
		XCTAssertTrue(delegateSpy.invokedFinishForcedInformation)
	}

	/// Test the did finish method with consent agreed
	func testDidFinishConsentAgreed() {

		// Given
		let result = ForcedInformationResult.consentAgreed

		// When
		sut.didFinish(result)

		// Then
		XCTAssertTrue(managerSpy.invokedConsentGiven)
		XCTAssertTrue(delegateSpy.invokedFinishForcedInformation)
	}

	/// Test the did finish method with consent viewed
	func testDidFinishConsentViewed() {

		// Given
		let result = ForcedInformationResult.consentViewed

		// When
		sut.didFinish(result)

		// Then
		XCTAssertTrue(managerSpy.invokedConsentGiven)
		XCTAssertTrue(delegateSpy.invokedFinishForcedInformation)
	}
}
