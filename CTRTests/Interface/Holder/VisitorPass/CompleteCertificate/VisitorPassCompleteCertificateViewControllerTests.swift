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

// swiftlint:disable:next type_name
class VisitorPassCompleteCertificateViewControllerTests: XCTestCase {

	var sut: VisitorPassCompleteCertificateViewController!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = VisitorPassCompleteCertificateViewController(
			viewModel: VisitorPassCompleteCertificateViewModel(
				coordinatorDelegate: holderCoordinatorDelegateSpy
			)
		)
		window = UIWindow()
	}
	
	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_content() {
	
		// Given
		
		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holder_completecertificate_title()
		expect(self.sut.sceneView.message) == L.holder_completecertificate_body()
		expect(self.sut.sceneView.primaryTitle) == L.holder_completecertificate_button_fetchnegativetest()
		expect(self.sut.sceneView.secondaryButtonTitle) == L.holder_completecertificate_button_makeappointement()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_primaryActionButtonTapped_shouldCallCoordinator_toNavigate() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateANegativeTestQR) == true
	}
	
	func test_secondaryActionButtonTapped_shouldCallCoordinator_toOpenUrl() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.secondaryButtonTapped()
		
		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
}
