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

final class VerifiedInfoViewControllerTests: XCTestCase {
	
	var sut: VerifiedInfoViewController!
	var coordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		sut = VerifiedInfoViewController(
			viewModel: VerifiedInfoViewModel(
				coordinator: coordinatorDelegateSpy
			)
		)
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_snapshot() {
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifierResultCheckTitle()
		expect(self.sut.sceneView.message) == L.verifierResultCheckText()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultCheckButton()
		expect(self.sut.sceneView.primaryButtonIcon) == I.deeplinkScan()
		
		sut.assertImage()
	}
}
