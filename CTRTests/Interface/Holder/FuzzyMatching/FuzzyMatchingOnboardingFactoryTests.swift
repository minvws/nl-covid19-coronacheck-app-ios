/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

final class FuzzyMatchingOnboardingFactoryTests: XCTestCase {
	
	var sut: FuzzyMatchingOnboardingFactory!
	
	override func setUp() {
		
		super.setUp()
		sut = FuzzyMatchingOnboardingFactory()
	}
	
	func test_pages() {
		
		// Given
		
		// When
		let pages = sut.pages
		
		// Then
		expect(pages).to(haveCount(3))
		expect(pages[0].title) == L.holder_fuzzyMatching_onboarding_firstPage_title()
		expect(pages[1].title) == L.holder_fuzzyMatching_onboarding_secondPage_title()
		expect(pages[2].title) == L.holder_fuzzyMatching_onboarding_thirdPage_title()
	}
}
