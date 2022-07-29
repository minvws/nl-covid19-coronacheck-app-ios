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
import ViewControllerPresentationSpy

class VerifierStartScanningViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: VerifierStartScanningViewController!

	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: VerifierStartScanningViewModel!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()

		viewModel = VerifierStartScanningViewModel(coordinator: verifyCoordinatorDelegateSpy)
		sut = VerifierStartScanningViewController(viewModel: viewModel)
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
		expect(self.sut.sceneView.fakeNavigationTitle) == L.verifierStartTitle()
		expect(self.sut.sceneView.headerTitle) == nil
		expect(self.sut.sceneView.message) == L.verifierStartMessage()
		expect(self.sut.sceneView.showInstructionsTitle) == L.verifierStartButtonShowinstructions()
		expect(self.sut.sceneView.primaryTitle) == L.verifierStartButtonTitle()

		// Snapshot
		sut.assertImage(precision: 0.98)
	}

	func test_primaryButtonTapped_noScanInstructionsShown() {

		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToInstructionsOrRiskSetting), description: "Result should match")
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownGetter) == true
	}

	func test_primaryButtonTapped_scanInstructionsShown_havePublicKeys() {

		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.cryptoManagerSpy.stubbedHasPublicKeysResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScan), description: "Result should match")
	}

	func test_primaryButtonTapped_scanInstructionsShown_noPublicKeys() {

		// Given
		let alertVerifier = AlertVerifier()
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.cryptoManagerSpy.stubbedHasPublicKeysResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		alertVerifier.verify(
			title: L.generalErrorTitle(),
			message: L.verifierStartOntimeinternet(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
	}

	func test_howInstructionsButtonTapped() {

		// Given
		loadView()

		// When
		sut.sceneView.showInstructionsButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScanInstructions), description: "Result should match")
		expect(self.environmentSpies.userSettingsSpy.invokedScanInstructionShownGetter) == false
	}
}
