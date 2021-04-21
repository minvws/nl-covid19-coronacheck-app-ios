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

	override func setUp() {

		super.setUp()

		coordinatorSpy = ForcedInformationCoordinatorDelegateSpy()
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: .consentWithoutMandatoryConsent
		)
	}

	/// Test the content with mandatory consent
	func testContentWithMandatoryConsent() {

		// Given
		let consent = ForcedInformationConsent.consentWithMandatoryConsent

		// When
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consent
		)

		// Then
		XCTAssertEqual(sut.title, consent.title)
		XCTAssertEqual(sut.highlights, consent.highlight)
		XCTAssertEqual(sut.content, consent.content)
		XCTAssertEqual(sut.primaryActionTitle, String.newTermsAgree)
		XCTAssertEqual(sut.secondaryActionTitle, String.newTermsDisagree)
		XCTAssertTrue(sut.useSecondaryButton)
	}

	/// Test the content without mandatory consent
	func testContentWithoutMandatoryConsent() {

		// Given
		let consent = ForcedInformationConsent.consentWithoutMandatoryConsent

		// When
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consent
		)

		// Then
		XCTAssertEqual(sut.title, consent.title)
		XCTAssertEqual(sut.highlights, consent.highlight)
		XCTAssertEqual(sut.content, consent.content)
		XCTAssertEqual(sut.primaryActionTitle, String.next)
		XCTAssertNil(sut.secondaryActionTitle)
		XCTAssertFalse(sut.useSecondaryButton)
	}

	/// Test the primary button with mandatory consent
	func testPrimaryButtonWithMandatoryConsent() {
		
		// Given
		let consent = ForcedInformationConsent.consentWithMandatoryConsent
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consent
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
		let consent = ForcedInformationConsent.consentWithoutMandatoryConsent
		sut = ForcedInformationConsentViewModel(
			coordinatorSpy,
			forcedInformationConsent: consent
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
