/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Clcore
import Nimble

class VerifierScanViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: VerifierScanViewModel!
	
	/// The coordinator spy
	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		sut = VerifierScanViewModel(coordinator: verifyCoordinatorDelegateSpy)
	}
	
	// MARK: - Tests
	
	func test_dismiss() {
		
		// Given
		
		// When
		sut?.dismiss()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func test_moreInformation() {
		
		// Given
		
		// When
		sut?.didTapMoreInformationButton()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScanInstruction) == true
	}
	
	func test_parseQRMessage_shouldAddScanLogEntry_lowRisk_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntryParameters?.verificationPolicy) == .policy3G
	}

	func test_parseQRMessage_shouldAddScanLogEntry_lowRisk_verification_policyDisabled() {

		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == false
	}

	func test_parseQRMessage_shouldAddScanLogEntry_highRisk_verificationPolicyEnabled() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntryParameters?.verificationPolicy) == .policy1G
	}

	func test_parseQRMessage_shouldAddScanLogEntry_highRisk_verification_policyDisabled() {

		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == false
	}

	func test_parseQRMessage_whenDCCIsNL_shouldDisplayAlert() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_IS_NL_DCC)
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .success(result)

		// When
		sut.parseQRMessage("test_verificationFailed_nlDCC")

		// Then
		expect(self.sut.alert) != nil
		expect(self.sut.alert?.title) == L.verifierResultAlertDccTitle()
		expect(self.sut.alert?.subTitle) == L.verifierResultAlertDccMessage()
	}

	func test_parseQRMessage_whenDCCIsUnknown_shouldDisplayAlert() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX)
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .success(result)

		// When
		sut.parseQRMessage("test_verificationFailed_unknownDCC")

		// Then
		expect(self.sut.alert) != nil
		expect(self.sut.alert?.title) == L.verifierResultAlertUnknownTitle()
		expect(self.sut.alert?.subTitle) == L.verifierResultAlertUnknownMessage()
	}
	
	func test_parseQRMessage_whenVerificationDetailsIsNil_shouldNavigateToDeniedAccess() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = nil
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .success(result)

		// When
		sut.parseQRMessage("test_deniedAccess")

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToDeniedAccess) == true
	}
	
	func test_parseQRMessage_whenStatusIsFailed_shouldNavigateToDeniedAccess() {

		// Given
		let details = MobilecoreVerificationDetails()
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_ERROR)
		result.details = details
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .success(result)

		// When
		sut.parseQRMessage("test_deniedAccess")

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToDeniedAccess) == true
	}

	func test_parseQRMessage_shouldNavigateToCheckIdentity() {

		// Given
		let details = MobilecoreVerificationDetails()
		details.firstNameInitial = "A"
		details.lastNameInitial = "B"
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = details
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .success(result)

		// When
		sut.parseQRMessage("test_verificationOK")

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToCheckIdentity) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToCheckIdentityParameters?.verificationDetails.firstNameInitial) == "A"
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToCheckIdentityParameters?.verificationDetails.lastNameInitial) == "B"
	}
	
	func test_parseQR_publicKeysMissing() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .failure(.keyMissing)
		
		// When
		sut.parseQRMessage("test_parseQR_publicKeysMissing")

		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorCryptolibMessage("i 140 000 090")
	}
	
	func test_parseQR_noRiskSetting() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .failure(.noRiskSetting)
		
		// When
		sut.parseQRMessage("test_parseQR_noRiskSetting")
		
		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorCryptolibMessage("i 140 000 091")
	}
	
	func test_parseQR_noDefaultVerificationPolicy() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .failure(.noDefaultVerificationPolicy)
		
		// When
		sut.parseQRMessage("test_parseQR_noDefaultVerificationPolicy")
		
		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorCryptolibMessage("i 140 000 092")
	}
	
	func test_parseQR_couldNotVerify() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .failure(.couldNotVerify)
		
		// When
		sut.parseQRMessage("test_parseQR_couldNotVerify")
		
		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorCryptolibMessage("i 140 000 093")
	}
	
	func test_parseQR_unknown() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = .failure(.unknown)
		
		// When
		sut.parseQRMessage("test_parseQR_unknown")
		
		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorCryptolibMessage("i 140 000 999")
	}
}
