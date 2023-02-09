/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting
import Shared
import TestingShared

final class PolicyInformationViewControllerTests: XCTestCase {
	
	private var sut: PolicyInformationViewController!
	
	private var coordinatorSpy: ScanInstructionsCoordinatorDelegateSpy!
	private var viewModel: PolicyInformationViewModel!
	private var environmentSpies: EnvironmentSpies!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = ScanInstructionsCoordinatorDelegateSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	func test_view_whenMultipleVerificationPoliciesAreEnabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.tagline) == L.new_policy_subtitle()
		expect(self.sut.sceneView.title) == L.new_in_app_risksetting_title()
		expect(self.sut.sceneView.content) == L.new_in_app_risksetting_subtitle()
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_view_whenPolicyStateIsSetAndMultiplePoliciesAreEnabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.tagline) == L.new_policy_subtitle()
		expect(self.sut.sceneView.title) == L.new_in_app_risksetting_title()
		expect(self.sut.sceneView.content) == L.new_in_app_risksetting_subtitle()
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_view_whenMultipleVerificationPoliciesAreDisabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.tagline) == L.new_policy_subtitle()
		expect(self.sut.sceneView.title) == L.new_policy_1G_title()
		expect(self.sut.sceneView.content) == L.new_policy_1G_subtitle()
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_view_whenPolicyStateIsSetAndMultiplePoliciesAreDisabled() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.tagline) == L.new_policy_subtitle()
		expect(self.sut.sceneView.title) == L.new_policy_1G_title()
		expect(self.sut.sceneView.content) == L.new_policy_1G_subtitle()
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_primaryButtonTitle_whenPolicyStateIsNilAndMultiplePoliciesAreEnabled_shouldDisplayNext() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.generalNext()
	}
	
	func test_primaryButtonTitle_whenPolicyStateIsSetAndMultiplePoliciesAreEnabled_shouldDisplayStartScanning() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_primaryButtonTitle_whenOnlyPolicyStateIsSetAndMultiplePoliciesAreDisabled_shouldDisplayStartScanning() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
	
	func test_primaryButtonTitle_whenPolicyStateIsNilAndMultiplePoliciesAreDisabled_shouldDisplayStartScanning() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		sut = PolicyInformationViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.footerButtonView.primaryTitle) == L.verifierScaninstructionsButtonStartscanning()
	}
}
