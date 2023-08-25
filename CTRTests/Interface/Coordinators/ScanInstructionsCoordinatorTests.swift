/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
@testable import CTR

class ScanInstructionsCoordinatorTests: XCTestCase {
	
	private func makeSUT(
		isOpenedFromMenu: Bool = false,
		file: StaticString = #filePath,
		line: UInt = #line) -> (ScanInstructionsCoordinator, NavigationControllerSpy, ScanInstructionsDelegateSpy, UserSettingsSpy, EnvironmentSpies) {
		
		let environmentSpies = setupEnvironmentSpies()
		let navigationSpy = NavigationControllerSpy()
		let scanInstructionsDelegateSpy = ScanInstructionsDelegateSpy()
		let userSettingsSpy = UserSettingsSpy()
		let sut = ScanInstructionsCoordinator(
			navigationController: navigationSpy,
			delegate: scanInstructionsDelegateSpy,
			isOpenedFromMenu: isOpenedFromMenu,
			allowSkipInstruction: true,
			userSettings: userSettingsSpy
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, scanInstructionsDelegateSpy, userSettingsSpy, environmentSpies)
	}
	
	// MARK: - Tests
	
	func test_userDidCompletePages_withScanLock() {
		
		// Given
		let (sut, _, scanInstructionsDelegateSpy, _, _) = makeSUT()
		
		// When
		sut.userDidCompletePages(hasScanLock: true)
		
		// Then
		expect(scanInstructionsDelegateSpy.invokedScanInstructionsDidFinish) == true
		expect(scanInstructionsDelegateSpy.invokedScanInstructionsDidFinishParameters?.hasScanLock) == true
	}
	
	func test_userDidCompletePages_withoutScanLock() {
		
		// Given
		let (sut, _, scanInstructionsDelegateSpy, _, _) = makeSUT()
		
		// When
		sut.userDidCompletePages(hasScanLock: false)
		
		// Then
		expect(scanInstructionsDelegateSpy.invokedScanInstructionsDidFinish) == true
		expect(scanInstructionsDelegateSpy.invokedScanInstructionsDidFinishParameters?.hasScanLock) == false
	}
	
	func test_userDidCancelScanInstructions() {
		
		// Given
		let (sut, _, scanInstructionsDelegateSpy, _, _) = makeSUT()
		
		// When
		sut.userDidCancelScanInstructions()
		
		// Then
		expect(scanInstructionsDelegateSpy.invokedScanInstructionsWasCancelled) == true
	}
	
	func test_userWishesToSelectRiskSetting() {
		
		// Given
		let (sut, navigationSpy, _, _, _) = makeSUT()
		
		// When
		sut.userWishesToSelectRiskSetting()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is RiskSettingInstructionViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToReadPolicyInformation() {
		
		// Given
		let (sut, navigationSpy, _, _, _) = makeSUT()
		
		// When
		sut.userWishesToReadPolicyInformation()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is PolicyInformationViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let (sut, _, _, _, _) = makeSUT()
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
		let (sut, navigationSpy, _, userSettingsSpy, environmentSpies) = makeSUT()
		userSettingsSpy.stubbedScanInstructionShown = true
		userSettingsSpy.stubbedPolicyInformationShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is PolicyInformationViewController) == true
	}
	
	func test_start_showRiskSetting() {
		
		// Given
		let (sut, navigationSpy, _, userSettingsSpy, environmentSpies) = makeSUT()
		userSettingsSpy.stubbedScanInstructionShown = true
		userSettingsSpy.stubbedPolicyInformationShown = true
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is RiskSettingInstructionViewController) == true
	}
	
	func test_start_showScanInstructions() {
		
		// Given
		let (sut, navigationSpy, _, userSettingsSpy, environmentSpies) = makeSUT(isOpenedFromMenu: true)
		userSettingsSpy.stubbedScanInstructionShown = true
		userSettingsSpy.stubbedPolicyInformationShown = true
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
	}
}
