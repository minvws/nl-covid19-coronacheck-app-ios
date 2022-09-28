/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import Clcore

class VerifierCoordinatorTests: XCTestCase {

	private var sut: VerifierCoordinator!

	private var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	private var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()

		navigationSpy = NavigationControllerSpy()
		sut = VerifierCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests
	
	func testStartNewFeatures() {

		// Given
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
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	// MARK: - Universal Link -
	
	func test_consume_thirdPartyScannerApp() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdPartyScannerApp?.name) == "CoronaCheck"
		expect(self.sut.thirdPartyScannerApp?.returnURL) == URL(string: "https://coronacheck.nl")
		expect(self.navigationSpy.viewControllers.last is VerifierScanViewController).toEventually(beTrue())
	}
	
	func test_consume_thirdPartyScannerApp_invalideScanLockState() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		environmentSpies.scanLockManagerSpy.stubbedState = .locked(until: Date())
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy1G
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdPartyScannerApp) == nil
	}
	
	func test_consume_thirdPartyScannerApp_invalidRiskLevel() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		environmentSpies.scanLockManagerSpy.stubbedState = .unlocked
		environmentSpies.verificationPolicyManagerSpy.stubbedState = nil
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdPartyScannerApp) == nil
	}
	
	func test_consume_thirdPartyScannerApp_domainNotAllowed() {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "oronacheck.nl", name: "CoronaCheck")]
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://apple.com"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdPartyScannerApp) == nil
	}
	
	func test_consume_redeemHolder() {
		
		// Given
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
		expect(self.sut.thirdPartyScannerApp) == nil
	}
	
	func test_navigateToVerifierWelcome() {
		
		// Given
		
		// When
		sut.navigateToVerifierWelcome()
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.viewControllers.last is VerifierStartScanningViewController) == true
	}
	
	func test_navigateToVerifierWelcome_withNavigationStack() {
		
		// Given
		navigationSpy.viewControllers = [
			VerifierStartScanningViewController(viewModel: VerifierStartScanningViewModel(coordinator: sut)),
			DeniedAccessViewController(viewModel: DeniedAccessViewModel(coordinator: sut))
		]
		
		// When
		sut.navigateToVerifierWelcome()
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is VerifierStartScanningViewController) == true
	}

	func test_didFinish_userTappedProceedToScan_scanInstructionsNotShown() {
		
		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown() {
		
		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown_withNavigationStack() {
		
		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		navigationSpy.viewControllers = [
			VerifierStartScanningViewController(viewModel: VerifierStartScanningViewModel(coordinator: sut)),
			VerifierScanViewController(viewModel: VerifierScanViewModel(coordinator: sut)),
			DeniedAccessViewController(viewModel: DeniedAccessViewModel(coordinator: sut))
		]
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 0
		expect(self.navigationSpy.invokedPopToViewController) == true
		expect(self.navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown_policyInformationNotShown() {
		
		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = false
		environmentSpies.featureFlagManagerSpy.stubbedIs1GVerificationPolicyEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedPolicyInformationShown = false
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScan_scanInstructionsShown_policy3G() {
		
		// Given
		environmentSpies.userSettingsSpy.stubbedScanInstructionShown = true
		environmentSpies.verificationPolicyManagerSpy.stubbedState = .policy3G
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = false
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScan)
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_didFinish_userTappedProceedToScanInstructions() {
		
		// Given
		
		// When
		sut.didFinish(VerifierStartResult.userTappedProceedToScanInstructions)
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ScanInstructionsViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
	}
	
	func test_navigateToCheckIdentity() {
		
		// Given
		let details = MobilecoreVerificationDetails()
		
		// When
		sut.navigateToCheckIdentity(details)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is CheckIdentityViewController) == true
	}
	
	func test_navigateToVerifiedAccess() {
		
		// Given
		let access = VerifiedAccess.verified(.policy1G)
		
		// When
		sut.navigateToVerifiedAccess(access)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is VerifiedAccessViewController) == true
	}
	
	func test_navigateToDeniedAccess() {
		
		// Given
		
		// When
		sut.navigateToDeniedAccess()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is DeniedAccessViewController) == true
	}
	
	func test_userWishesToOpenTheMenu() {
		
		// Given
		
		// When
		sut.userWishesToOpenTheMenu()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is MenuViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutClockDeviation() throws {
		
		// Given
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
		
		// When
		sut.userWishesToOpenScanLog()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ScanLogViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToOpenRiskLevelSettings() {
		
		// Given
		
		// When
		sut.navigateToOpenRiskLevelSettings()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RiskSettingStartViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAboutThisApp() {
		
		// Given
		
		// When
		sut.navigateToAboutThisApp()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is AboutThisAppViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAboutThisApp_openURL() throws {
		
		// Given
		sut.navigateToAboutThisApp()
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? AboutThisAppViewController)?.viewModel)
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))
		
		// When
		viewModel.outcomeHandler(.openURL(url, inApp: true))
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAboutThisApp_userWishesToSeeStoredEvents() throws {
		
		// Given
		sut.navigateToAboutThisApp()
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? AboutThisAppViewController)?.viewModel)
		
		// When
		viewModel.outcomeHandler(.userWishesToSeeStoredEvents) // Should not be handled by the Verifier Coordinator
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAboutThisApp_userWishesToOpenScanLog() throws {
		
		// Given
		sut.navigateToAboutThisApp()
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? AboutThisAppViewController)?.viewModel)
		
		// When
		viewModel.outcomeHandler(.userWishesToOpenScanLog)
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 2
		expect(self.navigationSpy.viewControllers.last is ScanLogViewController).toEventually(beTrue())
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToVerifiedInfo() {
		
		// Given
		
		// When
		sut.navigateToVerifiedInfo()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is VerifiedInfoViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToSetRiskLevel_shouldSelect() {
		
		// Given
		
		// When
		sut.userWishesToSetRiskLevel(shouldSelectSetting: true)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RiskSettingUnselectedViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToSetRiskLevel_shouldNotSelect() {
		
		// Given
		
		// When
		sut.userWishesToSetRiskLevel(shouldSelectSetting: false)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RiskSettingSelectedViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutDeniedQRScan() throws {
		
		// Given
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
		
		// When
		sut.scanInstructionsDidFinish(hasScanLock: true)
		
		// Then
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.viewControllers.last is VerifierStartScanningViewController) == true
	}
	
	func test_scanInstructionsDidFinish_withoutScanLock() {
		
		// Given
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
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.invokedPopToViewController) == false
		expect(self.navigationSpy.viewControllers.last is VerifierScanViewController) == true
	}
	
	func test_scanInstructionsWasCancelled() {
		
		// Given
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
		expect(self.navigationSpy.invokedPopViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
}
