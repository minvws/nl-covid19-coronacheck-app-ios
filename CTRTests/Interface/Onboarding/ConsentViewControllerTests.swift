/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting

class ConsentViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: OnboardingConsentViewController!

	var coordinatorSpy: OnboardingCoordinatorSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()
		sut = OnboardingConsentViewController(
			viewModel: OnboardingConsentViewModel(
				coordinator: coordinatorSpy,
				factory: HolderOnboardingFactory(),
				shouldHideBackButton: true
			)
		)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		_ = sut.view
	}

	// MARK: Test

	/// Test all the content without consent
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderConsentTitle()
		expect(self.sut.sceneView.message) == L.holderConsentMessage()
		expect(self.sut.sceneView.itemStackView.arrangedSubviews).to(haveCount(2))

		sut.assertImage()
	}

	/// Test the user tapped on the link
	func testLink() {

		// Given
		loadView()

		// When
		sut.linkTapped()

		// Then
		expect(self.coordinatorSpy.invokedShowPrivacyPage) == true
	}

	/// Test the user tapped on the enabled primary button
	func testPrimaryButtonTappedEnabled() {

		// Given
		loadView()
		sut.sceneView.primaryButton.isEnabled = true

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorSpy.invokedConsentGiven) == true
	}

	/// Test the user tapped on the enabled primary button
	func testPrimaryButtonTappedDisabled() {

		// Given
		loadView()
		sut.sceneView.primaryButton.isEnabled = false

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorSpy.invokedConsentGiven) == false
	}
}
