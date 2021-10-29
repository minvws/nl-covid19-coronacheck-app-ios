/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ShowQRViewItemControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ShowQRItemViewController!

	var delegateSpy: ShowQRItemViewModelDelegateSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManaging!
	var screenCaptureDetector: ScreenCaptureDetectorSpy!
	var userSettingsSpy: UserSettingsSpy!
	var viewModel: ShowQRItemViewModel!
	var remoteConfigManagingSpy: RemoteConfigManagingSpy!
	var window = UIWindow()

	// MARK: Test lifecycle

	override func setUpWithError() throws {

		try super.setUpWithError()
		dataStoreManager = DataStoreManager(.inMemory)
		delegateSpy = ShowQRItemViewModelDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()
		screenCaptureDetector = ScreenCaptureDetectorSpy()
		userSettingsSpy = UserSettingsSpy()
		remoteConfigManagingSpy = RemoteConfigManagingSpy(now: { now }, userSettings: UserSettingsSpy(), networkManager: NetworkSpy())
		remoteConfigManagingSpy.stubbedStoredConfiguration = .default
		remoteConfigManagingSpy.stubbedAppendReloadObserverResult = UUID()
		remoteConfigManagingSpy.stubbedAppendUpdateObserverResult = UUID()
		
		Services.use(cryptoManagerSpy)
		Services.use(remoteConfigManagingSpy)

		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		viewModel = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		sut = ShowQRItemViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

//	// MARK: - Tests

	func test_content_domestic() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		viewModel = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			userSettings: userSettingsSpy
		)
		sut = ShowQRItemViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.accessibilityDescription) == L.holderShowqrDomesticQrTitle()
	}

	/// Test the validity of the credential without credential
	func test_content_euGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			userSettings: userSettingsSpy
		)
		sut = ShowQRItemViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.accessibilityDescription) == L.holderShowqrEuQrTitle()
	}

	/// Test the validity of the credential with valid credential while screencapturing
	func testValidityCredentialValidWithScreenCapture() {

		// Given
		loadView()
		sut?.checkValidity()

		// When
		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(true)

		// Then
		expect(self.sut.sceneView.largeQRimageView.isHidden) == true
	}
}
