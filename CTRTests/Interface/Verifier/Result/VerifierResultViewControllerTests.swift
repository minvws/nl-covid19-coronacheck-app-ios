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
import Rswift
import Clcore

class VerifierResultViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: VerifierResultViewController!

	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: VerifierResultViewModel!
	
	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()

		viewModel = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			verificationResult: MobilecoreVerificationResult(),
			isDeepLinkEnabled: true
		)
		sut = VerifierResultViewController(viewModel: viewModel)
	}

	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func testDemo() throws {

		// Given
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		details.issuerCountryCode = "NL"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultDemoTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentityView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.checkIdentityView.dccScanned).to(beNil())
		expect(self.sut.sceneView.checkIdentityView.dccFlag).to(beNil())
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityDemo()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()

		// Snapshot
		sut.assertImage()
	}

	func testDeniedInvalidQR() throws {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_ERROR)
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultDeniedTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultNext()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultDeniedReadmore()
		expect(self.sut.navigationItem.accessibilityLabel).to(beNil())
		expect(self.sut.title).to(beNil())

		// Snapshot
		sut.assertImage()
	}

	func testVerified() throws {

		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "NL"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultAccessTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentityView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.checkIdentityView.dccScanned).to(beNil())
		expect(self.sut.sceneView.checkIdentityView.dccFlag).to(beNil())
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()

		// Snapshot
		sut.assertImage()
	}
	
	func testVerifiedDCC() throws {

		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "IT"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultAccessTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentityView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.checkIdentityView.dccScanned) == L.verifierResultAccessDcc()
		expect(self.sut.sceneView.checkIdentityView.dccFlag) == "🇮🇹"
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()

		// Snapshot
		sut.assertImage()
	}
	
	func testVerifiedDCCWithoutFlag() throws {

		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = ""
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultAccessTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentityView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.checkIdentityView.dccScanned) == L.verifierResultAccessDcc()
		expect(self.sut.sceneView.checkIdentityView.dccFlag).to(beNil())
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()

		// Snapshot
		sut.assertImage()
	}

	func test_dismiss_shouldNavigateToVerifierWelcome() {

		// Given

		// When
		sut.closeButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
 	}

    func test_scanNextTappedCommand_shouldNavigateToScan() {

        // Given
        loadView()

        // When
		sut.sceneView.scanNextTappedCommand?()

        // Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScan) == true
    }

	func test_readMoreTappedCommand_shouldDisplayContent() {

		// Given
		loadView()

		// When
		sut.sceneView.readMoreTappedCommand?()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
}
