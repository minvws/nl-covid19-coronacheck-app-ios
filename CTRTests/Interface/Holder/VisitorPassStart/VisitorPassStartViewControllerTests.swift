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

class VisitorPassStartViewControllerTests: XCTestCase {

	var sut: VisitorPassStartViewController!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var remoteConfigSpy: RemoteConfigManagingSpy!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		
		remoteConfigSpy = RemoteConfigManagingSpy()
		remoteConfigSpy.stubbedStoredConfiguration = .default
		Services.use(remoteConfigSpy)
		
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = VisitorPassStartViewController(
			viewModel: VisitorPassStartViewModel(
				coordinator: holderCoordinatorDelegateSpy
			)
		)
		window = UIWindow()
	}

	override func tearDown() {
		
		super.tearDown()
		Services.revertToDefaults()
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
		expect(self.sut.sceneView.title) == L.visitorpass_start_title()
		expect(self.sut.sceneView.message) == L.visitorpass_start_message()
		expect(self.sut.sceneView.primaryTitle) == L.visitorpass_start_action()
	}
	
	func test_actionButton() {
				
		// Given
		loadView()
		
		// When
		sut.sceneView.primaryButtonTapped()
		
		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAVisitorPass) == true
	}
}
