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

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()

		viewModel = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			verificationResult: MobilecoreVerificationResult()
		)
		sut = VerifierResultViewController(viewModel: viewModel)
	}

	func loadView() {
		_ = sut.view
	}

	// MARK: - Tests

	func testDemo() throws {

		// Given
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultDemoTitle()
		expect(self.sut.sceneView.message).to(beNil(), description: "Message should be nil")
		expect(self.sut.sceneView.imageView.image) == UIImage.access

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
		expect(self.sut.sceneView.message) == L.verifierResultDeniedMessage()
		expect(self.sut.sceneView.imageView.image) == UIImage.denied

		// Snapshot
		sut.assertImage()
	}

	func testVerified() throws {

		// Given
		let details = MobilecoreVerificationDetails()
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		viewModel.verificationResult = result
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultAccessTitle()
		expect(self.sut.sceneView.message).to(beNil(), description: "Message should be nil")
		expect(self.sut.sceneView.imageView.image) == UIImage.access

		// Snapshot
		sut.assertImage()
	}

	func testDismiss() {

		// Given

		// When
		sut.closeButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
 	}

    func testPrimaryButtonTapped() {

        // Given
        loadView()

        // When
        sut.sceneView.primaryButtonTapped()

        // Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScan) == true
    }

	func testLinkTapped() {

		// Given

		// When
		sut.linkTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
}
