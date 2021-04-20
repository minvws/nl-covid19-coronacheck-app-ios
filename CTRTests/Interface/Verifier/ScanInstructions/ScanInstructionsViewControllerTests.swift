/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ScanInstructionsViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ScanInstructionsViewController!

	var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	var viewModel: ScanInstructionsViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()

		viewModel = ScanInstructionsViewModel(coordinator: verifyCoordinatorDelegateSpy)
		sut = ScanInstructionsViewController(viewModel: viewModel)
		window = UIWindow()
	}

	func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content() throws {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.title) == .verifierScanInstructionsTitle
		expect(self.sut.sceneView.stackView.arrangedSubviews)
			.to(haveCount(10), description: "There should be 10 items")
	}

	func test_primaryButtonTapped() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishScanInstructionsResult) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishScanInstructionsResultParameters?.result) == .scanInstructionsCompleted
	}
}
