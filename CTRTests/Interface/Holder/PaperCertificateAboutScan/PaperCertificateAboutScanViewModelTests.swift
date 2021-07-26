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

final class PaperCertificateAboutScanViewModelTests: XCTestCase {
	
	var sut: PaperCertificateAboutScanViewModel!
	var coordinatorDelegateSpy: PaperCertificateCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = PaperCertificateCoordinatorDelegateSpy()
		sut = PaperCertificateAboutScanViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_initialState() {
		expect(self.sut.title) == L.holderPapercertificateAboutscanTitle()
		expect(self.sut.message) == L.holderPapercertificateAboutscanMessage()
		expect(self.sut.primaryButtonTitle) == L.holderScannerTitle()
		
		PaperCertificateAboutScanViewController(viewModel: sut).assertImage()
	}
	
	func test_primaryButtonTapped_shouldInvokeCoordinator() {
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToScanCertificate) == true
	}
}
