/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class ShowQRItemViewTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	func testLoading() {
		let sut = ShowQRItemView()
		sut.visibilityState = .loading
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}

	func testHidden() {
		let sut = ShowQRItemView()
		sut.visibilityState = .hiddenForScreenCapture
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}

	func testScreenshotBlocking() {
		let sut = ShowQRItemView()
		sut.visibilityState = .screenshotBlocking(timeRemainingText: "0:02", voiceoverTimeRemainingText: "in twee seconden")
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage(precision: 0.98)
	}

	func testVisible() {
		let sut = ShowQRItemView()

		sut.visibilityState = .visible(
			qrImage: UIImage.withColor(.blue, size: CGSize(width: 200, height: 200))
		)
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}
}
