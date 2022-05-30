/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble

final class VerifiedAccessViewControllerTests: XCTestCase {
	
	/// Subject under test
	private var sut: VerifiedAccessViewController!
	
	private var environmentSpies: EnvironmentSpies!
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	
	var window = UIWindow()
	
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_demo_riskLevelLow_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .demo(.policy3G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title_policy(VerificationPolicy.policy3G.localization)
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_demo_riskLevelLow_verificationPolicyDisabled() {
		
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .demo(.policy3G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_demo_riskLevelHigh_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .demo(.policy1G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title_policy(VerificationPolicy.policy1G.localization)
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_demo_riskLevelHigh_verificationPolicyDisabled() {
		
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .demo(.policy1G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_riskLevelLow_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .verified(.policy3G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title_policy(VerificationPolicy.policy3G.localization)
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_riskLevelLow_verificationPolicyDisabled() {
		
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .verified(.policy3G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_riskLevelHigh_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .verified(.policy1G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title_policy(VerificationPolicy.policy1G.localization)
		expect(self.sut.preferredStatusBarStyle) == .lightContent
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_riskLevelHigh_verificationPolicyDisabled() {
		
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedAccess: .verified(.policy1G)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
}
