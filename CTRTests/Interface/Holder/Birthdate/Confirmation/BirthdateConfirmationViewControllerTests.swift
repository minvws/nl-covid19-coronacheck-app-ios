/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR

class BirthdateConfirmationViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: BirthdateConfirmationViewController?

	/// Subject under test
	var viewModel: BirthdateConfirmationViewModel?

	/// The coordinator spy
	var birthdateCoordinatorDelegateSpy = BirthdateCoordinatorDelegateSpy()

	/// The proof manager spy
	var proofManagerSpy = ProofManagingSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	/// the date
	var date = Date()

	var window = UIWindow()

	override func setUp() {
		super.setUp()

		birthdateCoordinatorDelegateSpy = BirthdateCoordinatorDelegateSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		viewModel = BirthdateConfirmationViewModel(
			coordinator: birthdateCoordinatorDelegateSpy,
			proofManager: proofManagerSpy,
			date: date
		)

		sut = BirthdateConfirmationViewController( viewModel: viewModel!)
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

	// MARK: - Tests

	/// Test the dismiss method
	func testDismiss() {

		// Given
		loadView()

		// When
		sut?.closeButtonTapped()

		// Then
		XCTAssertTrue(birthdateCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}

	/// Test the primary button tapped method
	func testPrimaryButtonTapped() {

		// Given
		loadView()

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.confirmationView.isHidden, "Dialog should be shown")
	}

	/// Test the secondary button tapped method
	func testSecondaryButtonTapped() {

		// Given
		loadView()

		// When
		sut?.sceneView.secondaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(birthdateCoordinatorDelegateSpy.navigateBackToBirthdayEntryCalled, "Delegate method should be called")
	}

	/// Test the confirmation button tapped method
	func testConfirmButtonTapped() {

		// Given
		loadView()
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// When
		sut?.sceneView.confirmationView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.sceneView.confirmationView.isHidden, "Dialog should be shown")
		XCTAssertTrue(proofManagerSpy.setBirthDateCalled, "Method should be called")
		XCTAssertTrue(birthdateCoordinatorDelegateSpy.birthdateConfirmedCalled, "Delegate method should be called")
	}

	func testConsentButton() {

		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		// Given
		let button = ConsentButton()
		button.isSelected = true
		strongSut.sceneView.primaryButton.isEnabled = false
		
		// When
		sut?.consentValueChanged(button)

		// Then
		XCTAssertTrue(strongSut.sceneView.primaryButton.isEnabled, "button should be enable")
	}
}
