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

final class PaperCertificateStartViewModelTests: XCTestCase {
	
	var sut: PaperCertificateStartViewModel!
	var coordinatorDelegateSpy: PaperCertificateCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = PaperCertificateCoordinatorDelegateSpy()
		sut = PaperCertificateStartViewModel(coordinator: coordinatorDelegateSpy)
	}
	
	func test_initialState() {
		expect(self.sut.title) == L.holderPapercertificateStartTitle()
		expect(self.sut.message) == L.holderPapercertificateStartMessage()
		expect(self.sut.highlightedMessage) == L.holderPapercertificateStartHighlightedmessage()
		expect(self.sut.primaryButtonTitle) == L.generalNext()
		
		PaperCertificateStartViewController(viewModel: sut).assertImage()
	}
	
	func test_primaryButtonTapped_shouldInvokeCoordinator() {
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToEnterToken) == true
	}
}
