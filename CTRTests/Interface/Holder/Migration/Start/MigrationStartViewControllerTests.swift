/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
import Shared
import TestingShared
@testable import Resources
@testable import ReusableViews

class MigrationStartViewControllerTests: XCTestCase {
	
	private var sut: ContentWithImageViewController!
	private var coordinatorDelegateSpy: MigrationCoordinatorDelegateSpy!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		coordinatorDelegateSpy = MigrationCoordinatorDelegateSpy()
		sut = ContentWithImageViewController(viewModel: MigrationStartViewModel(coordinator: coordinatorDelegateSpy))
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
		expect(self.sut.sceneView.title) == L.holder_startMigration_onboarding_title()
		expect(self.sut.sceneView.message) == L.holder_startMigration_onboarding_message()
		expect(self.sut.sceneView.primaryTitle) == L.holder_startMigration_onboarding_nextButton()
		expect(self.sut.sceneView.secondaryTitle) == nil
		expect(self.sut.sceneView.image) == I.migration()
		
		sut.assertImage(containedInNavigationController: true)
	}

	func test_nextButton() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserCompletedStart) == true
	}
}
