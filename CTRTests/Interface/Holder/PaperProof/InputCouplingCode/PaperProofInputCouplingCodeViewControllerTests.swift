/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting

// swiftlint:disable:next type_name
class PaperProofInputCouplingCodeViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: PaperProofInputCouplingCodeViewController!
	private var coordinatorSpy: PaperProofCoordinatorDelegateSpy!
	private var viewModel: PaperProofInputCouplingCodeViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = PaperProofCoordinatorDelegateSpy()
		viewModel = PaperProofInputCouplingCodeViewModel(coordinator: coordinatorSpy)
		sut = PaperProofInputCouplingCodeViewController(viewModel: viewModel)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderDcctokenentryTitle()
		expect(self.sut.sceneView.header) == L.holderDcctokenentryHeader()
		expect(self.sut.sceneView.tokenEntryView.header) == L.holderDcctokenentryTokenFieldTitle()
		expect(self.sut.sceneView.tokenEntryFieldPlaceholder) == L.holderDcctokenentryTokenFieldPlaceholder()
		expect(self.sut.sceneView.primaryTitle) == L.holderDcctokenentryNext()
		expect(self.sut.sceneView.primaryButton.isEnabled) == true
		expect(self.sut.sceneView.fieldErrorMessage).to(beNil())
		expect(self.sut.sceneView.userNeedsATokenButtonTitle) == L.holderDcctokenentryButtonNotoken()
		expect(self.sut.sceneView.userNeedsATokenButton.isEnabled) == true

		sut.assertImage(containedInNavigationController: true)
	}

	func test_primaryButtonTapped_noInput() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.sut.sceneView.fieldErrorMessage) == L.holderDcctokenentryErrorEmptycode()
		expect(self.sut.sceneView.primaryButton.isEnabled) == true

		sut.assertImage(containedInNavigationController: true)
	}

	func test_primaryButtonTapped_wrongInput() {

		// Given
		loadView()
		// 1 is not in allowed alphabet
		viewModel.userDidUpdateTokenField(rawTokenInput: "123456")

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.sut.sceneView.fieldErrorMessage) == L.holderDcctokenentryErrorInvalidcode()
		expect(self.sut.sceneView.primaryButton.isEnabled) == true

		sut.assertImage(containedInNavigationController: true)
	}

	func test_primaryButtonTapped_correctInput() {

		// Given
		loadView()
		_ = sut.textField(sut.sceneView.tokenEntryView.inputField, shouldChangeCharactersIn: NSRange(), replacementString: "ABCDEF")

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.sut.sceneView.fieldErrorMessage).to(beNil())
		expect(self.coordinatorSpy.invokedUserDidSubmitPaperProofToken) == true
		expect(self.coordinatorSpy.invokedUserDidSubmitPaperProofTokenParameters?.token) == "ABCDEF"
	}

	func test_userNeedsATokenButtonTapped() {

		// Given
		loadView()

		// When
		sut.sceneView.userNeedsATokenButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedUserWishesMoreInformationOnNoInputToken) == true
	}
}
