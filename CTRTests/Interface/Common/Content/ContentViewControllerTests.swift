/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble

class ContentViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: ContentViewController!

	private var linkTapHandlerCalled = false
	private var backActionCalled = false
	private var primaryActionCalled = false
	private var secondaryActionCalled = false
	
	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		
		linkTapHandlerCalled = false
		backActionCalled = false
		primaryActionCalled = false
		secondaryActionCalled = false
		
		sut = ContentViewController(
			viewModel: ContentViewModel(
				content: Content(
					title: "Title",
					body: "Body",
					primaryActionTitle: "Primary Action",
					primaryAction: {
						self.primaryActionCalled = true
					},
					secondaryActionTitle: "Secondary Action",
					secondaryAction: {
						self.secondaryActionCalled = true
					}
				),
				backAction: {
					self.backActionCalled = true
				},
				allowsSwipeBack: true,
				linkTapHander: { _ in
					self.linkTapHandlerCalled = true
				}
			)
		)
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
		expect(self.sut.sceneView.title) == "Title"
		expect(self.sut.sceneView.message) == "Body"
		expect(self.sut.sceneView.primaryTitle) == "Primary Action"
		expect(self.sut.sceneView.secondaryButtonTitle) == "Secondary Action"
		
		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_primaryAction() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.primaryButtonTapped()
		
		// Then
		expect(self.primaryActionCalled).toEventually(beTrue())
	}
	
	func test_secondaryAction() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.secondaryButtonTapped()
		
		// Then
		expect(self.secondaryActionCalled).toEventually(beTrue())
	}
	
	func test_backButtonTapped() {
		
		// Given
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		expect(self.backActionCalled).toEventually(beTrue())
	}
}
