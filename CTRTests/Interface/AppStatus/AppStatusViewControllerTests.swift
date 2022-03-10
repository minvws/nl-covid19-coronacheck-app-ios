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

class AppStatusViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: AppStatusViewController!
	private var appCoordinatorSpy: AppCoordinatorSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUpWithError() throws {
		
		appCoordinatorSpy = AppCoordinatorSpy()
		window = UIWindow()
		
		try super.setUpWithError()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: Test

	/// Test showing the alert (should happen if no url is provided)
	func test_alert() {

		// Given
		let viewModel = AppStatusViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil
		)
		sut = AppStatusViewController(viewModel: viewModel)
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		alertVerifier.verify(
			title: L.generalErrorTitle(),
			message: L.updateAppErrorMessage(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)
	}

	func test_updateRequired() {

		// Given
		let viewModel = AppStatusViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.updateAppTitle()
		expect(self.sut.sceneView.message) == L.updateAppContent()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.updateAppButton()
		expect(self.sut.sceneView.image) == I.updateRequired()

		sut.assertImage()
	}

	func test_endOfLife() {

		// Given
		let viewModel = AppDeactivatedViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.endOfLifeTitle()
		expect(self.sut.sceneView.message) == L.endOfLifeDescription()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.endOfLifeButton()
		expect(self.sut.sceneView.image) == I.endOfLife()

		sut.assertImage()
	}

	func test_noInternet() {

		// Given
		let viewModel = InternetRequiredViewModel(coordinator: appCoordinatorSpy)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.internetRequiredTitle()
		expect(self.sut.sceneView.message) == L.internetRequiredText()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.internetRequiredButton()
		expect(self.sut.sceneView.image) == I.noInternet()

		sut.assertImage()
	}
}
