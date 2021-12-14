/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

final class PaperProofStartViewModelTests: XCTestCase {
	
	var sut: PaperProofStartViewModel!
	var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		sut = PaperProofStartViewModel(coordinator: coordinatorDelegateSpy)
	}
	
	func test_initialState() {

		expect(self.sut.title) == L.holderPaperproofStartTitle()
		expect(self.sut.message) == L.holderPaperproofStartMessage()
		expect(self.sut.nextButtonTitle) == L.generalNext()
		expect(self.sut.selfPrintedButtonTitle) == L.holderPaperproofStartSelfprinted()
		expect(self.sut.items).to(haveCount(2))
		expect(self.sut.items[0].title) == L.holderPaperproofStartProviderTitle()
		expect(self.sut.items[0].message) == L.holderPaperproofStartProviderMessage()
		expect(self.sut.items[0].icon) == I.healthProvider()
		expect(self.sut.items[1].title) == L.holderPaperproofStartMailTitle()
		expect(self.sut.items[1].message) == L.holderPaperproofStartMailMessage()
		expect(self.sut.items[1].icon) == I.mail()

		PaperProofStartViewController(viewModel: sut).assertImage()
	}
	
	func test_primaryButtonTapped_shouldInvokeCoordinator() {

		// When
		sut.userTappedNextButton()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToEnterToken) == true
	}

	func test_secondaryButtonTapped_shouldInvokeCoordinator() {

		// When
		sut.userTappedSelfPrintedButton()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInformationOnSelfPrintedProof) == true
	}
}
