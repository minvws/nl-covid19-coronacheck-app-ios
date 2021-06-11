/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

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
		XCTAssertEqual(sut.sceneView.title, .holderConsentTitle, "Title should match")
		XCTAssertEqual(sut.sceneView.message, .holderConsentMessage, "Message should match")
		XCTAssertEqual(sut.sceneView.consent, .holderConsentButtonTitle, "Consent should match")
		XCTAssertEqual(sut.sceneView.itemStackView.arrangedSubviews.count, 2, "There should be 2 items")
	}

	/// Test the user tapped on the link
	func testLink() {

		// Given
		loadView()

		// When
		sut.linkTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.invokedShowPrivacyPage, "Method should be called")
	}

	/// Test the user tapped on the consent button
	func testConsentGivenTrue() {

		// Given
		loadView()
		let button = ConsentButton()
		button.isSelected = true

		// When
		sut.consentValueChanged(button)

		// Then
		XCTAssertTrue(sut.viewModel.isContinueButtonEnabled, "Button should be enabled")
	}

	/// Test the user tapped on the consent button
	func testConsentGivenFalse() {

		// Given
		loadView()
		let button = ConsentButton()
		button.isSelected = false

		// When
		sut.consentValueChanged(button)

		// Then
		XCTAssertFalse(sut.viewModel.isContinueButtonEnabled, "Button should not be enabled")
	}

	/// Test the user tapped on the enabled primary button
	func testPrimaryButtonTappedEnabled() {

		// Given
		loadView()
		sut.sceneView.primaryButton.isEnabled = true

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(coordinatorSpy.invokedConsentGiven, "Method should be called")
	}

	/// Test the user tapped on the enabled primary button
	func testPrimaryButtonTappedDisabled() {

		// Given
		loadView()
		sut.sceneView.primaryButton.isEnabled = false

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertFalse(coordinatorSpy.invokedConsentGiven, "Method should not be called")
	}
}
