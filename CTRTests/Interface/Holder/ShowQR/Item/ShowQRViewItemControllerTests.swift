/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Shared
import ReusableViews
import TestingShared
import Persistence

class ShowQRViewItemControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ShowQRItemViewController!

	var delegateSpy: ShowQRItemViewModelDelegateSpy!
	var screenCaptureDetector: ScreenCaptureDetectorSpy!
	var viewModel: ShowQRItemViewModel!
	var window = UIWindow()
	private var environmentSpies: EnvironmentSpies!
	
	// MARK: Test lifecycle

	override func setUpWithError() throws {

		try super.setUpWithError()
		environmentSpies = setupEnvironmentSpies()
		delegateSpy = ShowQRItemViewModelDelegateSpy()
		screenCaptureDetector = ScreenCaptureDetectorSpy()

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		viewModel = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			disclosurePolicy: .policy3G,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)
		sut = ShowQRItemViewController(viewModel: viewModel)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content_domestic() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		viewModel = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			disclosurePolicy: .policy3G,
			state: .regular
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
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			disclosurePolicy: nil,
			state: .regular
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
