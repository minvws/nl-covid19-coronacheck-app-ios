/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import ViewControllerPresentationSpy

// swiftlint:disable:next type_name
class ForcedInformationConsentViewControllerTests: XCTestCase {

	var sut: ForcedInformationConsentViewController!

	var coordinatorSpy = ForcedInformationCoordinatorDelegateSpy()

	var consentWithoutMandatoryConsent = ForcedInformationConsent(
		title: "test title without mandatory consent",
		highlight: "test highlight without mandatory consent",
		content: "test content without mandatory consent",
		consentMandatory: false
	)

	var consentWithMandatoryConsent = ForcedInformationConsent(
		title: "test title with mandatory consent",
		highlight: "test highlight with mandatory consent",
		content: "test content with mandatory consent",
		consentMandatory: true
	)

	var viewModel: ForcedInformationConsentViewModel!

	var window = UIWindow()

	override func setUp() {
		super.setUp()

		coordinatorSpy = ForcedInformationCoordinatorDelegateSpy()
		viewModel = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithoutMandatoryConsent
		)

		sut = ForcedInformationConsentViewController(viewModel: viewModel)
	}

	func loadView() {

		if let sut = sut {
			window.addSubview(sut.view)
			RunLoop.current.run(until: Date())
		}
	}

	// MARK: - Tests

	/// Test the content without the mandatory consent
	func testContentWithoutMandatoryConsent() {

		// Given

		// When
		loadView()

		// Then
		XCTAssertEqual(sut.sceneView.title, consentWithoutMandatoryConsent.title)
		XCTAssertEqual(sut.sceneView.highlight, consentWithoutMandatoryConsent.highlight)
		XCTAssertEqual(sut.sceneView.content, consentWithoutMandatoryConsent.content)
		XCTAssertEqual(sut.sceneView.primaryTitle, String.next)
		XCTAssertEqual(sut.sceneView.secondaryTitle, "")
		XCTAssertTrue(sut.sceneView.secondaryButton.isHidden)
	}

	/// Test the content with the mandatory consent
	func testContentWitMandatoryConsent() {

		// Given
		viewModel = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithMandatoryConsent
		)

		sut = ForcedInformationConsentViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		XCTAssertEqual(sut.sceneView.title, consentWithMandatoryConsent.title)
		XCTAssertEqual(sut.sceneView.highlight, consentWithMandatoryConsent.highlight)
		XCTAssertEqual(sut.sceneView.content, consentWithMandatoryConsent.content)

		XCTAssertEqual(sut.sceneView.primaryTitle, String.newTermsAgree)
		XCTAssertEqual(sut.sceneView.secondaryTitle, String.newTermsDisagree)
		XCTAssertFalse(sut.sceneView.secondaryButton.isHidden)
	}

	func testPrimaryButton() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.invokedDidFinishConsent)
		XCTAssertEqual(coordinatorSpy.invokedDidFinishConsentParameters?.result, ForcedInformationResult.consentViewed)
	}

	/// Test the error dialog that should appear after tapping the secondary button
	func testErrorDialog() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		sut.sceneView.secondaryButtonTapped()

		// Then
		alertVerifier.verify(
			title: viewModel.errorTitle,
			message: viewModel.errorMessage,
			animated: true,
			actions: [
				.default(.ok)
			],
			presentingViewController: sut
		)
	}
}
