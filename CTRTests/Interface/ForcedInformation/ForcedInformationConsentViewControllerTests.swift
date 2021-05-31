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

	var coordinatorSpy: ForcedInformationCoordinatorDelegateSpy!

	var viewModel: ForcedInformationConsentViewModel!

	var window = UIWindow()

	override func setUp() {
		super.setUp()

		coordinatorSpy = ForcedInformationCoordinatorDelegateSpy()
		viewModel = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: .consentWithoutMandatoryConsent
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
		let consent = ForcedInformationConsent.consentWithoutMandatoryConsent

		// When
		loadView()

		// Then
		XCTAssertEqual(sut.sceneView.title, consent.title)
		XCTAssertEqual(sut.sceneView.highlight, consent.highlight)
		XCTAssertEqual(sut.sceneView.content, consent.content)
		XCTAssertEqual(sut.sceneView.primaryTitle, String.next)
		XCTAssertEqual(sut.sceneView.secondaryTitle, "")
		XCTAssertTrue(sut.sceneView.secondaryButton.isHidden)
	}

	/// Test the content with the mandatory consent
	func testContentWithMandatoryConsent() {

		// Given
		let consent = ForcedInformationConsent.consentWithMandatoryConsent
		viewModel = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consent
		)

		sut = ForcedInformationConsentViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		XCTAssertEqual(sut.sceneView.title, consent.title)
		XCTAssertEqual(sut.sceneView.highlight, consent.highlight)
		XCTAssertEqual(sut.sceneView.content, consent.content)

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
		XCTAssertTrue(coordinatorSpy.invokedDidFinish)
		XCTAssertEqual(coordinatorSpy.invokedDidFinishParameters?.result, ForcedInformationResult.consentViewed)
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
