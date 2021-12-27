/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble
import Clcore

final class CheckIdentityViewControllerTests: XCTestCase {
	
	/// Subject under test
	private var sut: CheckIdentityViewController!
	
	private var verifierCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: CheckIdentityViewModel!
	private var riskLevelManagerSpy: RiskLevelManagerSpy!
	private var featureFlagManagerSpy: FeatureFlagManagerSpy!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		riskLevelManagerSpy = RiskLevelManagerSpy()
		riskLevelManagerSpy.stubbedState = .low
		
		featureFlagManagerSpy = FeatureFlagManagerSpy()
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = true
		Services.use(featureFlagManagerSpy)
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_verified() throws {
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "NL"
		details.birthDay = "10"
		details.birthMonth = "J"
		details.firstNameInitial = "B"
		details.lastNameInitial = "C"
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.dccScanned).to(beNil())
		expect(self.sut.sceneView.dccFlag).to(beNil())
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.dayOfBirth) == "10"
		expect(self.sut.sceneView.monthOfBirth) == "J"
		expect(self.sut.sceneView.firstName) == "B"
		expect(self.sut.sceneView.lastName) == "C"
		expect(self.sut.sceneView.primaryButtonIcon).toNot(beNil())
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_noDeepLink() throws {
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "NL"
		details.birthDay = "10"
		details.birthMonth = "J"
		details.firstNameInitial = "B"
		details.lastNameInitial = "C"
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: false
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.dccScanned).to(beNil())
		expect(self.sut.sceneView.dccFlag).to(beNil())
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.dayOfBirth) == "10"
		expect(self.sut.sceneView.monthOfBirth) == "J"
		expect(self.sut.sceneView.firstName) == "B"
		expect(self.sut.sceneView.lastName) == "C"
		expect(self.sut.sceneView.primaryButtonIcon).to(beNil())
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_DCC() throws {
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = "IT"
		details.birthDay = "10"
		details.birthMonth = "J"
		details.firstNameInitial = "B"
		details.lastNameInitial = "C"
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.dccScanned) == L.verifierResultAccessDcc()
		expect(self.sut.sceneView.dccFlag) == "🇮🇹"
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.dayOfBirth) == "10"
		expect(self.sut.sceneView.monthOfBirth) == "J"
		expect(self.sut.sceneView.firstName) == "B"
		expect(self.sut.sceneView.lastName) == "C"
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_DCC_withoutFlag() throws {
		// Given
		let details = MobilecoreVerificationDetails()
		details.issuerCountryCode = ""
		details.birthDay = "10"
		details.birthMonth = "J"
		details.firstNameInitial = "B"
		details.lastNameInitial = "C"
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultAccessIdentityverified()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultAccessReadmore()
		expect(self.sut.sceneView.checkIdentity) == L.verifierResultAccessCheckidentity()
		expect(self.sut.sceneView.dccScanned) == L.verifierResultAccessDcc()
		expect(self.sut.sceneView.dccFlag).to(beNil())
		expect(self.sut.navigationItem.accessibilityLabel) == "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		expect(self.sut.title) == L.verifierResultIdentityTitle()
		expect(self.sut.sceneView.dayOfBirth) == "10"
		expect(self.sut.sceneView.monthOfBirth) == "J"
		expect(self.sut.sceneView.firstName) == "B"
		expect(self.sut.sceneView.lastName) == "C"
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_primaryButtonTapped_whenVerified_shouldNavigateToVerfiedInfo() {
		// Given
		riskLevelManagerSpy.stubbedState = .high
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: MobilecoreVerificationDetails(),
			isDeepLinkEnabled: true,
			riskLevelManager: riskLevelManagerSpy
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.footerButtonView.primaryButtonTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccess) == true
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedType) == .verified(.high)
	}
	
	func test_primaryButtonTapped_whenDemo_shouldNavigateToVerfiedInfo() {
		// Given
		riskLevelManagerSpy.stubbedState = .high
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true,
			riskLevelManager: riskLevelManagerSpy
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.identityVerifiedTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccess) == true
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedType) == .demo(.high)
	}
	
	func test_primaryButtonTapped_whenVerifiedAndFeatureFlagDisabled_shouldNavigateToVerfiedInfo() {
		// Given
		riskLevelManagerSpy.stubbedState = .high
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: MobilecoreVerificationDetails(),
			isDeepLinkEnabled: true,
			riskLevelManager: riskLevelManagerSpy
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.footerButtonView.primaryButtonTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccess) == true
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedType) == .verified(.low)
	}
	
	func test_primaryButtonTapped_whenDemoAndFeatureFlagDisabled_shouldNavigateToVerfiedInfo() {
		// Given
		riskLevelManagerSpy.stubbedState = .high
		featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		let details = MobilecoreVerificationDetails()
		details.isSpecimen = "1"
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: details,
			isDeepLinkEnabled: true,
			riskLevelManager: riskLevelManagerSpy
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.identityVerifiedTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccess) == true
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedAccessParameters?.verifiedType) == .demo(.low)
	}
	
	func test_readMoreTapped_shouldNavigateToVerifiedInfo() {
		// Given
		viewModel = CheckIdentityViewModel(
			coordinator: verifierCoordinatorDelegateSpy,
			verificationDetails: MobilecoreVerificationDetails(),
			isDeepLinkEnabled: true,
			riskLevelManager: riskLevelManagerSpy
		)
		sut = CheckIdentityViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.readMoreTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorDelegateSpy.invokedNavigateToVerifiedInfo) == true
	}
}