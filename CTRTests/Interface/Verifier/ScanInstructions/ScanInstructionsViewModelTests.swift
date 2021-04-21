/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ScanInstructionsViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ScanInstructionsViewModel!

	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!

	override func setUp() {

		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		sut = ScanInstructionsViewModel(coordinator: verifyCoordinatorDelegateSpy)
	}

	// MARK: - Tests

	func test_defaultContent() {

		// Given

		// When

		// Then
		expect(self.sut.title) == .verifierScanInstructionsTitle
		expect(self.sut.content)
			.to(haveCount(4), description: "Number of elements should match")
	}

	func test_linkTapped() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.linkTapped(url)

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedOpenUrl) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedOpenUrlParameters?.url) == url
	}

	func test_primaryButtonTapped() {

		// Given

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishScanInstructionsResult) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedDidFinishScanInstructionsResultParameters?.result) == .scanInstructionsCompleted
	}
}
