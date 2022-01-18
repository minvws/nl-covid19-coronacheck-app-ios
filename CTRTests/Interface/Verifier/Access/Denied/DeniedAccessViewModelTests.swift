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
	private var environmentSpies: EnvironmentSpies!
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func test_deniedAccessReason_invalid() {
		// Given
		sut = DeniedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			deniedAccessReason: .invalid
		)
		
		// When
		
		// Then
		expect(self.sut.accessTitle) == L.verifierResultDeniedTitle()
		expect(self.sut.primaryTitle) == L.verifierResultNext()
		expect(self.sut.secondaryTitle) == L.verifierResultDeniedReadmore()
	}
	
	func test_deniedAccessReason_identityMismatch() {
		// Given
		sut = DeniedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			deniedAccessReason: .identityMismatch
		)
		
		// When
		
		// Then
		expect(self.sut.accessTitle) == L.verifier_result_denied_personal_data_mismatch_title()
		expect(self.sut.primaryTitle) == L.verifierResultNext()
		expect(self.sut.secondaryTitle).to(beNil())
	}
	
	func test_dismiss_shouldNavigateBackToStart() {
		// Given
		sut = DeniedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			deniedAccessReason: .invalid
		)
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_scanAgain_shouldScanAgain() {
		// Given
		sut = DeniedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			deniedAccessReason: .invalid
		)
		
		// When
		sut.scanAgain()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToScan) == true
	}
	
	func test_showMoreInformation_shouldDisplayContent() {
		// Given
		sut = DeniedAccessViewModel(
			coordinator: verifierCoordinatorSpy,
			deniedAccessReason: .invalid
		)
		
		// When
		sut.showMoreInformation()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedUserWishesMoreInfoAboutDeniedQRScan) == true
	}
}
