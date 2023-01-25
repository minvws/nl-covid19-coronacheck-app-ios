/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
import Shared

// swiftlint:disable:next type_name
class PaperProofStartScanningViewControllerTests: XCTestCase {

	private var sut: PaperProofStartScanningViewController!
	private var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		sut = PaperProofStartScanningViewController(viewModel: PaperProofStartScanningViewModel(coordinator: coordinatorDelegateSpy))
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests
	
	func test_content() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_paperproof_startscanning_title()
		expect(self.sut.sceneView.message) == L.holder_paperproof_startscanning_body()
		expect(self.sut.sceneView.primaryTitle) == L.holder_paperproof_startscanning_button_startScanning()
		expect(self.sut.sceneView.secondaryButton.title) == L.holder_paperproof_startscanning_button_whichProofs()
		expect(self.sut.sceneView.icon) == I.scannableQRs()
		
		sut.assertImage(containedInNavigationController: true)
	}

	func test_backButton() {
		
		// Given
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCancelPaperProofFlow) == true
	}
	
	func test_nextButton() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToScanCertificate) == true
	}
	
	func test_secondaryButton() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.secondaryButtonTapped()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInformationOnWhichProofsCanBeUsed) == true
	}
}
