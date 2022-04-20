/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import XCTest
@testable import CTR
import Nimble

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
	
	func test_handleDisclosurePolicyUpdates_needsOnboarding() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = true
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
	}
	
	func test_handleDisclosurePolicyUpdates_shouldShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = true
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = ["3G"]
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_handleDisclosurePolicyUpdates_shouldNotShow() {
		
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.disclosurePolicyManagingSpy.stubbedHasChanges = false
		
		// When
		sut.handleDisclosurePolicyUpdates()
		
		// Then
		expect(self.navigationSpy.invokedPresent) == false
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
		expect(self.sut.unhandledUniversalLink).to(beNil())
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
	
	func test_consume_redeemVaccinationAssessment() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
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
		expect(self.sut.unhandledUniversalLink).to(beNil())
	}
	
	func test_consume_redeemVaccinationAssessment_needsOnboarding() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = true
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
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
	
	func test_consume_redeemVaccinationAssessment_needsConsent() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = true
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = false
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
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
	
	func test_consume_redeemVaccinationAssessment_needsUpdating() {
		
		// Given
		environmentSpies.onboardingManagerSpy.stubbedNeedsConsent = false
		environmentSpies.onboardingManagerSpy.stubbedNeedsOnboarding = false
		environmentSpies.newFeaturesManagerSpy.stubbedNeedsUpdating = true
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
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
		expect(self.sut.thirdpartyTicketApp).to(beNil())
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
		expect(self.navigationSpy.viewControllers.last is ChooseProofTypeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_navigateToAddPaperProof() {
		
		// Given
		
		// When
		sut.navigateToAddPaperProof()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is PaperProofStartViewController) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
	}
	
	func test_navigateToAddVisitorPass() {
		
		// Given
		
		// When
		sut.navigateToAddVisitorPass()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is VisitorPassStartViewController) == true
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
		expect(self.navigationSpy.viewControllers.last is ChooseTestLocationViewController) == true
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
		sut.userHasNotBeenTested()
		
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
		expect(self.navigationSpy.viewControllers.last is ChooseProofTypeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userDidScanRequestToken() {
		
		// Given
		
		// When
		sut.userDidScanRequestToken(
			requestToken: RequestToken(
				token: "STXT2VF3389TJ2",
				protocolVersion: "3.0",
				providerIdentifier: "XXX"
			)
		)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is InputRetrievalCodeViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutUnavailableQR() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutUnavailableQR(originType: .vaccination, currentRegion: .domestic, availableRegion: .europeanUnion)
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Over je vaccinatiebewijs"
	}
	
	func test_userWishesMoreInfoAboutCompletingVaccinationAssessment() {
		
		// Given
		
		// When
		sut.userWishesMoreInfoAboutCompletingVaccinationAssessment()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is VisitorPassCompleteCertificateViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Over je bezoekersbewijs"
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
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
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
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Maak verbinding met het internet"
	}
	
	func test_userWishesMoreInfoAboutIncompleteDutchVaccination() {
		
		// Given
		
		// When
		sut.userWishesMoreInfoAboutIncompleteDutchVaccination()
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is IncompleteDutchVaccinationViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_userWishesMoreInfoAboutExpiredDomesticVaccination() throws {
		
		// Given
		let viewControllerSpy = ViewControllerSpy()
		navigationSpy.viewControllers = [
			viewControllerSpy
		]
		
		// When
		sut.userWishesMoreInfoAboutExpiredDomesticVaccination()
		
		// Then
		expect(viewControllerSpy.presentCalled) == true
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == "Verlopen vaccinatiebewijs"
	}
	
	func test_userWishesToViewQRs() {
		
		// Given
		
		// When
		sut.userWishesToViewQRs(greenCardObjectIDs: [], disclosurePolicy: nil)
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_userWishesToViewQRs_differentContext() throws {
		
		// Given
		let dataStoreManager = DataStoreManager(.inMemory)
		var greenCard: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
			}
		}
		let greenCardObjectID = try XCTUnwrap(greenCard?.objectID)
		
		// When
		sut.userWishesToViewQRs(greenCardObjectIDs: [greenCardObjectID], disclosurePolicy: nil)
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
	}
	
	func test_userWishesToViewQRs_sameContext() throws {
		
		// Given
		var greenCard: GreenCard?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
			}
		}
		let greenCardObjectID = try XCTUnwrap(greenCard?.objectID)
		
		// When
		sut.userWishesToViewQRs(greenCardObjectIDs: [greenCardObjectID], disclosurePolicy: nil)
		
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
		sut.displayError(content: content, backAction: {})
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ErrorStateViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? ErrorStateViewController)?.viewModel)
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
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
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
		let viewModel = try XCTUnwrap(((viewControllerSpy.thePresentedViewController as? BottomSheetModalViewController)?.childViewController as? ContentViewController)?.viewModel)
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
		expect(self.navigationSpy.invokedPopViewController) == true
	}
	
	func test_eventFlowDidCancelFromBackSwipe() {
		
		// Given
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCancelFromBackSwipe()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
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
		expect(self.navigationSpy.viewControllers.last is ChooseProofTypeViewController) == true
	}
}
