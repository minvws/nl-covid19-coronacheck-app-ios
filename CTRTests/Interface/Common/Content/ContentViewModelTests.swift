/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

final class ContentViewModelTests: XCTestCase {
	
	var sut: ContentViewModel!

	private var linkTapHandlerCalled = false
	private var backActionCalled = false

	override func setUp() {
		super.setUp()

		linkTapHandlerCalled = false
		backActionCalled = false
		sut = ContentViewModel(
			content: Content(title: "test"),
			backAction: {
				self.backActionCalled = true
			},
			allowsSwipeBack: true,
			linkTapHander: { _ in
				self.linkTapHandlerCalled = true
			}
		)
	}
	
	func test_content() {

		// Given

		// When

		// Then
		expect(self.sut.content) == Content(title: "test")
		expect(self.sut.allowsSwipeBack) == true
	}

	func test_openURL() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Assert
		expect(self.linkTapHandlerCalled).toEventually(beTrue())
	}

	func test_backButton() {

		// Given

		// When
		sut.backButtonTapped()

		// Then
		expect(self.backActionCalled).toEventually(beTrue())
	}
}
