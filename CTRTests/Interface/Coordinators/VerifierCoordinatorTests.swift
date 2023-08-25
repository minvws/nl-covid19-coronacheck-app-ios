/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR
import Mobilecore

// swiftlint:disable type_body_length
class VerifierCoordinatorTests: XCTestCase {

	private var window = UIWindow()
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (VerifierCoordinator, NavigationControllerSpy, EnvironmentSpies) {
		
		let environmentSpies = setupEnvironmentSpies()
		let navigationSpy = NavigationControllerSpy()
		let sut = VerifierCoordinator(
			navigationController: navigationSpy,
			window: window
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, environmentSpies)
	}

	// MARK: - Tests
	
	func testStartNewFeatures() {

		// Given
		let (sut, _, environmentSpies) = makeSUT()
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			image: nil,
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]

		// When
		sut.start()

		// Then
		XCTAssertFalse(sut.childCoordinators.isEmpty)
		XCTAssertTrue(sut.childCoordinators.first is NewFeaturesCoordinator)
	}
	
	func testFinishNewFeatures() {

		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false

		sut.childCoordinators = [
			NewFeaturesCoordinator(
				navigationController: navigationSpy,
				newFeaturesManager: environmentSpies.newFeaturesManagerSpy,
				delegate: sut
			)
		]

		// When
		sut.finishNewFeatures()

		// Then
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	// MARK: - Universal Link -
	
	func test_consume_thirdPartyScannerApp() {
		
		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(sut.thirdPartyScannerApp?.name) == "CoronaCheck"
		expect(sut.thirdPartyScannerApp?.returnURL) == URL(string: "https://coronacheck.nl")
		expect(navigationSpy.viewControllers.last is VerifierScanViewController).toEventually(beTrue())
	}
	
	func test_consume_thirdPartyScannerApp_invalideScanLockState() {
		
		// Given
		let (sut, _, environmentSpies) = makeSUT()
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: Date())
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(sut.thirdPartyScannerApp) == nil
	}
	
	func test_consume_thirdPartyScannerApp_invalidRiskLevel() {
		
		// Given
		let (sut, _, environmentSpies) = makeSUT()
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(sut.thirdPartyScannerApp) == nil
	}
	
	func test_consume_thirdPartyScannerApp_domainNotAllowed() {
		
		// Given
		let (sut, _, environmentSpies) = makeSUT()
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "oronacheck.nl", name: "CoronaCheck")]
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://apple.com"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(sut.thirdPartyScannerApp) == nil
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let (sut, _, environmentSpies) = makeSUT()
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
		expect(sut.thirdPartyScannerApp) == nil
	}
	
	func test_navigateToVerifierWelcome() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.navigateToVerifierWelcome()
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.viewControllers.last is VerifierStartScanningViewController) == true
	}
	
	func test_navigateToVerifierWelcome_withNavigationStack() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		navigationSpy.viewControllers = [
			VerifierStartScanningViewController(viewModel: VerifierStartScanningViewModel(coordinator: sut)),
			DeniedAccessViewController(viewModel: DeniedAccessViewModel(coordinator: sut))
		]
		
		// When
		sut.navigateToVerifierWelcome()
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == true
		expect(navigationSpy.viewControllers.last is VerifierStartScanningViewController) == true
	}

	func test_didFinish_userTappedProceedToScan_scanInstructionsNotShown() {
		
		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown() {
		
		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown_withNavigationStack() {
		
		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		navigationSpy.viewControllers = [
			VerifierStartScanningViewController(viewModel: VerifierStartScanningViewModel(coordinator: sut)),
			VerifierScanViewController(viewModel: VerifierScanViewModel(coordinator: sut)),
			DeniedAccessViewController(viewModel: DeniedAccessViewModel(coordinator: sut))
		]
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 0
		expect(navigationSpy.invokedPopToViewController) == true
		expect(navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown_policyInformationNotShown() {
		
		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown_policy3G() {
		
		// Given
		let (sut, navigationSpy, environmentSpies) = makeSUT()
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScanInstructions() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScanInstructions)
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
		expect(sut.childCoordinators).to(haveCount(1))
	}
	
	func test_navigateToCheckIdentity() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let details = MobilecoreVerificationDetails()
		
		// When
		sut.navigateToCheckIdentity(details)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is CheckIdentityViewController) == true
	}
	
	func test_navigateToVerifiedAccess() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let access = VerifiedAccess.verified(.policy1G)
		
		// When
		sut.navigateToVerifiedAccess(access)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is VerifiedAccessViewController) == true
	}
	
	func test_navigateToDeniedAccess() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.navigateToDeniedAccess()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is DeniedAccessViewController) == true
	}
	
	func test_userWishesToOpenTheMenu() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.userWishesToOpenTheMenu()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is MenuViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutClockDeviation() throws {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutClockDeviation()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Controleer de tijd van je telefoon"
	}
	
	func test_userWishesToOpenScanLog() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.userWishesToOpenScanLog()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ScanLogViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToOpenRiskLevelSettings() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.navigateToOpenRiskLevelSettings()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is RiskSettingStartViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAboutThisApp() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.navigateToAboutThisApp()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is AboutThisAppViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAboutThisApp_userWishesToOpenScanLog() throws {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		sut.navigateToAboutThisApp()
		let viewModel = try XCTUnwrap((navigationSpy.viewControllers.last as? AboutThisAppViewController)?.viewModel)
		
		// When
		viewModel.outcomeHandler(.userWishesToOpenScanLog)
		
		// Then
		expect(navigationSpy.invokedPresent) == false
		expect(navigationSpy.pushViewControllerCallCount) == 2
		expect(navigationSpy.viewControllers.last is ScanLogViewController).toEventually(beTrue())
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToVerifiedInfo() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.navigateToVerifiedInfo()
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is VerifiedInfoViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToSetRiskLevel_shouldSelect() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.userWishesToSetRiskLevel(shouldSelectSetting: true)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is RiskSettingUnselectedViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToSetRiskLevel_shouldNotSelect() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.userWishesToSetRiskLevel(shouldSelectSetting: false)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is RiskSettingSelectedViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutDeniedQRScan() throws {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutDeniedQRScan()
				
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? DeniedQRScanMoreInfoViewController)?.viewModel)
		expect(viewModel.title) == "Wat kan ik doen?"
	}
	
	// MARK: ScanInstructions Delegate
	
	func test_scanInstructionsDidFinish_withScanLock() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		
		// When
		sut.scanInstructionsDidFinish(hasScanLock: true)
		
		// Then
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.viewControllers.last is VerifierStartScanningViewController) == true
	}
	
	func test_scanInstructionsDidFinish_withoutScanLock() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		sut.childCoordinators = [
			ScanInstructionsCoordinator(
				navigationController: sut.navigationController,
				delegate: sut,
				isOpenedFromMenu: true,
				allowSkipInstruction: true
			)
		]
		
		// When
		sut.scanInstructionsDidFinish(hasScanLock: false)
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.invokedPopToViewController) == false
		expect(navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_scanInstructionsWasCancelled() {
		
		// Given
		let (sut, navigationSpy, _) = makeSUT()
		sut.childCoordinators = [
			ScanInstructionsCoordinator(
				navigationController: sut.navigationController,
				delegate: sut,
				isOpenedFromMenu: true,
				allowSkipInstruction: true
			)
		]
		
		// When
		sut.scanInstructionsWasCancelled()
		
		// Then
		expect(navigationSpy.invokedPopViewController) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
}
// swiftlint:enable type_body_length
