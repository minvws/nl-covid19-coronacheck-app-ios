/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

final class VerifiedAccessViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: VerifiedAccessViewModel!
	
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func test_dismiss_shouldNavigateBackToStart() {
		// Given
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedType: .verified(.low)
		)
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_accessTitle_demoLowRisk() {
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedType: .demo(.low)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifierResultAccessTitle()
	}
	
	func test_accessTitle_demoHighRisk() {
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedType: .demo(.high)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_highrisk()
	}
	
	func test_accessTitle_verifiedLowRisk() {
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedType: .verified(.low)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifierResultAccessTitle()
	}
	
	func test_accessTitle_verifiedHighRisk() {
		// Given
		
		// When
		sut = VerifiedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			verifiedType: .verified(.high)
		)
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_access_title_highrisk()
	}
}
