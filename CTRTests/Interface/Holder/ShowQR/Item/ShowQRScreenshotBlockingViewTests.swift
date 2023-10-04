/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class ShowQRScreenshotBlockingViewTests: XCTestCase {

	func testContent() {
		let sut = ShowQRScreenshotBlockingView()
		sut.title = "ShowQRScreenshotBlockingView title"
		sut.subtitle = "ShowQRScreenshotBlockingView subtitle"
		sut.setCountdown(text: "ShowQRScreenshotBlockingView countdown", voiceoverText: "")

		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}
}
