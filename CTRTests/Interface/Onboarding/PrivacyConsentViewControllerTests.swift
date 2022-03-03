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

class PrivacyConsentViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: PrivacyConsentViewController!

	var coordinatorSpy: OnboardingCoordinatorSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		coordinatorSpy = OnboardingCoordinatorSpy()
		sut = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
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
		sut = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
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
		sut = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
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
	
	/// Test verifier error consent state
	func testContent_verifier_errorState() {

		// Given
		sut = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
				coordinator: coordinatorSpy,
				factory: VerifierOnboardingFactory(),
				shouldHideBackButton: true
			)
		)

		// When
		loadView()
		sut.sceneView.hasErrorState = true

		// Then
		expect(self.sut.sceneView.title) == L.verifierConsentTitle()
		expect(self.sut.sceneView.message) == L.verifierConsentMessage()
		expect(self.sut.sceneView.itemStackView.arrangedSubviews).to(haveCount(3))

		sut.assertImage()
	}
	
	/// Test verifier selected state
	func testContent_verifier_selectedState() {

		// Given
		sut = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
				coordinator: coordinatorSpy,
				factory: VerifierOnboardingFactory(),
				shouldHideBackButton: true
			)
		)

		// When
		loadView()
		sut.sceneView.consentButton.isSelected = true

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
	func test_consentValueChanged_whenButtonSelectedIsTrue_shouldHideConsentError() {

		// Given
		loadView()
		let button = LabelWithCheckbox()
		button.isSelected = true

		// When
		sut.consentValueChanged(button)

		// Then
		expect(self.sut.viewModel.shouldDisplayConsentError) == false
	}

	/// Test the user tapped on the consent button
	func test_consentValueChanged_whenButtonSelectedIsFalse_shouldNotDisplayConsentError() {

		// Given
		loadView()
		let button = LabelWithCheckbox()
		button.isSelected = false

		// When
		sut.consentValueChanged(button)

		// Then
		expect(self.sut.viewModel.shouldDisplayConsentError) == false
	}

	/// Test the user tapped on the primary button
	func test_primaryButtonTapped_whenConsentButtonSelectedIsFalse_shouldNotGiveConsent() {

		// Given
		sut = PrivacyConsentViewController(
			viewModel: PrivacyConsentViewModel(
				coordinator: coordinatorSpy,
				factory: VerifierOnboardingFactory(),
				shouldHideBackButton: true
			)
		)
		loadView()
		sut.sceneView.primaryButton.isEnabled = true
		sut.sceneView.consentButton.isSelected = false
		
		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorSpy.invokedConsentGiven) == false
	}
	
	/// Test the user tapped on the primary button
	func test_primaryButtonTapped_whenConsentButtonSelectedIsTrue_shouldGiveConsent() {

		// Given
		loadView()
		sut.sceneView.primaryButton.isEnabled = true
		sut.sceneView.consentButton.isSelected = true

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorSpy.invokedConsentGiven) == true
	}
	
	/// Test the user tapped on the primary button for holder
	func test_primaryButtonTapped_whenConsentButtonIsHidden_shouldGiveConsent() {

		// Given
		loadView()
		sut.sceneView.primaryButton.isEnabled = true

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.coordinatorSpy.invokedConsentGiven) == true
	}
}
