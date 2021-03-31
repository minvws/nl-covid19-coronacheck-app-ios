/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR

class LaunchViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: LaunchViewController?

	var appCoordinatorSpy = AppCoordinatorSpy()
	var versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")

	var remoteConfigSpy = RemoteConfigManagingSpy()
	var proofManagerSpy = ProofManagingSpy()

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")

		remoteConfigSpy = RemoteConfigManagingSpy()
		proofManagerSpy = ProofManagingSpy()

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy
		)

		sut = LaunchViewController(viewModel: viewModel)
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
		XCTAssertEqual(strongSut.sceneView.title, .holderLaunchTitle, "Text should match")
		XCTAssertEqual(strongSut.sceneView.message, .holderLaunchText, "Text should match")
		XCTAssertNotNil(strongSut.sceneView.version, "Version should not be nil")
		XCTAssertNotNil(strongSut.sceneView.appIcon, "Version should not be nil")
	}
}
