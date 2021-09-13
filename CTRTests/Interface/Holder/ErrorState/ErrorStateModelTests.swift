/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class ErrorStateViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ErrorStateViewModel!

	override func setUp() {

		super.setUp()
	}

	func test_init() {

		// Given
		let content = Content(title: "test", subTitle: "test", primaryActionTitle: "test", primaryAction: nil, secondaryActionTitle: "test", secondaryAction: nil)

		// when
		sut = ErrorStateViewModel(content: content, backAction: {})

		// Then
		expect(self.sut.content) == content
	}
}
