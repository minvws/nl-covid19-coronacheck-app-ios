/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR

class BirthdateConfirmationViewModelTests: XCTestCase {

	/// Subject under test
	var sut: BirthdateConfirmationViewModel?

	/// The coordinator spy
	var birthdateCoordinatorDelegateSpy = BirthdateCoordinatorDelegateSpy()

	/// The proof manager spy
	var proofManagerSpy = ProofManagingSpy()

	/// The configuration spy
	var configSpy = ConfigurationGeneralSpy()

	/// the date
	var date = Date()

	override func setUp() {
		super.setUp()

		birthdateCoordinatorDelegateSpy = BirthdateCoordinatorDelegateSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		sut = BirthdateConfirmationViewModel(
			coordinator: birthdateCoordinatorDelegateSpy,
			proofManager: proofManagerSpy,
			date: date
		)
	}

	// MARK: - Test Doubles

	class BirthdateCoordinatorDelegateSpy: BirthdateCoordinatorDelegate & Dismissable {

		var navigateToBirthdayEntryCalled = false
		var navigateToBirthdayConfirmationCalled = false
		var navigateBackToBirthdayEntryCalled = false
		var birthdateConfirmedCalled = false
		var dismissCalled = false

		func navigateToBirthdayEntry() {

			navigateToBirthdayEntryCalled = true
		}

		func navigateToBirthdayConfirmation(_ date: Date) {

			navigateToBirthdayConfirmationCalled = true
		}

		func navigateBackToBirthdayEntry() {

			navigateBackToBirthdayEntryCalled = true
		}

		func birthdateConfirmed() {

			birthdateConfirmedCalled = true
		}

		func dismiss() {

			dismissCalled = true
		}
	}

	// MARK: - Tests

	/// Test all the default content
	func testContent() {

		// Given

		// When
		sut = BirthdateConfirmationViewModel(
			coordinator: birthdateCoordinatorDelegateSpy,
			proofManager: proofManagerSpy,
			date: date
		)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertNotNil(strongSut.message, "Message should not be nil")
		XCTAssertNotNil(strongSut.confirm, "Confirm should not be nil")
	}

	/// Test the dismiss method
	func testDismiss() {

		// Given

		// When
		sut?.dismiss()

		// Then
		XCTAssertTrue(birthdateCoordinatorDelegateSpy.dismissCalled, "Method should be called")
	}

	/// Test the primary button tapped method
	func testPrimaryButtonTapped() {

		// Given

		// When
		sut?.primaryButtonTapped()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.showDialog, "Dialog should be shown")
	}

	/// Test the secondary button tapped method
	func testSecondaryButtonTapped() {

		// Given

		// When
		sut?.secondaryButtonTapped()

		// Then
		XCTAssertTrue(birthdateCoordinatorDelegateSpy.navigateBackToBirthdayEntryCalled, "Delegate method should be called")
	}

	/// Test the confirmation button tapped method
	func testConfirmButtonTapped() {

		// Given

		// When
		sut?.confirmButtonTapped()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showDialog, "Dialog should be removed")
		XCTAssertTrue(proofManagerSpy.setBirthDateCalled, "Method should be called")
		XCTAssertTrue(birthdateCoordinatorDelegateSpy.birthdateConfirmedCalled, "Delegate method should be called")
	}
}
