/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Rswift
import Clcore

class VerifierResultViewModelTests: XCTestCase {
	
	/// Subject under test
	var sut: VerifierResultViewModel!
	
	/// The coordinator spy
	var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	/// Date parser
	private lazy var parseDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
	
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		
		sut = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			verificationResult: MobilecoreVerificationResult()
		)
	}
	
	// MARK: - Tests
	
	func test_checkAttributes_shouldDisplayDemo() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .demo
		expect(self.sut.title) == L.verifierResultDemoTitle()
	}
	
	func test_checkAttributes_whenNoAttributesAreSet_shouldDisplayDeniedInvalidQR() {
		
		// Given
		sut.verificationResult = MobilecoreVerificationResult()
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == L.verifierResultDeniedTitle()
		expect(self.sut.secondaryTitle) == L.verifierResultDeniedReadmore()
	}
	
	func test_checkAttributes_shouldDisplayVerified() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified
		expect(self.sut.title) == L.verifierResultAccessTitle()
		expect(self.sut.secondaryTitle) == L.verifierResultAccessReadmore()
	}

	func test_holderIdentity_allNil() {

		// Given
		let details = MobilecoreVerificationDetails()

		// When
		sut.setHolderIdentity(details)

		// Then
		expect(self.sut.firstName).to(beNil())
		expect(self.sut.lastName).to(beNil())
		expect(self.sut.dayOfBirth).to(beNil())
		expect(self.sut.monthOfBirth).to(beNil())
	}

	func test_holderIdentity_allEmpty() {

		// Given
		let details = MobilecoreVerificationDetails()
		details.birthDay = ""
		details.birthMonth = ""
		details.firstNameInitial = ""
		details.lastNameInitial = ""

		// When
		sut.setHolderIdentity(details)

		// Then
		expect(self.sut.firstName).to(beNil())
		expect(self.sut.lastName).to(beNil())
		expect(self.sut.dayOfBirth).to(beNil())
		expect(self.sut.monthOfBirth).to(beNil())
	}

	func test_holderIdentity_allNotEmpty() {

		// Given
		let details = MobilecoreVerificationDetails()
		details.birthDay = "5"
		details.birthMonth = "5"
		details.firstNameInitial = "R"
		details.lastNameInitial = "P"

		// When
		sut.setHolderIdentity(details)

		// Then
		expect(self.sut.firstName) == "R"
		expect(self.sut.lastName) == "P"
		expect(self.sut.dayOfBirth) == "5"
		expect(self.sut.monthOfBirth) == "MEI (05)"
	}

	func test_holderIdentity_dateOfBirthUnknown() {

		// Given
		let details = MobilecoreVerificationDetails()
		details.birthDay = "X"
		details.birthMonth = "X"
		details.firstNameInitial = ""
		details.lastNameInitial = ""

		// When
		sut.setHolderIdentity(details)

		// Then
		expect(self.sut.firstName).to(beNil())
		expect(self.sut.lastName).to(beNil())
		expect(self.sut.dayOfBirth) == "X"
		expect(self.sut.monthOfBirth) == "X"
	}

	func test_dismiss_shouldNavigateToVerifierWelcome() {
		
		// Given
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_scanAgain_shouldNavigateToScan() {
		
		// Given
		
		// When
		sut.scanAgain()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScan) == true
	}
	
	func test_showMoreInformation_whenDenied_shouldDisplayContent() {
		
		// Given
		sut.allowAccess = .denied
		
		// When
		sut.showMoreInformation()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
	
	func test_showMoreInformation_whenAllowed_shouldDisplayContent() {
		
		// Given
		sut.allowAccess = .verified
		
		// When
		sut.showMoreInformation()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifiedInfo) == true
	}
}
