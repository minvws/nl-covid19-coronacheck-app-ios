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

class ShowQRViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ShowQRViewController!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var configSpy: ConfigurationGeneralSpy!
	var dataStoreManager: DataStoreManaging!
	var viewModel: ShowQRViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle

	override func setUpWithError() throws {

		try super.setUpWithError()
		dataStoreManager = DataStoreManager(.inMemory)
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		configSpy = ConfigurationGeneralSpy()
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			cryptoManager: cryptoManagerSpy,
			configuration: configSpy
		)
		sut = ShowQRViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	/// Test all the default content
	func test_content_domesticGreenCard() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrDomesticTitle()
		expect(self.sut.sceneView.largeQRimageView.isHidden) == false
	}

	func test_content_euGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			cryptoManager: cryptoManagerSpy,
			configuration: configSpy
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.largeQRimageView.isHidden) == false
	}

	/// Test the validity of the credential without credential
	func test_withoutCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			cryptoManager: cryptoManagerSpy,
			configuration: configSpy
		)
		sut = ShowQRViewController(viewModel: viewModel)
		loadView()

		// When
		sut?.checkValidity()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
	}

	/// Test the validity of the credential with valid credential while screencapturing
	func testValidityCredentialValidWithScreenCapture() {

		// Given
		loadView()
		sut?.checkValidity()

		// When
		viewModel?.hideForCapture = true

		// Then
		expect(self.sut.sceneView.largeQRimageView.isHidden) == true
	}

	/// Test the security features
	func testSecurityFeaturesAnimation() {

		// Given
		loadView()
		sut?.checkValidity()

		// When
		sut?.sceneView.securityView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.sut.sceneView.largeQRimageView.isHidden) == false
		expect(self.sut.sceneView.securityView.currentAnimation) == .domesticAnimation
	}

	/// Test showing the alert dialog for screen shots
	func testAlertDialog() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		viewModel.handleScreenShot()

		// Then
		alertVerifier.verify(
			title: L.holderEnlargedScreenshotTitle(),
			message: L.holderEnlargedScreenshotMessage(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)
	}
}
