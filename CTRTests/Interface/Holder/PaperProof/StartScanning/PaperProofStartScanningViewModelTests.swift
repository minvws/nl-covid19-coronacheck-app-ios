/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

final class PaperProofStartScanningViewModelTests: XCTestCase {
	
	var sut: PaperProofStartScanningViewModel!
	var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		sut = PaperProofStartScanningViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_initialState() {
		expect(self.sut.title) == L.holderPaperproofStartscanningTitle()
		expect(self.sut.message) == L.holderPaperproofStartscanningMessage()
		expect(self.sut.nextButtonTitle) == L.holderPaperproofStartscanningAction()
		expect(self.sut.internationalTitle) == L.holderPaperproofStartscanningInternational()
		expect(self.sut.internationalQROnly) == I.internationalQROnly()
		
		PaperProofStartScanningViewController(viewModel: sut).assertImage()
	}
	
	func test_nextButtonTapped_shouldInvokeCoordinator() {

		// When
		sut.userTappedNextButton()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToScanCertificate) == true
	}

	func test_internationButtonTapped_shouldInvokeCoordinator() {

		// When
		sut.userTappedInternationalButton()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInformationOnInternationalQROnly) == true
	}
}
