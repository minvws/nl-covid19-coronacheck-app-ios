/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR
import Nimble
import SnapshotTesting

class AppUpdateViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: AppUpdateViewController!
	private var appCoordinatorSpy: AppCoordinatorSpy!

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
				storeUrl: nil,
				deactivated: nil,
				informationURL: nil,
				configTTL: 3600,
				maxValidityHours: 48
			)
		)

		sut = AppUpdateViewController(viewModel: viewModel)
		window = UIWindow()

//		isRecording = true
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: Test

	/// Test all the content
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == .updateAppTitle
		expect(self.sut.sceneView.message) == "AppUpdateViewControllerTests"
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == .updateAppButton
	}

	/// Test showing the alert (should happen if no url is provided)
	func testAlert() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

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

	func test_noInternet() {

		// Given
		let viewModel = InternetRequiredViewModel(coordinator: appCoordinatorSpy)
		sut = AppUpdateViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == .internetRequiredTitle
		expect(self.sut.sceneView.message) == .internetRequiredText
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == .internetRequiredButton
		expect(self.sut.sceneView.image) == .noInternet

		sut.assertImage()
	}
}
