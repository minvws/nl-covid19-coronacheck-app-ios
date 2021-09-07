/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class SnapshotViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: SnapshotViewController?

	var versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0", build: "test")

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0", build: "test")
		sut = SnapshotViewController(
			viewModel: SnapshotViewModel(
				versionSupplier: versionSupplierSpy,
				flavor: AppFlavor.holder
			)
		)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		if let sut = sut {
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
		XCTAssertEqual(strongSut.sceneView.title, L.holderLaunchTitle(), "Title should match")
		XCTAssertEqual(strongSut.sceneView.appIcon, I.launch.holderAppIcon(), "Icon should match")
	}
}
