/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR
import Transport
import Nimble
import SnapshotTesting

class AppStatusViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: AppStatusViewController!
	private var appCoordinatorSpy: AppCoordinatorSpy!
	private var contactInfoSpy: ContactInfoSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUpWithError() throws {
		
		appCoordinatorSpy = AppCoordinatorSpy()
		contactInfoSpy = ContactInfoSpy()
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
	func test_holder_alert() {

		// Given
		let viewModel = UpdateRequiredViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil,
			flavor: .holder
		)
		sut = AppStatusViewController(viewModel: viewModel)
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		alertVerifier.verify(
			title: L.generalErrorTitle(),
			message: L.holder_updateApp_errorMessage(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)
	}

	/// Test showing the alert (should happen if no url is provided)
	func test_verifier_alert() {

		// Given
		let viewModel = UpdateRequiredViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil,
			flavor: .verifier
		)
		sut = AppStatusViewController(viewModel: viewModel)
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		alertVerifier.verify(
			title: L.generalErrorTitle(),
			message: L.verifier_updateApp_errorMessage(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)
	}
	
	func test_holder_updateRequired() {

		// Given
		let viewModel = UpdateRequiredViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil,
			flavor: .holder
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holder_updateApp_title()
		expect(self.sut.sceneView.message) == L.holder_updateApp_content()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.holder_updateApp_button()
		expect(self.sut.sceneView.image) == I.updateRequired()

		sut.assertImage()
	}
	
	func test_verifier_updateRequired() {

		// Given
		let viewModel = UpdateRequiredViewModel(
			coordinator: appCoordinatorSpy,
			appStoreUrl: nil,
			flavor: .verifier
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.verifier_updateApp_title()
		expect(self.sut.sceneView.message) == L.verifier_updateApp_content()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.verifier_updateApp_button()
		expect(self.sut.sceneView.image) == I.updateRequired()

		sut.assertImage()
	}

	func test_holder_endOfLife() {

		// Given
		let viewModel = AppDeactivatedViewModel(
			coordinator: appCoordinatorSpy,
			informationUrl: nil,
			flavor: .holder
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holder_endOfLife_title()
		expect(self.sut.sceneView.message) == L.holder_endOfLife_description()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.holder_endOfLife_button()
		expect(self.sut.sceneView.image) == I.endOfLife()

		sut.assertImage()
	}
	
	func test_verifier_endOfLife() {

		// Given
		let viewModel = AppDeactivatedViewModel(
			coordinator: appCoordinatorSpy,
			informationUrl: nil,
			flavor: .verifier
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.verifier_endOfLife_title()
		expect(self.sut.sceneView.message) == L.verifier_endOfLife_description()
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.verifier_endOfLife_button()
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
	
	func test_launchError() {
		
		// Given
		contactInfoSpy.stubbedPhoneNumberLink = "<a href=\"tel: 0800-1421\">0800-1421</a>"
		let viewModel = LaunchErrorViewModel(
			contactInfo: contactInfoSpy,
			errorCodes: [ErrorCode(flow: .onboarding, step: .configuration, errorCode: "123")],
			urlHandler: { _ in },
			closeHandler: {}
		)
		sut = AppStatusViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.appstatus_launchError_title()
		expect(self.sut.sceneView.message) == L.appstatus_launchError_body("i 010 000 123")
		expect(self.sut.sceneView.primaryButton.titleLabel?.text) == L.appstatus_launchError_button()
		expect(self.sut.sceneView.image) == I.launchError()

		sut.assertImage()
	}
}
