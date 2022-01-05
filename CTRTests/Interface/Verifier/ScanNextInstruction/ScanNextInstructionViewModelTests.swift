/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Clcore

final class ScanNextInstructionViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: ScanNextInstructionViewModel!
	
	private var verifierCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func test_bindings_test() {
		// Given
		sut = ScanNextInstructionViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			scanNext: .test
		)
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifier_scannextinstruction_title_test()
		expect(self.sut.subtitle) == L.verifier_scannextinstruction_subtitle()
		expect(self.sut.header) == L.verifier_scannextinstruction_header_test()
		expect(self.sut.primaryTitle) == L.verifier_scannextinstruction_button_scan_next_test()
		expect(self.sut.secondaryTitle) == L.verifier_scannextinstruction_button_deny_access_test()
	}
	
	func test_bindings_vaccinationOrRecovery() {
		// Given
		sut = ScanNextInstructionViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			scanNext: .vaccinationOrRecovery
		)
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifier_scannextinstruction_title_supplemental()
		expect(self.sut.subtitle) == L.verifier_scannextinstruction_subtitle()
		expect(self.sut.header) == L.verifier_scannextinstruction_header_supplemental()
		expect(self.sut.primaryTitle) == L.verifier_scannextinstruction_button_scan_next_supplemental()
		expect(self.sut.secondaryTitle) == L.verifier_scannextinstruction_button_deny_access_supplemental()
	}
	
	func test_scanNextQR_shouldNavigateToScan() {
		// Given
		sut = ScanNextInstructionViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			scanNext: .test
		)
		
		// When
		sut.scanNextQR()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToScan) == true
	}
	
	func test_denyAccess_shouldNavigateToDeniedAccess() {
		// Given
		sut = ScanNextInstructionViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			scanNext: .test
		)
		
		// When
		sut.denyAccess()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToDeniedAccess) == true
	}
}
