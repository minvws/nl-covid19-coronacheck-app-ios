/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Transport

class FuzzyMatchingCoordinatorTests: XCTestCase {
	
	var sut: FuzzyMatchingCoordinator!

	var navigationSpy: NavigationControllerSpy!
	
	var factorySpy: FuzzyMatchingOnboardingFactorySpy!

	var delegateSpy: FuzzyMatchingFlowSpy!

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		factorySpy = FuzzyMatchingOnboardingFactorySpy()
		delegateSpy = FuzzyMatchingFlowSpy()
		_ = setupEnvironmentSpies()
		sut = FuzzyMatchingCoordinator(
			navigationController: navigationSpy,
			factory: factorySpy,
			delegate: delegateSpy
		)
	}

	// MARK: - Tests

	/// Test the start method with update page
	func test_start_shouldNotInvokeFinishFlow() {

		// Given
		factorySpy.stubbedPages = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			image: nil,
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]

		// When
		sut.start()

		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == false
	}

	func test_onboardingFinished_shouldInvokeFinishFlow() {
		
		// Given
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(self.delegateSpy.invokedFuzzyMatchingFlowDidFinish) == true
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let universalLink = UniversalLink.redeemHolderToken(
			requestToken: RequestToken(
				token: "STXT2VF3389TJ2",
				protocolVersion: "3.0",
				providerIdentifier: "XXX"
			)
		)
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
	}
}

class FuzzyMatchingFlowSpy: FuzzyMatchingFlowDelegate {

	var invokedFuzzyMatchingFlowDidFinish = false
	var invokedFuzzyMatchingFlowDidFinishCount = 0

	func fuzzyMatchingFlowDidFinish() {
		invokedFuzzyMatchingFlowDidFinish = true
		invokedFuzzyMatchingFlowDidFinishCount += 1
	}
}

class FuzzyMatchingOnboardingFactorySpy: FuzzyMatchingOnboardingFactoryProtocol {

	var invokedPagesGetter = false
	var invokedPagesGetterCount = 0
	var stubbedPages: [PagedAnnoucementItem]! = []

	var pages: [PagedAnnoucementItem] {
		invokedPagesGetter = true
		invokedPagesGetterCount += 1
		return stubbedPages
	}
}
