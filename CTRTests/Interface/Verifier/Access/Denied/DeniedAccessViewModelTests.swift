/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

final class DeniedAccessViewModelTests: XCTestCase {
	
	private var sut: DeniedAccessViewModel!
	
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
		
		sut = DeniedAccessViewModel(coordinator: verifierCoordinatorSpy)
	}
	
	func test_binding() {
		// Given
		
		// When
		
		// Then
		expect(self.sut.accessTitle) == L.verifierResultDeniedTitle()
		expect(self.sut.primaryTitle) == L.verifierResultNext()
		expect(self.sut.secondaryTitle) == L.verifierResultDeniedReadmore()
	}
	
	func test_dismiss_shouldNavigateBackToStart() {
		// Given
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_scanAgain_shouldScanAgain() {
		// Given
		
		// When
		sut.scanAgain()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToScan) == true
	}
	
	func test_showMoreInformation_shouldDisplayContent() {
		// Given
		
		// When
		sut.showMoreInformation()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedDisplayContent) == true
		expect(self.verifierCoordinatorSpy.invokedDisplayContentParameters?.title) == L.verifierDeniedTitle()
	}
}