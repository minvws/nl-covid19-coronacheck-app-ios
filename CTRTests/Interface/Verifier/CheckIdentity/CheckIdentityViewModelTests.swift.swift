/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Mobilecore
import Shared
@testable import Models
@testable import Managers
@testable import Resources

final class CheckIdentityViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: CheckIdentityViewModel!
	private var environmentSpies: EnvironmentSpies!
	private var verifierCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifierCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: MobilecoreVerificationDetails(),
			isDeepLinkEnabled: true
		)
	}
	
	func test_bindings() {
		// Given
		
		// When
		
		// Then
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
		expect(self.sut.dccFlag) == nil
		expect(self.sut.verifiedAccessibility) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()
	}
	
	func test_dismiss_shouldNavigateToVerifierWelcome() {
		// Given
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_scanAgain_shouldNavigateToScan() {
		// Given
		
		// When
		sut.scanAgain()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToScan) == true
	}
	
	func test_showMoreInformation_shouldNavigateToVerifiedInfo() {
		// Given
		
		// When
		sut.showMoreInformation()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedInfo) == true
	}
	
	func test_showVerifiedAccess_whenVerified_shouldNavigateToVerifiedAccess() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy1G]
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: MobilecoreVerificationDetails(),
			isDeepLinkEnabled: true
		)
		
		// When
		sut.showVerifiedAccess()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedAccess) == .verified(.policy1G)
	}
	
	func test_showVerifiedAccess_whenDemo_shouldNavigateToVerifiedAccess() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy1G]
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// When
		sut.showVerifiedAccess()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedAccess) == .demo(.policy1G)
	}
	
	func test_showVerifiedAccess_whenVerifiedAndFeatureFlagDisabled_shouldNavigateToVerifiedAccess() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		environmentSpies.userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy3G]
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: MobilecoreVerificationDetails(),
			isDeepLinkEnabled: true
		)
		
		// When
		sut.showVerifiedAccess()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedAccess) == .verified(.policy3G)
	}
	
	func test_showVerifiedAccess_whenDemoAndFeatureFlagDisabled_shouldNavigateToVerifiedAccess() {
		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		environmentSpies.userSettingsSpy.stubbedConfigVerificationPolicies = [VerificationPolicy.policy3G]
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// When
		sut.showVerifiedAccess()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedAccess) == .demo(.policy3G)
	}
	
	func test_showDccInfo_shouldDisplayVerified() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "NL"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == nil
		expect(self.sut.dccScanned) == nil
	}
	
	func test_showDccInfo_whenDCCIsScannedWithFlag_shouldDisplayVerified() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "IT"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == "🇮🇹"
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_showDccInfo_whenDCCIsScannedWithoutFlag_shouldDisplayVerified() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = ""
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == nil
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_showDccInfo_whenDCCIsScannedWithGarbageValueCountry_shouldNotDisplayFlag() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "ITFR"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == nil
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_showDccInfo_whenDCCIsScannedWithGarbageValueCountryStartingWithNL_shouldNotDisplayFlag() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "NLIT"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == nil
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_showDccInfo_whenDCCIsScannedWithUnknownCountryCode_shouldNotDisplayFlag() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "ZZ"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == nil
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_showDccInfo_whenDCCIsScannedWithLowercasedCountryCode_shouldDisplayFlag() {
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "it"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dccFlag) == "🇮🇹"
		expect(self.sut.dccScanned) == L.verifierResultAccessDcc()
	}
	
	func test_holderIdentity() {
		// Given
		let details = MobilecoreVerificationDetails()
		details.birthDay = "3"
		details.birthMonth = "A"
		details.firstNameInitial = "B"
		details.lastNameInitial = "C"
		
		// When
		sut = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		
		// Then
		expect(self.sut.dayOfBirth) == "3"
		expect(self.sut.monthOfBirth) == "A"
		expect(self.sut.firstName) == "B"
		expect(self.sut.lastName) == "C"
	}
}
