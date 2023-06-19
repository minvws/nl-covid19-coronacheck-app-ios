/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length file_length

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
import ViewControllerPresentationSpy

class HolderCoordinatorTests: XCTestCase {

	var sut: HolderCoordinator!

	var navigationSpy: NavigationControllerSpy!
	var environmentSpies: EnvironmentSpies!
	var alertVerifier: AlertVerifier?
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.featureFlagManagerSpy.stubbedIsAddingEventsEnabledResult = true
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = false
		navigationSpy = NavigationControllerSpy()
		alertVerifier = AlertVerifier()
		sut = HolderCoordinator(
			navigationController: navigationSpy,
			window: window
		)
	}
	
	override func tearDown() {
		super.tearDown()
		alertVerifier = nil
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
	
	func testRunsDatabaseCleanupOnStart_archiveModeEnabled() {
		// When
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = true
		sut.start()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveVaccinationAssessmentEventGroups) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveDomesticGreenCards) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveDraftEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedExpireEventGroups) == false
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
	
	func test_consume_redeemHolder_addEvents_disabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsAddingEventsEnabledResult = false
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
		expect(self.navigationSpy.pushViewControllerCallCount).toEventually(equal(0))
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
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel)
			.to(beAnInstanceOf(ChooseProofTypeViewModel.self))
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAddPaperProof() {
		
		// Given
		
		// When
		sut.navigateToAddPaperProof()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentWithImageViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ContentWithImageViewController)?.viewModel)
			.to(beAnInstanceOf(PaperProofStartScanningViewModel.self))
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

	func test_userWishesMoreInfoAboutExpiredQR_vaccination_notInArchiveMode() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = false
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutExpiredQR(type: .vaccination)
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Verlopen QR-code"
		expect(viewModel.content.body) == "<p>Als je QR-code is verlopen betekent dit dat je vaccinatie nog geldig is, maar het bewijs dat je hebt toegevoegd niet meer. Je kunt een nieuw bewijs met QR-code aanvragen en deze opnieuw toevoegen aan de app.</p><p>Heb je een nieuwere vaccinatie in de app staan? Dan kun je ook die QR-code gebruiken.</p>"
		expect(viewModel.content.secondaryActionTitle) == "Lees meer op CoronaCheck.nl"
		expect(viewModel.content.secondaryAction) != nil
	}
	
	func test_userWishesMoreInfoAboutExpiredQR_vaccination_inArchiveMode() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = true
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutExpiredQR(type: .vaccination)
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Verlopen QR-code"
		expect(viewModel.content.body) == "<p>Als je QR-code is verlopen betekent dit dat je vaccinatie nog geldig is, maar de QR-code in deze app niet meer. </p><p>Met verlopen QR-codes kun je nog wel aantonen dat je gevaccineerd bent. Je kunt deze QR-codes alleen niet overal meer als vaccinatiebewijs gebruiken.</p>"
		expect(viewModel.content.secondaryActionTitle) == nil
		expect(viewModel.content.secondaryAction) == nil
	}
	
	func test_userWishesMoreInfoAboutExpiredQR_recovery_inArchiveMode() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = true
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutExpiredQR(type: .recovery)
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? BottomSheetContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Verlopen QR-code"
		expect(viewModel.content.body) == "<p>Als de QR-code van je herstelbewijs is verlopen betekent dit dat je positieve testuitslag ouder dan 180 dagen is.</p><p>Met een verlopen QR-code kun je nog wel aantonen dat je ooit corona hebt gehad. Je kunt deze QR-code alleen niet meer als herstelbewijs gebruiken.</p>"
		expect(viewModel.content.secondaryActionTitle) == nil
		expect(viewModel.content.secondaryAction) == nil
	}

	func test_userWishesMoreInfoAboutHiddenQR() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = false
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
		expect(viewModel.content.body) == "<p>Als de QR-code van je vaccinatie verborgen is, dan heb je deze waarschijnlijk niet nodig. Dit komt omdat je ook QR-codes van nieuwere vaccinaties in de app hebt staan.</p><p>Verborgen QR-codes kun je gewoon nog laten zien en gebruiken als dat nodig is.</p>"
		expect(viewModel.content.secondaryActionTitle) == "Lees meer op CoronaCheck.nl"
		expect(viewModel.content.secondaryAction) != nil
	}
	
	func test_userWishesMoreInfoAboutHiddenQR_inArchiveMode() throws {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIsInArchiveModeResult = true
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
		expect(viewModel.content.body) == "<p>QR-codes worden verborgen als je ook QR-codes van nieuwere vaccinaties in de app hebt staan.</p><p>Verborgen QR-codes kun je gewoon nog laten zien als dat nodig is.</p>"
		expect(viewModel.content.secondaryActionTitle) == nil
		expect(viewModel.content.secondaryAction) == nil
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
					type: .eu,
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
					type: .eu,
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
	
	func test_migrationIsSuccessful() {
		
		// Given
		
		// When
		sut.showMigrationSuccessfulDialog()
		
		// Then
		alertVerifier?.verify(
			title: L.holder_migrationFlow_deleteDetails_dialog_title(),
			message: L.holder_migrationFlow_deleteDetails_dialog_message(),
			animated: true,
			actions: [
				.destructive(L.holder_migrationFlow_deleteDetails_dialog_deleteButton()),
				.default(L.holder_migrationFlow_deleteDetails_dialog_retainButton())
			]
		)
	}
	
	func test_removeDataAfterMigration_cancel() throws {
		
		// Given
		sut.showMigrationSuccessfulDialog()
		
		// When
		try alertVerifier?.executeAction(forButton: L.holder_migrationFlow_deleteDetails_dialog_retainButton())
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingBlockedEvents) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingMismatchedIdentityEvents) == false
	}
	
	func test_removeDataAfterMigration_remove() throws {
		
		// Given
		sut.showMigrationSuccessfulDialog()
		
		// When
		try alertVerifier?.executeAction(forButton: L.holder_migrationFlow_deleteDetails_dialog_deleteButton())
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingBlockedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingMismatchedIdentityEvents) == true
	}
}
