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

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: Test

	/// Test all the content for the holder
	func testContent_holder() {

		// Given
		sut = OnboardingConsentViewController(
			viewModel: OnboardingConsentViewModel(
				coordinator: coordinatorSpy,
				factory: HolderOnboardingFactory(),
				shouldHideBackButton: true
			)
		)
		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderConsentTitle()
		expect(self.sut.sceneView.message) == L.holderConsentMessage()
		expect(self.sut.sceneView.itemStackView.arrangedSubviews).to(haveCount(2))

		sut.assertImage()
	}

	/// Test all the content for the verifier
	func testContent_verifier() {

		// Given
		sut = OnboardingConsentViewController(
			viewModel: OnboardingConsentViewModel(
				coordinator: coordinatorSpy,
				factory: VerifierOnboardingFactory(),
				shouldHideBackButton: true
			)
		)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.verifierConsentTitle()
		expect(self.sut.sceneView.message) == L.verifierConsentMessage()
		expect(self.sut.sceneView.itemStackView.arrangedSubviews).to(haveCount(3))

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

	/// Test the user tapped on the consent button
	func testConsentGivenTrue() {

		// Given
		loadView()
		let button = ConsentButton()
		button.isSelected = true

		// When
		sut.consentValueChanged(button)

		// Then
		expect(self.sut.viewModel.isContinueButtonEnabled) == true
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
		expect(self.sut.viewModel.isContinueButtonEnabled) == false
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
