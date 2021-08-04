/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
@testable import CTR
import SnapshotTesting
import XCTest

class ShowQRViewTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	func testLoading() {
		let sut = ShowQRImageView()
		sut.visibilityState = .loading
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}

	func testHidden() {
		let sut = ShowQRImageView()
		sut.visibilityState = .hiddenForScreenCapture
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}

	func testScreenshotBlocking() {
		let sut = ShowQRImageView()
		sut.visibilityState = .screenshotBlocking(timeRemainingText: "123:34")
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}

	func testVisible() {
		let sut = ShowQRImageView()


		sut.visibilityState = .visible(
			qrImage: UIImage.withColor(.blue, size: CGSize(width: 200, height: 200))
		)
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
		sut.assertImage()
	}
}
