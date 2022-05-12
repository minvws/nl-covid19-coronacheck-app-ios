/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ScanInstructionsCoordinatorTests: XCTestCase {

	private var sut: ScanInstructionsCoordinator!

	private var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	private var scanInstructionsDelegateSpy: ScanInstructionsDelegateSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		navigationSpy = NavigationControllerSpy()
		scanInstructionsDelegateSpy = ScanInstructionsDelegateSpy()
		userSettingsSpy = UserSettingsSpy()
	}

	// MARK: - Tests
	
	func test_userDidCompletePages_withScanLock() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true
		)
		
		// When
		sut.userDidCompletePages(hasScanLock: true)
		
		// Then
		expect(self.scanInstructionsDelegateSpy.invokedScanInstructionsDidFinish) == true
		expect(self.scanInstructionsDelegateSpy.invokedScanInstructionsDidFinishParameters?.hasScanLock) == true
	}
	
	func test_userDidCompletePages_withoutScanLock() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true
		)
		
		// When
		sut.userDidCompletePages(hasScanLock: false)
		
		// Then
		expect(self.scanInstructionsDelegateSpy.invokedScanInstructionsDidFinish) == true
		expect(self.scanInstructionsDelegateSpy.invokedScanInstructionsDidFinishParameters?.hasScanLock) == false
	}
	
	func test_userDidCancelScanInstructions() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true
		)
		
		// When
		sut.userDidCancelScanInstructions()
		
		// Then
		expect(self.scanInstructionsDelegateSpy.invokedScanInstructionsWasCancelled) == true
	}
	
	func test_userWishesToSelectRiskSetting() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true
		)
		
		// When
		sut.userWishesToSelectRiskSetting()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RiskSettingInstructionViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToReadPolicyInformation() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true
		)
		
		// When
		sut.userWishesToReadPolicyInformation()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is PolicyInformationViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true
		)
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
	}
	
	func test_start_showPolicy() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true,
			userSettings: userSettingsSpy
		)
		userSettingsSpy.stubbedScanInstructionShown = true
		userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is PolicyInformationViewController) == true
	}
	
	func test_start_showRiskSetting() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: false,
			allowSkipInstruction: true,
			userSettings: userSettingsSpy
		)
		userSettingsSpy.stubbedScanInstructionShown = true
		userSettingsSpy.stubbedPolicyInformationShown = true
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RiskSettingInstructionViewController) == true
	}
	
	func test_start_showScanInstructions() {
		
		// Given
		sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: true,
			allowSkipInstruction: true,
			userSettings: userSettingsSpy
		)
		userSettingsSpy.stubbedScanInstructionShown = true
		userSettingsSpy.stubbedPolicyInformationShown = true
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
	}
}
