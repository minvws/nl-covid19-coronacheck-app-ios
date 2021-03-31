/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR

class AboutViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: AboutViewController?

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		let viewModel = AboutViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder
		)

		sut = AboutViewController(viewModel: viewModel)
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

	/// Test all the content
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		guard let strongSut = sut else {

			XCTFail("Can not unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.title, .holderAboutTitle, "Text should match")
		XCTAssertEqual(strongSut.sceneView.message, .holderAboutText, "Text should match")
		XCTAssertNotNil(strongSut.sceneView.version, "Version should not be nil")
	}
}
