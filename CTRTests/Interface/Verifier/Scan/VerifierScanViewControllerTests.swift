/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import ViewControllerPresentationSpy
@testable import CTR
import Shared
@testable import Models
@testable import Managers

class VerifierScanViewControllerTests: XCTestCase {

	private var sut: VerifierScanViewController!
	private var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		sut = VerifierScanViewController(viewModel: VerifierScanViewModel(coordinator: verifyCoordinatorDelegateSpy))
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests
	
	func test_showPermissionError() {
		
		// Given
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.showPermissionError()
		
		// Then
		alertVerifier.verify(
			title: L.verifierScanPermissionTitle(),
			message: L.verifierScanPermissionMessage(),
			animated: true,
			actions: [
				.default(L.verifierScanPermissionSettings()),
				.cancel(L.general_cancel())
			]
		)
	}
	
	func test_moreInformation() {
		
		// Given
		loadView()
		
		// When
		sut.sceneView.moreInformationButtonCommand?()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScanInstruction) == true
	}
	
	func test_parseQRMessage_shouldAddScanLogEntry_lowRisk_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G

		// When
		sut.found(code: "test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntryParameters?.verificationPolicy) == .policy3G
	}
	
	func test_parseQRMessage_shouldAddScanLogEntry_lowRisk_verification_policyDisabled() {

		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G

		// When
		sut.found(code: "test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == false
	}

	func test_parseQRMessage_shouldAddScanLogEntry_highRisk_verificationPolicyEnabled() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G

		// When
		sut.found(code: "test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == true
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntryParameters?.verificationPolicy) == .policy1G
	}
	
	func test_parseQRMessage_shouldAddScanLogEntry_highRisk_verification_policyDisabled() {

		// Given
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G

		// When
		sut.found(code: "test_parseQRMessage_shouldAddScanLogEntry")

		// Then
		expect(self.environmentSpies.scanLogManagerSpy.invokedAddScanEntry) == false
	}
}
