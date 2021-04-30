/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR

class ListResultsViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ListResultsViewController?

	/// The coordinator spy
	var holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()

	/// The proof manager spy
	var proofManagingSpy = ProofManagingSpy()

	var viewModel: ListResultsViewModel?

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		proofManagingSpy = ProofManagingSpy()

		viewModel = ListResultsViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			proofManager: proofManagingSpy,
			maxValidity: 48
		)
		sut = ListResultsViewController( viewModel: viewModel!)
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

	/// Test the content for pending result
	func testContentPendingResult() throws {

		// Given
		loadView()

		// When
		viewModel?.reportPendingResult()

		// Then
		XCTAssertEqual(sut?.sceneView.title, .holderTestResultsPendingTitle, "Title should match")
		XCTAssertEqual(sut?.sceneView.message, .holderTestResultsPendingText, "Message should match")
		XCTAssertEqual(sut?.sceneView.primaryTitle, .holderTestResultsBackToMenuButton, "Button title should match")
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.resultView.isHidden, "Resultview should not be visible")
	}

	/// Test the content for no result
	func testContentNoResult() throws {

		// Given
		loadView()

		// When
		viewModel?.reportNoTestResult()

		// Then
		XCTAssertEqual(sut?.sceneView.title, .holderTestResultsNoResultsTitle, "Title should match")
		XCTAssertEqual(sut?.sceneView.message, String(format: .holderTestResultsNoResultsText, "48"), "Message should match")
		XCTAssertEqual(sut?.sceneView.primaryTitle, .holderTestResultsBackToMenuButton, "Button title should match")
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.resultView.isHidden, "Resultview should not be visible")
	}

	/// Test the content for no result
	func testContentAlreadyDoneResult() throws {

		// Given
		loadView()

		// When
		viewModel?.reportAlreadyDone()

		// Then
		XCTAssertEqual(sut?.sceneView.title, .holderTestResultsAlreadyHandledTitle, "Title should match")
		XCTAssertEqual(sut?.sceneView.message, .holderTestResultsAlreadyHandledText, "Message should match")
		XCTAssertEqual(sut?.sceneView.primaryTitle, .holderTestResultsBackToMenuButton, "Button title should match")
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.resultView.isHidden, "Resultview should not be visible")
	}

	func testContentValid() throws {

		// Given
		loadView()
		let result = TestResult(
			unique: "test",
			sampleDate: "2021-02-01T00:00:00+00:00",
			testType: "test",
			negativeResult: true,
			holder: nil
		)
		
		// When
		viewModel?.reportTestResult(result)

		// Then
		XCTAssertEqual(sut?.sceneView.title, .holderTestResultsResultsTitle, "Title should match")
		XCTAssertEqual(sut?.sceneView.message, .holderTestResultsResultsText, "Message should match")
		XCTAssertEqual(sut?.sceneView.primaryTitle, .holderTestResultsResultsButton, "Button title should match")

		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.sceneView.resultView.isHidden, "Resultview should be visible")
		XCTAssertEqual(sut?.sceneView.resultView.header, .holderTestResultsRecent, "Header should match")
		XCTAssertEqual(sut?.sceneView.resultView.title, .holderTestResultsNegative, "Title should match")
		XCTAssertNotNil(sut?.sceneView.resultView.message, "Message should NOT be nil")
	}

	/// Test showing the alert dialog
	func testAlertDialog() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		viewModel?.showAlert = true

		// Then
		alertVerifier.verify(
			title: .holderTestResultsAlertTitle,
			message: .holderTestResultsAlertMessage,
			animated: true,
			actions: [
				.cancel(.holderTestResultsAlertOk),
				.default(.holderTestResultsAlertCancel)
			],
			presentingViewController: sut
		)
	}

	/// Test showing the error dialog
	func testErrorDialog() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		viewModel?.showError = true
		// Then
		alertVerifier.verify(
			title: .errorTitle,
			message: .technicalErrorText,
			animated: true,
			actions: [
				.default(.ok)
			],
			presentingViewController: sut
		)
	}

	func test_shouldShowProgress() throws {

		// Given
		loadView()
		proofManagingSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = false

		// When
		viewModel?.createProofStepOne()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.sceneView.primaryButton.isEnabled, "Button should be disabled")
	}

	func test_shouldNotShowProgress() throws {

		// Given
		loadView()
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagingSpy.stubbedFetchIssuerPublicKeysOnErrorResult = (error, ())

		// When
		viewModel?.createProofStepOne()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.sceneView.primaryButton.isEnabled, "Button should be enabled")
	}

	func testNextButtonNoItems() {

		// Given
		loadView()

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Delegate method should be called")
	}

	func testNextButtonWithItems() {

		// Given
		loadView()
		viewModel?.listItem = ListResultItem(identifier: "testNextButtonWithItems", date: "Now", holder: "CC 10 MAR")

		// When
		sut?.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertFalse(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Delegate method should not be called")
		XCTAssertTrue(proofManagingSpy.invokedFetchIssuerPublicKeys, "Step 1 should be executed")
	}

	func testDisclaimer() {

		// Given
		loadView()
		viewModel?.listItem = ListResultItem(identifier: "testNextButtonWithItems", date: "Now", holder: "CC 10 MAR")

		// When
		sut?.sceneView.resultView.disclaimerButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateToAboutTestResultCalled, "Delegate method should be called")
	}

	func testDismiss() {

		// Given

		// When
		sut?.closeButtonTapped()

		// Then
		XCTAssertTrue(holderCoordinatorDelegateSpy.navigateBackToStartCalled, "Delegate method should be called")
	}
}
