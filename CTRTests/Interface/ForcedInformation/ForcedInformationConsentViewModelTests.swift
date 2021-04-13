/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class ForcedInformationConsentViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ForcedInformationConsentViewModel!

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

	override func setUp() {

		super.setUp()

		coordinatorSpy = ForcedInformationCoordinatorDelegateSpy()
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithoutMandatoryConsent
		)
	}

	/// Test the content with mandatory consent
	func testContentWithMandatoryConsent() {

		// Given

		// When
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithMandatoryConsent
		)

		// Then
		XCTAssertEqual(sut.title, consentWithMandatoryConsent.title)
		XCTAssertEqual(sut.highlights, consentWithMandatoryConsent.highlight)
		XCTAssertEqual(sut.content, consentWithMandatoryConsent.content)
		XCTAssertEqual(sut.primaryActionTitle, String.newTermsAgree)
		XCTAssertEqual(sut.secondaryActionTitle, String.newTermsDisagree)
		XCTAssertTrue(sut.useSecondaryButton)
	}

	/// Test the content without mandatory consent
	func testContentWithoutMandatoryConsent() {

		// Given

		// When
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithoutMandatoryConsent
		)

		// Then
		XCTAssertEqual(sut.title, consentWithoutMandatoryConsent.title)
		XCTAssertEqual(sut.highlights, consentWithoutMandatoryConsent.highlight)
		XCTAssertEqual(sut.content, consentWithoutMandatoryConsent.content)
		XCTAssertEqual(sut.primaryActionTitle, String.next)
		XCTAssertNil(sut.secondaryActionTitle)
		XCTAssertFalse(sut.useSecondaryButton)
	}

	/// Test the primary button with mandatory consent
	func testPrimaryButtonWithMandatoryConsent() {
		
		// Given
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithMandatoryConsent
		)

		// When
		sut.primaryButtonTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.invokedDidFinishConsent)
		XCTAssertEqual(coordinatorSpy.invokedDidFinishConsentParameters?.result, ForcedInformationResult.consentAgreed)
	}

	/// Test the primary button without mandatory consent
	func testPrimaryButtonWithoutMandatoryConsent() {

		// Given
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consentWithoutMandatoryConsent
		)

		// When
		sut.primaryButtonTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.invokedDidFinishConsent)
		XCTAssertEqual(coordinatorSpy.invokedDidFinishConsentParameters?.result, ForcedInformationResult.consentViewed)
	}

	/// Test the secondary button
	func testSecondaryButton() {

		// Given

		// When
		sut.secondaryButtonTapped()

		// Then
		XCTAssertEqual(sut.errorTitle, String.newTermsErrorTitle)
		XCTAssertEqual(sut.errorMessage, String.newTermsErrorMessage)
		XCTAssertTrue(sut.showErrorDialog)
	}
}
