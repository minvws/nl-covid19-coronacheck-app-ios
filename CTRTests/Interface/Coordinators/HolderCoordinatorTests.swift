/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import ReusableViews
import TestingShared
import Persistence
@testable import Models
@testable import Managers
@testable import Resources

class HolderCoordinatorTests: XCTestCase {

	var sut: HolderCoordinator!

	var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		navigationSpy = NavigationControllerSpy()
		sut = HolderCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}

	// MARK: - Tests

	func testRunsDatabaseCleanupOnStart() {
		// When
		sut.start()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveVaccinationAssessmentEventGroups) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveDomesticGreenCards) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveDraftEventGroups) == true
		expect(self.environmentSpies.walletManagerSpy.invokedExpireEventGroups) == true
	}
	
	func testStartNewFeatures() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		environmentSpies.newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]

		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).toNot(beEmpty())
		expect(self.sut.childCoordinators.first is NewFeaturesCoordinator) == true
	}

	func testFinishNewFeatures() {

		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false

		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false

		sut.childCoordinators = [
			NewFeaturesCoordinator(
				navigationController: navigationSpy,
				newFeaturesManager: NewFeaturesManagerSpy(),
				delegate: sut
			)
		]

		// When
		sut.finishNewFeatures()

		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	// MARK: - Universal Links -
	
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
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(1))
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController).toEventually(beTrue())
		expect(self.sut.unhandledUniversalLink) == nil
	}
	
	func test_consume_redeemHolder_needsOnboarding() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemHolder_needsConsent() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
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
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemHolder_needsUpdating() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_thirdPartyTicketApp() {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		let universalLink = UniversalLink.thirdPartyTicketApp(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdpartyTicketApp?.name) == "CoronaCheck"
		expect(self.sut.thirdpartyTicketApp?.returnURL) == URL(string: "https://coronacheck.nl")
	}
	
	func test_consume_thirdPartyTicketApp_domainNotAllowed() {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.universalLinkPermittedDomains = [UniversalLinkPermittedDomain(url: "coronacheck.nl", name: "CoronaCheck")]
		let universalLink = UniversalLink.thirdPartyTicketApp(returnURL: URL(string: "https://apple.com"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.thirdpartyTicketApp) == nil
	}
	
	func test_consume_tvsAuth() {
		
		// Given
		let universalLink = UniversalLink.tvsAuth(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
	}
	
	func test_consume_thirdPartyScannerApp() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
	}
	
	// MARK: - Navigate to -
	
	func test_navigateToChooseQRCodeType() {
		
		// Given
		
		// When
		sut.navigateToChooseQRCodeType()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseProofTypeViewModel.self))
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAddPaperProof() {
		
		// Given
		
		// When
		sut.navigateToAddPaperProof()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is PaperProofStartScanningViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
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
	
	func test_navigateToAboutThisApp_userWishesToOpenScanLog() throws {
		
		// Given
		sut.navigateToAboutThisApp()
		let viewModel = try XCTUnwrap((self.navigationSpy.viewControllers.last as? AboutThisAppViewController)?.viewModel)
		
		// When
		viewModel.outcomeHandler(.userWishesToOpenScanLog) // Should not be handled by HolderCoordinator
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateBackToStart() {
		
		// Given
		
		// When
		sut.navigateBackToStart()
		
		// Then
		expect(self.navigationSpy.invokedPopToRootViewController) == true
	}

	func test_presentDCCQRDetails() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.presentDCCQRDetails(
			title: "test title",
			description: "test description",
			details: [],
			dateInformation: "none"
		)
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? DCCQRDetailsViewController)?.viewModel)
		expect(viewModel.title) == "test title"
		expect(viewModel.description) == "test description"
		expect(viewModel.dateInformation) == "none"
	}
	
	// MARK: - User wishes to  -
	
	func test_userWishesToOpenTheMenu() {
		
		// Given
		
		// When
		sut.userWishesToOpenTheMenu()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is MenuViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}

	func test_userWishesToMakeQRFromRemoteEvent() {
		
		// Given
		
		// When
		sut.userWishesToMakeQRFromRemoteEvent(FakeRemoteEvent.fakeRemoteEventVaccination, originalMode: .vaccination)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListRemoteEventsViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
	}

	func test_userWishesToCreateANegativeTestQR() {
		
		// Given
		
		// When
		sut.userWishesToCreateANegativeTestQR()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToCreateAVisitorPass() {
		
		// Given
		
		// When
		sut.userWishesToCreateAVisitorPass()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToChooseTestLocation_GGDenabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDEnabledResult = true
		
		// When
		sut.userWishesToChooseTestLocation()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseTestLocationViewModel.self))
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToChooseTestLocation_GGDdisabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsGGDEnabledResult = false
		
		// When
		sut.userWishesToChooseTestLocation()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userHasNotBeenTested() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutGettingTested()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? MakeTestAppointmentViewController)?.viewModel)
		expect(viewModel.title) == L.holderNotestTitle()
		expect(viewModel.message) == L.holderNotestBody()
		expect(viewModel.buttonTitle) == L.holderNotestButtonTitle()
	}
	
	func test_userWishesToCreateANegativeTestQRFromGGD() {
		
		// Given
		
		// When
		sut.userWishesToCreateANegativeTestQRFromGGD()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
	}
	
	func test_userWishesToCreateAVaccinationQR() {
		
		// Given
		
		// When
		sut.userWishesToCreateAVaccinationQR()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
	}

	func test_userWishesToCreateARecoveryQR() {
		
		// Given
		
		// When
		sut.userWishesToCreateARecoveryQR()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is RemoteEventStartViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
	}
	
	func test_userWishesToCreateAQR() {
		
		// Given
		
		// When
		sut.userWishesToCreateAQR()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseProofTypeViewModel.self))
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
	
	func test_userWishesMoreInfoAboutOutdatedConfig() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutOutdatedConfig(validUntil: "test")
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Maak verbinding met het internet"
	}

	func test_userWishesMoreInfoAboutExpiredQR() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutExpiredQR()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Verlopen QR-code"
	}

	func test_userWishesMoreInfoAboutHiddenQR() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutHiddenQR()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Verborgen QR-code"
	}
	
	func test_userWishesToViewQRs() {
		
		// Given
		
		// When
		sut.userWishesToViewQRs(greenCardObjectIDs: [])
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_userWishesToViewQRs_differentContext() throws {
		
		// Given
		let dataStoreManager = DataStoreManager(.inMemory, persistentContainerName: "CoronaCheck", loadPersistentStoreCompletion: { _ in })
		var greenCard: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCard(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
			}
		}
		let greenCardObjectID = try XCTUnwrap(greenCard?.objectID)
		
		// When
		sut.userWishesToViewQRs(greenCardObjectIDs: [greenCardObjectID])
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_userWishesToViewQRs_sameContext() throws {
		
		// Given
		var greenCard: GreenCard?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCard(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
			}
		}
		let greenCardObjectID = try XCTUnwrap(greenCard?.objectID)
		
		// When
		sut.userWishesToViewQRs(greenCardObjectIDs: [greenCardObjectID])
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ShowQRViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_displayError() throws {
		
		// Given
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.presentError(content: content, backAction: {})
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
	}
	
	func test_userWishesMoreInfoAboutNoTestToken() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutNoTestToken()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Heb je geen ophaalcode?"
	}

	func test_userWishesMoreInfoAboutNoVisitorPassToken() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutNoVisitorPassToken()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Heb je geen beoordelingscode?"
	}
	
	func test_userWishesToSeeStoredEvents() {
		
		// Given
		
		// When
		sut.userWishesToSeeStoredEvents()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListStoredEventsViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesToSeeEventDetails() {
		
		// Given
		
		// When
		sut.userWishesToSeeEventDetails("test_userWishesToSeeEventDetails", details: [])
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is StoredEventDetailsViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	// MARK: - EventFlowDelegate -
	
	func test_eventFlowDidComplete() throws {
		
		// Given
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidComplete()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	func test_eventFlowDidCompleteButVisitorPassNeedsCompletion() {
		
		// Given
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCompleteButVisitorPassNeedsCompletion()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}

	func test_eventFlowDidCancel() {
		
		// Given
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCancel()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.invokedPopViewController) == false
	}
	
	// MARK: - PaperProofFlowDelegate -
	
	func test_addPaperProofFlowDidCancel() throws {
		
		// Given
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: navigationSpy, delegate: sut))
		
		// When
		sut.addPaperProofFlowDidCancel()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_addPaperProofFlowDidFinish() throws {
		
		// Given
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: navigationSpy, delegate: sut))
		
		// When
		sut.addPaperProofFlowDidFinish()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	func test_switchToAddRegularProof() throws {
		
		// Given
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: navigationSpy, delegate: sut))
		
		// When
		sut.switchToAddRegularProof()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseProofTypeViewModel.self))
	}
	
	func test_handleMismatchedIdentityError() {
		
		// Given
		
		// When
		sut.handleMismatchedIdentityError(matchingBlobIds: [["123"]])
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first).to(beAKindOf(FuzzyMatchingCoordinator.self))
		expect(self.navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
	}
	
	func test_fuzzyMatchingFlowDidStop() {
		
		// Given
		
		let fmCoordinator = FuzzyMatchingCoordinator(
			navigationController: sut.navigationController,
			matchingBlobIds: [[]],
			onboardingFactory: FuzzyMatchingOnboardingFactory(),
			delegate: sut
		)
		sut.childCoordinators = [fmCoordinator]
		
		// When
		fmCoordinator.userHasStoppedTheFlow()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.invokedPopToRootViewController) == true
	}
	
	func test_fuzzyMatchingFlowDidFinish() {
		
		// Given
		
		let fmCoordinator = FuzzyMatchingCoordinator(
			navigationController: sut.navigationController,
			matchingBlobIds: [[]],
			onboardingFactory: FuzzyMatchingOnboardingFactory(),
			delegate: sut
		)
		sut.childCoordinators = [fmCoordinator]
		
		// When
		fmCoordinator.userHasFinishedTheFlow()
		
		// Then
		expect(self.navigationSpy.invokedPopToRootViewController) == true
	}
}
