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

	var navigationSpy = NavigationControllerSpy()

	var managerSpy = ForcedInformationManagerSpy()

	var delegateSpy = ForcedInformationDelegateSpy()

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

	/// Test the start method with consent content
	func testStartWithConsent() {

		// Given
		managerSpy.stubbedGetConsentResult = ForcedInformationConsent(
			title: "Test",
			highlight: "Test",
			content: "Test",
			consentMandatory: true
		)

		// When
		sut.start()

		// Then
		XCTAssertTrue(navigationSpy.viewControllers.count == 1)
		XCTAssertFalse(delegateSpy.invokedFinishForcedInformation)
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
		sut.didFinishConsent(result)

		// Then
		XCTAssertTrue(managerSpy.invokedConsentGiven)
		XCTAssertTrue(delegateSpy.invokedFinishForcedInformation)
	}

	/// Test the did finish method with consent viewed
	func testDidFinishConsentViewed() {

		// Given
		let result = ForcedInformationResult.consentViewed

		// When
		sut.didFinishConsent(result)

		// Then
		XCTAssertTrue(managerSpy.invokedConsentGiven)
		XCTAssertTrue(delegateSpy.invokedFinishForcedInformation)
	}
}
