/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class SnapshotViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: SnapshotViewController?

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		sut = SnapshotViewController(
			viewModel: SnapshotViewModel(
				flavor: AppFlavor.holder
			)
		)
		window = UIWindow()
	}

	func loadView() {

		if let sut {
			window.addSubview(sut.view)
			RunLoop.current.run(until: Date())
		}
	}

	// MARK: Test

	/// Test all the content without consent
	func testContent() throws {

		// Given

		// When
		loadView()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.sceneView.appIcon, I.launch.holderAppIcon(), "Icon should match")
	}
}
