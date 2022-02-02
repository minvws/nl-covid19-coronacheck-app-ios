/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class NewFeaturesConsentViewModelTests: XCTestCase {

	/// Subject under test
	var sut: NewFeaturesConsentViewModel!

	var coordinatorSpy = NewFeaturesCoordinatorDelegateSpy()

	override func setUp() {

		super.setUp()

		coordinatorSpy = NewFeaturesCoordinatorDelegateSpy()
		sut = NewFeaturesConsentViewModel(
			coordinatorSpy,
			newFeatureConsent: .consentWithoutMandatoryConsent
		)
	}

	/// Test the content with mandatory consent
	func testContentWithMandatoryConsent() {

		// Given
		let consent = NewFeatureConsent.consentWithMandatoryConsent

		// When
		sut = NewFeaturesConsentViewModel(
			coordinatorSpy,
			newFeatureConsent: consent
		)

		// Then
		XCTAssertEqual(sut.title, consent.title)
		XCTAssertEqual(sut.highlights, consent.highlight)
		XCTAssertEqual(sut.content, consent.content)
		XCTAssertEqual(sut.primaryActionTitle, L.newTermsAgree())
		XCTAssertEqual(sut.secondaryActionTitle, L.newTermsDisagree())
		XCTAssertTrue(sut.useSecondaryButton)
	}

	/// Test the content without mandatory consent
	func testContentWithoutMandatoryConsent() {

		// Given
		let consent = NewFeatureConsent.consentWithoutMandatoryConsent

		// When
		sut = NewFeaturesConsentViewModel(
			coordinatorSpy,
			newFeatureConsent: consent
		)

		// Then
		XCTAssertEqual(sut.title, consent.title)
		XCTAssertEqual(sut.highlights, consent.highlight)
		XCTAssertEqual(sut.content, consent.content)
		XCTAssertEqual(sut.primaryActionTitle, L.generalNext())
		XCTAssertNil(sut.secondaryActionTitle)
		XCTAssertFalse(sut.useSecondaryButton)
	}

	/// Test the primary button with mandatory consent
	func testPrimaryButtonWithMandatoryConsent() {
		
		// Given
		let consent = NewFeatureConsent.consentWithMandatoryConsent
		sut = NewFeaturesConsentViewModel(
			coordinatorSpy,
			newFeatureConsent: consent
		)

		// When
		sut.primaryButtonTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.invokedDidFinish)
		XCTAssertEqual(coordinatorSpy.invokedDidFinishParameters?.result, NewFeaturesScreenResult.consentAgreed)
	}

	/// Test the primary button without mandatory consent
	func testPrimaryButtonWithoutMandatoryConsent() {

		// Given
		let consent = NewFeatureConsent.consentWithoutMandatoryConsent
		sut = NewFeaturesConsentViewModel(
			coordinatorSpy,
			newFeatureConsent: consent
		)

		// When
		sut.primaryButtonTapped()

		// Then
		XCTAssertTrue(coordinatorSpy.invokedDidFinish)
		XCTAssertEqual(coordinatorSpy.invokedDidFinishParameters?.result, NewFeaturesScreenResult.consentViewed)
	}

	/// Test the secondary button
	func testSecondaryButton() {

		// Given

		// When
		sut.secondaryButtonTapped()

		// Then
		XCTAssertEqual(sut.errorTitle, L.newTermsErrorTitle())
		XCTAssertEqual(sut.errorMessage, L.newTermsErrorMessage())
		XCTAssertTrue(sut.showErrorDialog)
	}
}
