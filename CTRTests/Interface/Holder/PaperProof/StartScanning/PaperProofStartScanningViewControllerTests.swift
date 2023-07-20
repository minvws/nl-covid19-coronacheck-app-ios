/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class PaperProofStartScanningViewControllerTests: XCTestCase { // swiftlint:disable:this type_name
	
	private var sut: ContentWithImageViewController!
	private var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	var window = UIWindow()
	
	override func setUp() {
		
		super.setUp()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		sut = ContentWithImageViewController(viewModel: PaperProofStartScanningViewModel(coordinator: coordinatorDelegateSpy))
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
		expect(self.sut.sceneView.secondaryTitle) == L.holder_paperproof_startscanning_button_whichProofs()
		expect(self.sut.sceneView.image) == I.scannableQRs()
		
		sut.assertImage(containedInNavigationController: true)
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
