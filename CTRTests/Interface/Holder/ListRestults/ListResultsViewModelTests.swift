/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ListResultsViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ListResultsViewModel?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	/// The proof manager spy
	var proofManagingSpy = ProofManagingSpy()

	/// Date parser
	private lazy var parseDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()

	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		proofManagingSpy = ProofManagingSpy()
		sut = ListResultsViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			proofManager: proofManagingSpy,
			maxValidity: 48
		)
	}

	// MARK: - Tests

	/// Test the check result method with a pending test result
	func testCheckResultPending() {

		// Given
		let pendingWrapper = TestResultWrapper(
			providerIdentifier: "testCheckResultPending",
			protocolVersion: "1.0",
			result: nil,
			status: .pending
		)
		proofManagingSpy.testResultWrapper = pendingWrapper

		// When
		sut?.checkResult()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsPendingTitle, "Title should match")
		XCTAssertEqual(sut?.message, .holderTestResultsPendingText, "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test the check result method with a not negative test result
	func testCheckResultNotNegative() {

		// Given
		let notNegativeWrapper = TestResultWrapper(
			providerIdentifier: "testCheckResultNotNegative",
			protocolVersion: "1.0",
			result: TestResult(
				unique: "testCheckResultNotNegative",
				sampleDate: "now",
				testType: "test",
				negativeResult: false,
				holder: nil,
				checksum: nil
			),
			status: .complete
		)
		proofManagingSpy.testResultWrapper = notNegativeWrapper

		// When
		sut?.checkResult()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test the check result method with a too old test result
	func testCheckResultTooOld() {

		// Given
		let tooOldWrapper = TestResultWrapper(
			providerIdentifier: "testCheckResultTooOld",
			protocolVersion: "1.0",
			result: TestResult(
				unique: "testCheckResultTooOld",
				sampleDate: "2021-02-01T00:00:00+00:00",
				testType: "test",
				negativeResult: true,
				holder: nil,
				checksum: nil
			),
			status: .complete
		)
		proofManagingSpy.testResultWrapper = tooOldWrapper

		// When
		sut?.checkResult()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test the check result method with a too old test result
	func testCheckResultTooNew() {

		// Given
		let now = Date().timeIntervalSince1970 + 200

		let tooOldWrapper = TestResultWrapper(
			providerIdentifier: "testCheckResultTooNew",
			protocolVersion: "1.0",
			result: TestResult(
				unique: "testCheckResultTooNew",
				sampleDate: parseDateFormatter.string(from: Date(timeIntervalSince1970: now)),
				testType: "test",
				negativeResult: true,
				holder: nil,
				checksum: nil
			),
			status: .complete
		)
		proofManagingSpy.testResultWrapper = tooOldWrapper

		// When
		sut?.checkResult()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test the check result method with a too old test result
	func testCheckResultValid() {

		// Given
		let now = Date().timeIntervalSince1970 - 200

		let tooOldWrapper = TestResultWrapper(
			providerIdentifier: "testCheckResultValid",
			protocolVersion: "1.0",
			result: TestResult(
				unique: "testCheckResultValid",
				sampleDate: parseDateFormatter.string(from: Date(timeIntervalSince1970: now)),
				testType: "test",
				negativeResult: true,
				holder: nil,
				checksum: nil
			),
			status: .complete
		)
		proofManagingSpy.testResultWrapper = tooOldWrapper

		// When
		sut?.checkResult()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, .holderTestResultsResultsText, "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsResultsButton, "Button should match")
		XCTAssertNotNil(sut?.listItem, "Selected item should NOT be nil")
		XCTAssertEqual(sut?.listItem?.identifier, "testCheckResultValid", "Identifier should match")
	}

	/// Test tap on the next button with an item selected
	func testButtonTappedListItemNotNil() {

		// Given
		sut?.listItem = ListResultItem(identifier: "test", date: "test")

		// When
		sut?.buttonTapped()

		// Then
		XCTAssertTrue(proofManagingSpy.fetchIssuerPublicKeysCalled, "Step 1 should be executed")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showAlert, "Alert should not be shown")
	}

	/// Test tap on the next button with no item selected
	func testButtonTappedListItemNil() {

		// Given
		sut?.listItem = nil

		// When
		sut?.buttonTapped()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Delegate method should be called")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showAlert, "Alert should not be shown")
	}

	/// Test tap on the close button with an item selected
	func testDismissListItemNotNil() {

		// Given
		sut?.listItem = ListResultItem(identifier: "test", date: "test")

		// When
		sut?.dismiss()

		// Then
		XCTAssertFalse(proofManagingSpy.fetchNonceCalled, "Step 1 should be not executed")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.showAlert, "Alert should be shown")
	}

	/// Test tap on the close button with no item selected
	func testDismissListItemNil() {

		// Given
		sut?.listItem = nil

		// When
		sut?.dismiss()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Delegate method should be called")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showAlert, "Alert should not be shown")
	}

	/// Test step one with an error
	func testStepOneIssuerPublicKeysError() {

		// Given
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagingSpy.issuerPublicKeyError = error

		// When
		sut?.createProofStepOne()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertTrue(strongSut.showError, "Error should not be nil")
		XCTAssertFalse(strongSut.showProgress, "Progress should not be shown")
	}

	/// Test step one without an error
	func testStepOneIssuerPublicKeysNoError() {

		// Given
		proofManagingSpy.shouldIssuerPublicKeyComplete = true

		// When
		sut?.createProofStepOne()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertTrue(proofManagingSpy.fetchNonceCalled, "Step 2 should be called")
		XCTAssertTrue(strongSut.showProgress, "Progress should be shown")
	}

	/// Test step two with an error
	func testStepTwoNonceError() {

		// Given
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagingSpy.nonceError = error

		// When
		sut?.createProofStepTwo()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertTrue(strongSut.showError, "Error should not be nil")
		XCTAssertFalse(strongSut.showProgress, "Progress should not be shown")
	}

	/// Test step one without an error
	func testStepTwoNonceNoError() {

		// Given
		proofManagingSpy.shouldNonceComplete = true

		// When
		sut?.createProofStepTwo()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertTrue(proofManagingSpy.fetchSignedTestResultCalled, "Step 2 should be called")
		XCTAssertTrue(strongSut.showProgress, "Progress should be shown")
	}

	/// Test step three with an error
	func testStepThreeWithError() {

		// Given
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagingSpy.signedTestResultError = error

		// When
		sut?.createProofStepThree()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertTrue(strongSut.showError, "Error should not be nil")
		XCTAssertFalse(strongSut.showProgress, "Progress should not be shown")
	}

	/// Test step three with a valid result
	func testStepThreeWithValidResult() {

		// Given
		proofManagingSpy.shouldSignedTestResultComplete = true
		proofManagingSpy.signedTestResultState = .valid

		// When
		sut?.createProofStepThree()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertFalse(strongSut.showError, "Error should be false")
		XCTAssertFalse(strongSut.showProgress, "Progress should not be shown")
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToCreateProofCalled, "Delegate method should be called")
	}

	/// Test step two with an already signed result
	func testStepThreeWithAlreadySignedResult() {

		// Given
		proofManagingSpy.shouldSignedTestResultComplete = true
		proofManagingSpy.signedTestResultState = .alreadySigned

		// When
		sut?.createProofStepThree()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsAlreadyHandledTitle, "Title should match")
		XCTAssertEqual(sut?.message, .holderTestResultsAlreadyHandledText, "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test step two with a not negative  result
	func testStepThreeWithNotNegativeResult() {

		// Given
		proofManagingSpy.shouldSignedTestResultComplete = true
		proofManagingSpy.signedTestResultState = .notNegative

		// When
		sut?.createProofStepThree()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test step two with a too new  result
	func testStepThreeWithTooNewResult() {

		// Given
		proofManagingSpy.shouldSignedTestResultComplete = true
		proofManagingSpy.signedTestResultState = .tooNew

		// When
		sut?.createProofStepThree()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test step two with a too old  result
	func testStepThreeWithTooOldResult() {

		// Given
		proofManagingSpy.shouldSignedTestResultComplete = true
		proofManagingSpy.signedTestResultState = .tooOld

		// When
		sut?.createProofStepThree()

		// Then
		XCTAssertEqual(sut?.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.buttonTitle, .holderTestResultsBackToMenuButton, "Button should match")
		XCTAssertNil(sut?.listItem, "Selected item should be nil")
	}

	/// Test step two with a too old  result
	func testStepThreeWithUnknownError() {

		// Given
		proofManagingSpy.shouldSignedTestResultComplete = true
		proofManagingSpy.signedTestResultState = .unknown(nil)

		// When
		sut?.createProofStepThree()

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.showError, "Error should be true")
	}
}
