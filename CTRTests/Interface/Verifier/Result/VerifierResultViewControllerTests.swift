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
				attributes: Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "test",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
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
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40

		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "1",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp40SecAgo)
				),
			errorMessage: nil
		)
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == .verifierResultDemoTitle
		expect(self.sut.sceneView.message).to(beNil(), description: "Message should be nil")
		expect(self.sut.sceneView.imageView.image) == UIImage.access

		// Snapshot
		sut.assertImage()
	}

	func testDemoFaultTime() throws {

		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "pcr",
						specimen: "1",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
			errorMessage: nil
		)
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == .verifierResultDeniedTitle
		expect(self.sut.sceneView.message) == .verifierResultDeniedMessage
		expect(self.sut.sceneView.imageView.image) == UIImage.denied

		// Snapshot
		sut.assertImage()
	}

	func testDenied() throws {

		// Given
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
			errorMessage: nil
		)
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == .verifierResultDeniedTitle
		expect(self.sut.sceneView.message) == .verifierResultDeniedMessage
		expect(self.sut.sceneView.imageView.image) == UIImage.denied

		// Snapshot
		sut.assertImage()
	}

	func testDenied48hours() throws {

		// Given
		let timeStamp48HoursAgo = Date().timeIntervalSince1970 - (48 * 60 * 60) - 40
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp48HoursAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(Date().timeIntervalSince1970)
				),
			errorMessage: nil
		)
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == .verifierResultDeniedTitle
		expect(self.sut.sceneView.message) == .verifierResultDeniedMessage
		expect(self.sut.sceneView.imageView.image) == UIImage.denied

		// Snapshot
		sut.assertImage()
	}

	func testVerified() throws {

		// Given
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40
		viewModel.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp40SecAgo)
				),
			errorMessage: nil
		)
		loadView()

		// When
		viewModel.checkAttributes()

		// Then
		expect(self.sut.sceneView.title) == .verifierResultAccessTitle
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
