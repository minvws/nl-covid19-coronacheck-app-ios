/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR

class AppUpdateViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: AppUpdateViewController?
	var appCoordinatorSpy = AppCoordinatorSpy()

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		let viewModel = AppUpdateViewModel(
			coordinator: appCoordinatorSpy,
			versionInformation: RemoteConfiguration(
				minVersion: "1.0",
				minVersionMessage: "AppUpdateViewControllerTests",
				storeUrl: nil
			)
		)

		sut = AppUpdateViewController(viewModel: viewModel)
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
		XCTAssertEqual(strongSut.sceneView.titleLabel.text, .updateAppTitle, "Text should match")
		XCTAssertEqual(strongSut.sceneView.messageLabel.text, "AppUpdateViewControllerTests", "Text should match")
		XCTAssertEqual(strongSut.sceneView.primaryButton.titleLabel?.text, .updateAppButton, "Text should match")
	}

	/// Test showing the alert (should happen if no url is provided)
	func testAlert() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		alertVerifier.verify(
			title: .errorTitle,
			message: .updateAppErrorMessage,
			animated: true,
			actions: [
				.default(.ok)
			],
			presentingViewController: sut
		)
	}
}
