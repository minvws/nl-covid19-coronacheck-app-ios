/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ListResultsViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ListResultsViewModel!
	private var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var proofManagingSpy: ProofManagingSpy!
	private let maxValidity = 48

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
			maxValidity: maxValidity
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
		proofManagingSpy.stubbedGetTestWrapperResult = pendingWrapper

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsPendingTitle
		expect(self.sut.message) == .holderTestResultsPendingText
		expect(self.sut.buttonTitle) == .holderTestResultsBackToMenuButton
		expect(self.sut.listItem).to(beNil())
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
				holder: nil
			),
			status: .complete
		)
		proofManagingSpy.stubbedGetTestWrapperResult = notNegativeWrapper

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsNoResultsTitle
		expect(self.sut.message) == String(format: .holderTestResultsNoResultsText, "\(maxValidity)")
		expect(self.sut.buttonTitle) == .holderTestResultsBackToMenuButton
		expect(self.sut.listItem).to(beNil())
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
				holder: nil
			),
			status: .complete
		)
		proofManagingSpy.stubbedGetTestWrapperResult = tooOldWrapper

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsResultsTitle
		expect(self.sut.message) == .holderTestResultsResultsText
		expect(self.sut.buttonTitle) == .holderTestResultsResultsButton
		expect(self.sut.listItem).toNot(beNil())
		expect(self.sut.listItem?.identifier) == "testCheckResultTooOld"
	}

	/// Test the check result method with a too new test result
	func testCheckResultTooNew() {

		// Given
		let now = Date().timeIntervalSince1970 + 200

		let tooNewWrapper = TestResultWrapper(
			providerIdentifier: "testCheckResultTooNew",
			protocolVersion: "1.0",
			result: TestResult(
				unique: "testCheckResultTooNew",
				sampleDate: parseDateFormatter.string(from: Date(timeIntervalSince1970: now)),
				testType: "test",
				negativeResult: true,
				holder: nil
			),
			status: .complete
		)
		proofManagingSpy.stubbedGetTestWrapperResult = tooNewWrapper

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsResultsTitle
		expect(self.sut.message) == .holderTestResultsResultsText
		expect(self.sut.buttonTitle) == .holderTestResultsResultsButton
		expect(self.sut.listItem).toNot(beNil())
		expect(self.sut.listItem?.identifier) == "testCheckResultTooNew"
	}

	/// Test the check result method with a valid test result
	func testCheckResultValidProtocolVersionOne() {

		// Given
		let now = Date().timeIntervalSince1970 - 200

		let validProtocolOne = TestResultWrapper(
			providerIdentifier: "testCheckResultValid",
			protocolVersion: "1.0",
			result: TestResult(
				unique: "testCheckResultValid",
				sampleDate: parseDateFormatter.string(from: Date(timeIntervalSince1970: now)),
				testType: "test",
				negativeResult: true,
				holder: nil
			),
			status: .complete
		)
		proofManagingSpy.stubbedGetTestWrapperResult = validProtocolOne

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsResultsTitle
		expect(self.sut.message) == .holderTestResultsResultsText
		expect(self.sut.buttonTitle) == .holderTestResultsResultsButton
		expect(self.sut.listItem).toNot(beNil())
		expect(self.sut.listItem?.identifier) == "testCheckResultValid"
	}

	/// Test the check result method with a valid test result
	func test_checkResultValid_protocolVersionTwo() {

		// Given
		let now = Date().timeIntervalSince1970 - 200

		let validProtocolTwo = TestResultWrapper(
			providerIdentifier: "testCheckResultValid",
			protocolVersion: "2.0",
			result: TestResult(
				unique: "testCheckResultValid",
				sampleDate: parseDateFormatter.string(from: Date(timeIntervalSince1970: now)),
				testType: "test",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "T",
					lastNameInitial: "T",
					birthDay: "1",
					birthMonth: "1"
				)
			),
			status: .complete
		)
		proofManagingSpy.stubbedGetTestWrapperResult = validProtocolTwo

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsResultsTitle
		expect(self.sut.message) == .holderTestResultsResultsText
		expect(self.sut.buttonTitle) == .holderTestResultsResultsButton
		expect(self.sut.listItem).toNot(beNil())
		expect(self.sut.listItem?.identifier) == "testCheckResultValid"
		expect(self.sut.listItem?.date) != ""

	}

	/// Test the check result method with a valid test result using microseconds
	func test_checkResultValid_protocolVersionTwo_withMicroSeconds() {

		// Given
		let now = Date().timeIntervalSince1970 - 200
		parseDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		let validProtocolTwo = TestResultWrapper(
			providerIdentifier: "testCheckResultValid",
			protocolVersion: "2.0",
			result: TestResult(
				unique: "testCheckResultValid",
				sampleDate: parseDateFormatter.string(from: Date(timeIntervalSince1970: now)),
				testType: "test",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "T",
					lastNameInitial: "T",
					birthDay: "1",
					birthMonth: "1"
				)
			),
			status: .complete
		)
		proofManagingSpy.stubbedGetTestWrapperResult = validProtocolTwo

		// When
		sut.checkResult()

		// Then
		expect(self.sut.title) == .holderTestResultsResultsTitle
		expect(self.sut.message) == .holderTestResultsResultsText
		expect(self.sut.buttonTitle) == .holderTestResultsResultsButton
		expect(self.sut.listItem).toNot(beNil())
		expect(self.sut.listItem?.identifier) == "testCheckResultValid"
		expect(self.sut.listItem?.date) != ""
	}

	/// Test tap on the next button with an item selected
	func testButtonTappedListItemNotNil() {

		// Given
		sut.listItem = ListResultItem(identifier: "test", date: "test", holder: "CC 10 MAR")

		// When
		sut.buttonTapped()

		// Then
		expect(self.proofManagingSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.sut.showAlert) == false
	}

	/// Test tap on the next button with no item selected
	func testButtonTappedListItemNil() {

		// Given
		sut.listItem = nil

		// When
		sut.buttonTapped()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
		expect(self.sut.showAlert) == false
	}

	/// Test tap on the close button with an item selected
	func testDismissListItemNotNil() {

		// Given
		sut.listItem = ListResultItem(identifier: "test", date: "test", holder: "CC 10 MAR")

		// When
		sut.dismiss()

		// Then
		expect(self.proofManagingSpy.invokedFetchIssuerPublicKeys) == false
		expect(self.sut.showAlert) == true
	}

	/// Test tap on the close button with no item selected
	func testDismissListItemNil() {

		// Given
		sut.listItem = nil

		// When
		sut.dismiss()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
		expect(self.sut.showAlert) == false
	}

	/// Test step one with an error
	func testStepOneIssuerPublicKeysError() {

		// Given
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
        proofManagingSpy.stubbedFetchIssuerPublicKeysOnErrorResult = (error, ())

		// When
		sut.createProofStepOne()

		// Then
		expect(self.sut.showError) == true
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step one without an error
	func testStepOneIssuerPublicKeysNoError() {

		// Given
		proofManagingSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut.createProofStepOne()

		// Then
		expect(self.proofManagingSpy.invokedFetchNonce) == true
		expect(self.sut.shouldShowProgress) == true
	}

	/// Test step two with an error
	func testStepTwoNonceError() {

		// Given
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagingSpy.stubbedFetchNonceOnErrorResult = (error, ())

		// When
		sut.createProofStepTwo()

		// Then
		expect(self.sut.showError) == true
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step one without an error
	func testStepTwoNonceNoError() {

		// Given
		proofManagingSpy.shouldInvokeFetchNonceOnCompletion = true

		// When
		sut.createProofStepTwo()

		// Then
		expect(self.proofManagingSpy.invokedFetchSignedTestResult) == true
		expect(self.sut.shouldShowProgress) == true
	}

	/// Test step three with an error
	func testStepThreeWithError() {

		// Given
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagingSpy.stubbedFetchSignedTestResultOnErrorResult = (error, ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.showError) == true
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step three with a valid result
	func testStepThreeWithValidResult() {

		// Given
		proofManagingSpy.stubbedFetchSignedTestResultOnCompletionResult = (.valid, ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.showError) == false
		expect(self.sut.shouldShowProgress) == false
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
	}

	/// Test step two with an already signed result
	func testStepThreeWithAlreadySignedResult() {

		// Given
        proofManagingSpy.stubbedFetchSignedTestResultOnCompletionResult = (.alreadySigned(
            response: SignedTestResultErrorResponse(status: "test", code: 1)
        ), ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.errorMessage).to(beNil())
		expect(self.sut.title) == .holderTestResultsAlreadyHandledTitle
		expect(self.sut.message) == .holderTestResultsAlreadyHandledText
		expect(self.sut.buttonTitle) == .holderTestResultsBackToMenuButton
		expect(self.sut.listItem).to(beNil())
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step two with a not negative  result
	func testStepThreeWithNotNegativeResult() {

		// Given
		proofManagingSpy.stubbedFetchSignedTestResultOnCompletionResult = (.notNegative(
            response: SignedTestResultErrorResponse(status: "test", code: 1)
        ), ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.errorMessage).to(beNil())
		expect(self.sut.title) == .holderTestResultsNoResultsTitle
		expect(self.sut.message) == String(format: .holderTestResultsNoResultsText, "\(maxValidity)")
		expect(self.sut.buttonTitle) == .holderTestResultsBackToMenuButton
		expect(self.sut.listItem).to(beNil())
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step two with a too new  result
	func testStepThreeWithTooNewResult() {

		// Given
        proofManagingSpy.stubbedFetchSignedTestResultOnCompletionResult = (.tooNew(
			response: SignedTestResultErrorResponse(status: "test", code: 1)
		), ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.errorMessage).toNot(beNil())
		expect(self.sut.title) == .holderTestResultsNoResultsTitle
		expect(self.sut.message) == String(format: .holderTestResultsNoResultsText, "\(maxValidity)")
		expect(self.sut.buttonTitle) == .holderTestResultsBackToMenuButton
		expect(self.sut.listItem).to(beNil())
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step two with a too old  result
	func testStepThreeWithTooOldResult() {

		// Given
        proofManagingSpy.stubbedFetchSignedTestResultOnCompletionResult = (.tooOld(
			response: SignedTestResultErrorResponse(status: "test", code: 1)
		), ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.errorMessage).toNot(beNil())
		expect(self.sut.title) == .holderTestResultsNoResultsTitle
		expect(self.sut.message) == String(format: .holderTestResultsNoResultsText, "\(maxValidity)")
		expect(self.sut.buttonTitle) == .holderTestResultsBackToMenuButton
		expect(self.sut.listItem).to(beNil())
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test step two with a too old  result
	func testStepThreeWithUnknownError() {

		// Given
        proofManagingSpy.stubbedFetchSignedTestResultOnCompletionResult = (.unknown(
			response: SignedTestResultErrorResponse(status: "test", code: 1)
		), ())

		// When
		sut.createProofStepThree()

		// Then
		expect(self.sut.errorMessage).toNot(beNil())
		expect(self.sut.shouldShowProgress) == false
	}

	/// Test the display of the identity
	func testIdentity() {

		// Given
		let examples: [String: TestHolderIdentity] = [
			"R P 27 JAN": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "1"),
			"R P 27 FEB": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "2"),
			"R P 27 MAR": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "3"),
			"R P 27 APR": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "4"),
			"R P 27 MEI": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "5"),
			"R P 27 JUN": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "6"),
			"R P 27 JUL": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "7"),
			"R P 27 AUG": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "8"),
			"R P 27 SEP": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "9"),
			"R P 27 OKT": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "10"),
			"R P 27 NOV": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "11"),
			"R P 27 DEC": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "12"),
			"R P 05 MEI": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "5", birthMonth: "5"),
			"R P X MEI": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "X", birthMonth: "5"),
			"R P X X": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "X", birthMonth: "X"),
			"R P 27 X": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "X"),
			"R P 27 0": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "27", birthMonth: "0"),
			"R P 0 0": TestHolderIdentity(firstNameInitial: "R", lastNameInitial: "P", birthDay: "0", birthMonth: "0")
		]

		examples.forEach { expectedResult, holder in

			// When
			let result = sut.getDisplayIdentity(holder)

			// Then
			expect(result) == expectedResult
		}
	}
}
