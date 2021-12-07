/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble
import ViewControllerPresentationSpy

class VerifierStartViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: VerifierStartViewController!

	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: VerifierStartViewModel!
	private var cryptoManagerSpy: CryptoManagerSpy!
	private var cryptoLibUtilitySpy: CryptoLibUtilitySpy!
	private var clockDeviationManagerSpy: ClockDeviationManagerSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	private var scanLockManagerSpy: ScanLockManagerSpy!
	private var scanLogManagerSpy: ScanLogManagingSpy!
	
	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		riskLevelManagerSpy = RiskLevelManagerSpy()
		riskLevelManagerSpy.stubbedAppendObserverResult = UUID()
		scanLockManagerSpy = ScanLockManagerSpy()
		scanLockManagerSpy.stubbedAppendObserverResult = UUID()
		
		cryptoLibUtilitySpy = CryptoLibUtilitySpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			fileStorage: FileStorage(),
			flavor: AppFlavor.verifier
		)
		clockDeviationManagerSpy = ClockDeviationManagerSpy()
		clockDeviationManagerSpy.stubbedHasSignificantDeviation = false
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = (false, ())
		clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverResult = ClockDeviationManager.ObserverToken()
		userSettingsSpy = UserSettingsSpy()
		scanLogManagerSpy = ScanLogManagingSpy()
		Services.use(cryptoLibUtilitySpy)
		Services.use(cryptoManagerSpy)
		Services.use(clockDeviationManagerSpy)
		Services.use(scanLogManagerSpy)

		viewModel = VerifierStartViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			scanLockProvider: scanLockManagerSpy,
			riskLevelProvider: riskLevelManagerSpy,
			userSettings: userSettingsSpy
		)
		sut = VerifierStartViewController(viewModel: viewModel)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
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
		expect(self.sut.title) == L.verifierStartTitle()
		expect(self.sut.sceneView.title) == L.verifierStartHeader()
		expect(self.sut.sceneView.message) == L.verifierStartMessage()
		expect(self.sut.sceneView.showInstructionsTitle) == L.verifierStartButtonShowinstructions()
		expect(self.sut.sceneView.primaryTitle) == L.verifierStartButtonTitle()

		// Snapshot
		sut.assertImage()
	}

	func test_primaryButtonTapped_noScanInstructionsShown() {

		// Given
		userSettingsSpy.stubbedScanInstructionShown = false
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinish) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishParameters?.result)
			.to(equal(.userTappedProceedToScanInstructions), description: "Result should match")
		expect(self.userSettingsSpy.invokedScanInstructionShownGetter) == true
	}

	func test_primaryButtonTapped_scanInstructionsShown_havePublicKeys() {

		// Given
		userSettingsSpy.stubbedScanInstructionShown = true
		cryptoManagerSpy.stubbedHasPublicKeysResult = true
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
		userSettingsSpy.stubbedScanInstructionShown = true
		cryptoManagerSpy.stubbedHasPublicKeysResult = false
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
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
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
		expect(self.userSettingsSpy.invokedScanInstructionShownGetter) == false
	}
}
