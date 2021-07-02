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
			cryptoResults: CryptoResult(
				attributes: nil,
				errorMessage: nil
			),
			maxValidity: 48
		)
		sut = VerifierResultViewController(viewModel: viewModel)
	}

	func loadView() {
		_ = sut.view
	}

	// MARK: - Tests

	func testDemo() throws {

		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes: CryptoAttributes(
				birthDay: nil,
				birthMonth: nil,
				credentialVersion: nil,
				domesticDcc: "0",
				firstNameInitial: nil,
				lastNameInitial: nil,
				specimen: "1"
			),
			errorMessage: nil
		)
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
		viewModel.cryptoResults = CryptoResult(
			attributes: nil,
			errorMessage: "Invalid QR"
		)
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
	
	func testDeniedDomesticDcc() throws {
		
		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes: CryptoAttributes(
				birthDay: nil,
				birthMonth: nil,
				credentialVersion: nil,
				domesticDcc: "1",
				firstNameInitial: nil,
				lastNameInitial: nil,
				specimen: nil
			),
			errorMessage: "Invalid QR"
		)
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == L.verifierResultDeniedRegionTitle()
		expect(self.sut.sceneView.message) == L.verifierResultDeniedRegionMessage()
		expect(self.sut.sceneView.imageView.image) == UIImage.denied

		// Snapshot
		sut.assertImage()
	}

	func testVerified() throws {

		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes: CryptoAttributes(
				birthDay: nil,
				birthMonth: nil,
				credentialVersion: nil,
				domesticDcc: "0",
				firstNameInitial: nil,
				lastNameInitial: nil,
				specimen: "0"
			),
			errorMessage: nil
		)
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
