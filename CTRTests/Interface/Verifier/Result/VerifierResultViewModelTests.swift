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
	
	private var userSettingsSpy: UserSettingsSpy!
	
	/// Date parser
	private lazy var parseDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
	
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
		userSettingsSpy.stubbedScanRiskSettingValue = .low
		
		sut = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			verificationResult: MobilecoreVerificationResult(),
			isDeepLinkEnabled: true,
			userSettings: userSettingsSpy
		)
	}
	
	// MARK: - Tests
	
	func test_checkAttributes_shouldDisplayDemo() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		details.issuerCountryCode = "NL"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .demo(.low)
		expect(self.sut.title) == L.verifierResultDemoTitle()
		expect(self.sut.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.dccFlag).to(beNil())
		expect(self.sut.dccScanned).to(beNil())
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
		details.issuerCountryCode = "NL"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified(.low)
		expect(self.sut.title) == L.verifierResultAccessTitle()
		expect(self.sut.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.dccFlag).to(beNil())
		expect(self.sut.dccScanned).to(beNil())
	}
	
	func test_checkAttributes_whenDCCIsScannedWithFlag_shouldDisplayVerified() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "IT"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified(.low)
		expect(self.sut.title) == L.verifierResultAccessTitle()
		expect(self.sut.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.dccFlag) == "🇮🇹"
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_checkAttributes_whenDCCIsScannedWithoutFlag_shouldDisplayVerified() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = ""
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified(.low)
		expect(self.sut.title) == L.verifierResultAccessTitle()
		expect(self.sut.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.dccFlag).to(beNil())
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_checkAttributes_whenDCCIsScannedWithGarbageValueCountry_shouldNotDisplayFlag() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "ITFR"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.dccFlag).to(beNil())
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_checkAttributes_whenDCCIsScannedWithGarbageValueCountryStartingWithNL_shouldNotDisplayFlag() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "NLIT"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.dccFlag).to(beNil())
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_checkAttributes_whenDCCIsScannedWithUnknownCountryCode_shouldNotDisplayFlag() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "ZZ"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.dccFlag).to(beNil())
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_checkAttributes_whenDCCIsScannedWithLowercasedCountryCode_shouldDisplayFlag() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "it"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		sut.verificationResult = result
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.dccFlag) == "🇮🇹"
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
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
		sut.allowAccess = .verified(.low)
		
		// When
		sut.showMoreInformation()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifiedInfo) == true
	}
	
	func test_openDeeplinkOrScanAgain_shouldLaunchThirdPartyApp() {
		
		// Given
		
		// When
		sut.launchThirdPartyAppOrScanAgain()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedUserWishesToLaunchThirdPartyScannerApp) == true
	}
}
