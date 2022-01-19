/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = true
		environmentSpies.riskLevelManagerSpy.stubbedState = .low

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntryParameters?.riskLevel) == .low
	}

	func test_parseQRMessage_shouldAddScanLogEntry_lowRisk_verification_policyDisabled() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		environmentSpies.riskLevelManagerSpy.stubbedState = .low

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == false	}

	func test_parseQRMessage_shouldAddScanLogEntry_highRisk_verificationPolicyEnabled() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = true
		environmentSpies.riskLevelManagerSpy.stubbedState = .high

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntryParameters?.riskLevel) == .high
	}

	func test_parseQRMessage_shouldAddScanLogEntry_highRisk_verification_policyDisabled() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		environmentSpies.riskLevelManagerSpy.stubbedState = .high

		// When
		sut.parseQRMessage("test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == false
	}

	func test_parseQRMessage_whenDCCIsNL_shouldDisplayAlert() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_IS_NL_DCC)
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = result

		// When
		sut.parseQRMessage("test_verificationFailed_nlDCC")

		// Then
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.verifierResultAlertDccTitle()
		expect(self.sut.alert?.subTitle) == L.verifierResultAlertDccMessage()
	}

	func test_parseQRMessage_whenDCCIsUnknown_shouldDisplayAlert() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX)
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = result

		// When
		sut.parseQRMessage("test_verificationFailed_unknownDCC")

		// Then
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.verifierResultAlertUnknownTitle()
		expect(self.sut.alert?.subTitle) == L.verifierResultAlertUnknownMessage()
	}
	
	func test_parseQRMessage_whenVerificationDetailsIsNil_shouldNavigateToDeniedAccess() {

		// Given
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = nil
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = result

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
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = result

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
		environmentSpies.cryptoManagerSpy.stubbedVerifyQRMessageResult = result

		// When
		sut.parseQRMessage("test_verificationOK")

		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToCheckIdentity) == true
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToCheckIdentityParameters?.verificationDetails.firstNameInitial) == "A"
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToCheckIdentityParameters?.verificationDetails.lastNameInitial) == "B"
	}
}
