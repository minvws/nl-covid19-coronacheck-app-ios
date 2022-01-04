/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length

import UIKit
import CoreData
import Reachability

protocol HolderCoordinatorDelegate: AnyObject {

	// MARK: Navigation

	/// Navigate to the start fo the holder flow
	func navigateBackToStart()

	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool)
	
	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String)

	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent)

	func userWishesToCreateAQR()

	func userWishesToCreateANegativeTestQR()
	
	func userWishesToCreateAVisitorPass()

	func userWishesToChooseLocation()

	func userHasNotBeenTested()

	func userWishesToCreateANegativeTestQRFromGGD()

	func userWishesToCreateAVaccinationQR()

	func userWishesToCreateARecoveryQR()

	func userWishesToFetchPositiveTests()

	func userDidScanRequestToken(requestToken: RequestToken)

	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion)

	func userWishesMoreInfoAboutClockDeviation()
	
	func userWishesMoreInfoAboutTestOnlyValidFor3G()

	func userWishesMoreInfoAboutUpgradingEUVaccinations()

	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String)
	
    func userWishesMoreInfoAboutRecoveryValidityExtension()

	func userWishesMoreInfoAboutRecoveryValidityReinstation()
	
	func userWishesMoreInfoAboutIncompleteDutchVaccination()

	func userWishesMoreInfoAboutMultipleDCCUpgradeCompleted()

	func userWishesMoreInfoAboutRecoveryValidityExtensionCompleted()
	
	func userWishesMoreInfoAboutRecoveryValidityReinstationCompleted()
	
	func openUrl(_ url: URL, inApp: Bool)

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID])

	func userWishesToLaunchThirdPartyTicketApp()

	func displayError(content: Content, backAction: @escaping () -> Void)

	func migrateEUVaccinationDidComplete()

	func extendRecoveryValidityDidComplete()
	
	func userWishesMoreInfoAboutNoTestToken()
	
	func userWishesMoreInfoAboutNoVisitorPassToken()
}

// swiftlint:enable class_delegate_protocol

class HolderCoordinator: SharedCoordinator {

	var userSettings: UserSettingsProtocol = UserSettings()
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()

	let recoveryValidityExtensionManager: RecoveryValidityExtensionManager = {
		RecoveryValidityExtensionManager(
			userHasRecoveryEvents: {
				let eventGroups = Services.walletManager.listEventGroups()
				let hasRecoveryEvents = eventGroups.contains { $0.type == OriginType.recovery.rawValue }
				return hasRecoveryEvents
			},
			userHasUnexpiredRecoveryGreencards: {
				let unexpiredGreencards = Services.walletManager.greencardsWithUnexpiredOrigins(
					now: Date(),
					ofOriginType: OriginType.recovery
				)

				let hasUnexpiredRecoveryGreencards = !unexpiredGreencards.isEmpty
				return hasUnexpiredRecoveryGreencards
			},
			userHasPaperflowRecoveryGreencards: {

				return Services.walletManager.hasEventGroup(
					type: EventMode.recovery.rawValue,
					providerIdentifier: EventFlow.paperproofIdentier
				)
			},
			userSettings: UserSettings(),
			remoteConfigManager: Services.remoteConfigManager,
			now: { Date() }
		)
	}()

	///	A (whitelisted) third-party can open the app & - if they provide a return URL, we will
	///	display a "return to Ticket App" button on the ShowQR screen
	/// Docs: https://shrtm.nu/oc45
	private var thirdpartyTicketApp: (name: String, returnURL: URL)?

	/// If set, this should be handled at the first opportunity:
	private var unhandledUniversalLink: UniversalLink?

	/// Restricts access to GGD test provider login
	private var isGGDEnabled: Bool {
		return remoteConfigManager.storedConfiguration.isGGDEnabled == true
	}
	
	// MARK: - Setup
	
	override init(navigationController: UINavigationController, window: UIWindow) {
		super.init(navigationController: navigationController, window: window)
		setupNotificationListeners()
	}
	
	// Designated starter method
	override func start() {

		handleOnboarding(
			onboardingFactory: onboardingFactory,
			forcedInformationFactory: HolderForcedInformationFactory()
		) {
			
			if let unhandledUniversalLink = unhandledUniversalLink {
				
				// Attempt to consume the universal link again:
				self.unhandledUniversalLink = nil // prevent potential infinite loops
				navigateToHolderStart {
					self.consume(universalLink: unhandledUniversalLink)
				}

			} else {

				// Start with the holder app
				navigateToHolderStart()
			}
		}
	}
	
	// MARK: - Teardown

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Listeners
	
	private func setupNotificationListeners() {
		
		// Prevent the thirdparty ticket feature persisting forever, let's clear it when the user minimises the app
		NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.thirdpartyTicketApp = nil
		}
	}

    // MARK: - Universal Links

    /// Try to consume the Activity
    /// returns: bool indicating whether it was possible.
    @discardableResult
    override func consume(universalLink: UniversalLink) -> Bool {
		switch universalLink {
			case .redeemHolderToken(let requestToken):

				// Need to handle two situations:
				// - the user is currently viewing onboarding/consent/force-information (and these should not be skipped)
				//   ⮑ in this situation, it is nice to keep hold of the UniversalLink and go straight to handling
				//      that after the user has completed these screens.
				// - the user is somewhere in the Holder app, and the nav stack can just be replaced.

				if onboardingManager.needsOnboarding || onboardingManager.needsConsent || forcedInformationManager.needsUpdating {
					self.unhandledUniversalLink = universalLink
				} else {
					// Do it on the next runloop, to standardise all the entry points to this function:
					DispatchQueue.main.async { [self] in
						navigateToTokenEntry(requestToken)
					}
				}
				return true
				
			case .redeemVaccinationAssessment(let requestToken):
				
				// Need to handle two situations:
				// - the user is currently viewing onboarding/consent/force-information (and these should not be skipped)
				//   ⮑ in this situation, it is nice to keep hold of the UniversalLink and go straight to handling
				//      that after the user has completed these screens.
				// - the user is somewhere in the Holder app, and the nav stack can just be replaced.
				
				if onboardingManager.needsOnboarding || onboardingManager.needsConsent || forcedInformationManager.needsUpdating {
					self.unhandledUniversalLink = universalLink
				} else {
					// Do it on the next runloop, to standardise all the entry points to this function:
					DispatchQueue.main.async { [self] in
						navigateToTokenEntry(requestToken, retrievalMode: .visitorPass)
					}
				}
				return true

			case .thirdPartyTicketApp(let returnURL):
				guard let returnURL = returnURL,
					  let matchingMetadata = remoteConfigManager.storedConfiguration.universalLinkPermittedDomains?.first(where: { permittedDomain in
						  permittedDomain.url == returnURL.host
					  })
				else {
					return true
				}

				thirdpartyTicketApp = (name: matchingMetadata.name, returnURL: returnURL)

				// Reset the dashboard back to the domestic tab:
				if let dashboardViewController = dashboardNavigationController?.viewControllers.last as? HolderDashboardViewController {
					dashboardViewController.viewModel.selectTab = .domestic
				}
				return true
				
			case .tvsAuth(let returnURL):
				
				if let url = returnURL,
				   let appAuthState = UIApplication.shared.delegate as? AppAuthState,
				   let authorizationFlow = appAuthState.currentAuthorizationFlow,
				   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
					appAuthState.currentAuthorizationFlow = nil
				}
				return true
			default:
				return false
		}
    }

	private func startEventFlowForVaccination() {

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithVaccination()
		}
	}

	private func startEventFlowForRecovery() {

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithRecovery()
		}
	}
	
	private func startEventFlowForNegativeTest() {
		
		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithNegativeTest()
		}
	}

	private func startEventFlowForPositiveTests() {

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithPositiveTest()
		}
	}

	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken? = nil, retrievalMode: InputRetrievalCodeMode = .negativeTest) {

		let destination = TokenEntryViewController(
			viewModel: TokenEntryViewModel(
				coordinator: self,
				requestToken: token,
				tokenValidator: TokenValidator(isLuhnCheckEnabled: remoteConfigManager.storedConfiguration.isLuhnCheckEnabled ?? false),
				inputRetrievalCodeMode: retrievalMode
			)
		)

		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	// "Waar wil je een QR-code van maken?"
	func navigateToChooseQRCodeType() {
		let destination = ChooseQRCodeTypeViewController(
			viewModel: ChooseQRCodeTypeViewModel(
				coordinator: self
			),
			isRootViewController: false
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}
	
	private func navigateToDashboard() {
		
		let dashboardViewController = HolderDashboardViewController(
			viewModel: HolderDashboardViewModel(
				coordinator: self,
				datasource: HolderDashboardQRCardDatasource(now: { Date() }),
				strippenRefresher: DashboardStrippenRefresher(
					minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: remoteConfigManager.storedConfiguration.credentialRenewalDays ?? 5,
					reachability: try? Reachability(),
					now: { Date() }
				),
				userSettings: UserSettings(),
				dccMigrationNotificationManager: DCCMigrationNotificationManager(userSettings: userSettings),
				recoveryValidityExtensionManager: recoveryValidityExtensionManager,
				configurationNotificationManager: ConfigurationNotificationManager(userSettings: userSettings),
				versionSupplier: versionSupplier,
				now: { Date() }
			)
		)
		dashboardNavigationController = NavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationController
	}
	
	private func removeChildCoordinator() {
		
		guard let coordinator = childCoordinators.last else { return }
		removeChildCoordinator(coordinator)
	}

}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {

	// MARK: Navigation

    func navigateToHolderStart(completion: (() -> Void)? = nil) {

		let menu = MenuViewController(
			viewModel: MenuViewModel(
				delegate: self
			)
		)
		sidePanel = SidePanelController(sideController: NavigationController(rootViewController: menu))
		navigateToDashboard()

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel

        DispatchQueue.main.async {
            completion?()
        }
	}

	/// Navigate to enlarged QR
	private func navigateToShowQRs(_ greenCards: [GreenCard]) {

		let destination = ShowQRViewController(
			viewModel: ShowQRViewModel(
				coordinator: self,
				greenCards: greenCards,
				thirdPartyTicketAppName: thirdpartyTicketApp?.name
			)
		)

		destination.modalPresentationStyle = .fullScreen
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	private func navigateToChooseTestLocation() {

		let destination = ChooseTestLocationViewController(
			viewModel: ChooseTestLocationViewModel(
				coordinator: self
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to the start fo the holder flow
	func navigateBackToStart() {

		sidePanel?.selectedViewController?.dismiss(animated: true, completion: nil)
		(sidePanel?.selectedViewController as? UINavigationController)?.popToRootViewController(animated: true)
	}
	
	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String) {
		
		let viewController = DCCQRDetailsViewController(
			viewModel: DCCQRDetailsViewModel(
				coordinator: self,
				title: title,
				description: description,
				details: details,
				dateInformation: dateInformation
			)
		)
		presentAsBottomSheet(viewController)
	}

	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent) {

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithListTestEvents([remoteEvent])
		}
	}

	func userWishesToCreateANegativeTestQR() {
		navigateToTokenEntry()
	}
	
	func userWishesToCreateAVisitorPass() {
//		navigateToTokenEntry(RequestToken(token: "QTULGFYS26T98U", protocolVersion: "3.0", providerIdentifier: "ZZZ"), retrievalMode: .visitorPass)
		
		navigateToTokenEntry(retrievalMode: .visitorPass)
	}

	func userWishesToChooseLocation() {
		if isGGDEnabled {
			navigateToChooseTestLocation()
		} else {
			// Fallback when GGD is not available
			navigateToTokenEntry()
		}
	}

	func userHasNotBeenTested() {
		
		let viewController = MakeTestAppointmentViewController(
			viewModel: MakeTestAppointmentViewModel(
				coordinator: self,
				title: L.holderNotestTitle(),
				message: String(format: L.holderNotestBody()),
				buttonTitle: L.holderNotestButtonTitle()
			)
		)
		presentAsBottomSheet(viewController)
	}

	func userWishesToCreateANegativeTestQRFromGGD() {
		startEventFlowForNegativeTest()
	}

	func userWishesToCreateAVaccinationQR() {
		startEventFlowForVaccination()
	}

	func userWishesToCreateARecoveryQR() {
		startEventFlowForRecovery()
	}

	func userWishesToFetchPositiveTests() {
		startEventFlowForPositiveTests()
	}

	func userWishesToCreateAQR() {
		navigateToChooseQRCodeType()
	}

	func userDidScanRequestToken(requestToken: RequestToken) {
		navigateToTokenEntry(requestToken)
	}

	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) {

		let title: String = .holderDashboardNotValidInThisRegionScreenTitle(originType: originType, currentRegion: currentRegion, availableRegion: availableRegion)
		let message: String = .holderDashboardNotValidInThisRegionScreenMessage(originType: originType, currentRegion: currentRegion, availableRegion: availableRegion)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false)
	}

	func userWishesMoreInfoAboutClockDeviation() {
		let title: String = L.holderClockDeviationDetectedTitle()
		let message: String = L.holderClockDeviationDetectedMessage(UIApplication.openSettingsURLString)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}
	
	func userWishesMoreInfoAboutTestOnlyValidFor3G() {
		let title: String = L.holder_my_overview_3g_test_validity_bottom_sheet_title()
		let message: String = L.holder_my_overview_3g_test_validity_bottom_sheet_body()
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}

	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String) {
		let title: String = L.holderDashboardConfigIsAlmostOutOfDatePageTitle()
		let message: String = L.holderDashboardConfigIsAlmostOutOfDatePageMessage(validUntil)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}

	func userWishesMoreInfoAboutUpgradingEUVaccinations() {
		let viewModel = MigrateEUVaccinationViewModel(
			backAction: { [weak self] in
				(self?.sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true)
			},
			greencardLoader: GreenCardLoader(),
			userSettings: userSettings
		)
		viewModel.coordinator = self
		let viewController = MigrateEUVaccinationViewController(viewModel: viewModel)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}

	func userWishesMoreInfoAboutRecoveryValidityExtension() {
		let viewModel = ExtendRecoveryValidityViewModel(
			mode: .extend,
			backAction: { [weak self] in
				(self?.sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true)
			},
			greencardLoader: GreenCardLoader(),
			userSettings: userSettings
		)
		viewModel.coordinator = self
		let viewController = ExtendRecoveryValidityViewController(viewModel: viewModel)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}

	func userWishesMoreInfoAboutRecoveryValidityReinstation() {
		let viewModel = ExtendRecoveryValidityViewModel(
			mode: .reinstate,
			backAction: { [weak self] in
				(self?.sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true)
			},
			greencardLoader: GreenCardLoader(),
			userSettings: userSettings
		)
		viewModel.coordinator = self
		let viewController = ExtendRecoveryValidityViewController(viewModel: viewModel)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}

	func userWishesMoreInfoAboutIncompleteDutchVaccination() {
		let viewModel = IncompleteDutchVaccinationViewModel(coordinatorDelegate: self)
		let viewController = IncompleteDutchVaccinationViewController(viewModel: viewModel)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}
	
	func userWishesMoreInfoAboutMultipleDCCUpgradeCompleted() {
		presentInformationPage(
			title: L.holderEuvaccinationswereupgradedTitle(),
			body: L.holderEuvaccinationswereupgradedMessage(),
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
	func userWishesMoreInfoAboutRecoveryValidityExtensionCompleted() {
		presentInformationPage(
			title: L.holderRecoveryvalidityextensionExtensioncompleteTitle(),
			body: L.holderRecoveryvalidityextensionExtensioncompleteDescription(),
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
	func userWishesMoreInfoAboutRecoveryValidityReinstationCompleted() {
		presentInformationPage(
			title: L.holderRecoveryvalidityextensionReinstationcompleteTitle(),
			body: L.holderRecoveryvalidityextensionReinstationcompleteDescription(),
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
	func migrateEUVaccinationDidComplete() {

		(sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true, completion: {})
	}

	func extendRecoveryValidityDidComplete() {

		recoveryValidityExtensionManager.reload()

		(sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true, completion: {})
	}

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID]) {

		let result = GreenCardModel.fetchByIds(objectIDs: greenCardObjectIDs)
		switch result {
			case let .success(greenCards):
				if greenCards.isEmpty {
					showAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .noGreenCardsAvailable))
				} else {
					navigateToShowQRs(greenCards)
				}
			case .failure:
				showAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .coreDataFetchError))
		}
	}

	private func showAlertWithErrorCode(_ code: ErrorCode) {
		
		let alertController = UIAlertController(
			title: L.generalErrorTitle(),
			message: L.generalErrorTechnicalCustom("\(code)"),
			preferredStyle: .alert
		)

		alertController.addAction(.init(title: L.generalOk(), style: .default, handler: nil))
		(sidePanel?.selectedViewController as? UINavigationController)?.present(alertController, animated: true, completion: nil)
	}

	func userWishesToLaunchThirdPartyTicketApp() {
		guard let thirdpartyTicketApp = thirdpartyTicketApp else { return }
		openUrl(thirdpartyTicketApp.returnURL, inApp: false)
	}

	func displayError(content: Content, backAction: @escaping () -> Void) {

		let viewController = ErrorStateViewController(
			viewModel: ErrorStateViewModel(
				content: content,
				backAction: backAction
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: false)
	}
	
	func userWishesMoreInfoAboutNoTestToken() {
		
		presentInformationPage(
			title: L.holderTokenentryModalNotokenTitle(),
			body: L.holderTokenentryModalNotokenDetails(),
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
	func userWishesMoreInfoAboutNoVisitorPassToken() {
		
		presentInformationPage(
			title: L.visitorpass_token_modal_notoken_title(),
			body: L.visitorpass_token_modal_notoken_details(),
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
}

// MARK: - MenuDelegate

extension HolderCoordinator: MenuDelegate {

	/// Close the menu
	func closeMenu() {

		sidePanel?.hideSidePanel()
	}

	/// Open a menu item
	/// - Parameter identifier: the menu identifier
	func openMenuItem(_ identifier: MenuIdentifier) {
		
		// Clean up child coordinator. Faq is not replacing side panel view controller
		if identifier != .faq {
			removeChildCoordinator()
		}

		switch identifier {
			case .overview:
				dashboardNavigationController?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationController

			case .faq:
				guard let faqUrl = URL(string: L.holderUrlFaq()) else {
					logError("No holder FAQ url")
					return
				}
				openUrl(faqUrl, inApp: true)

			case .about:
				let destination = AboutThisAppViewController(
					viewModel: AboutThisAppViewModel(
						coordinator: self,
						versionSupplier: versionSupplier,
						flavor: AppFlavor.flavor,
						userSettings: UserSettings()
					)
				)
				aboutNavigationController = NavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = aboutNavigationController

			case .addCertificate:
				let destination = ChooseQRCodeTypeViewController(
					viewModel: ChooseQRCodeTypeViewModel(
						coordinator: self
					),
					isRootViewController: true
				)
				navigationController = NavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = navigationController
				
			case .addPaperProof:
				let coordinator = PaperProofCoordinator(delegate: self)
				let destination = PaperProofStartViewController(viewModel: .init(coordinator: coordinator))
				navigationController = NavigationController(rootViewController: destination)
				coordinator.navigationController = navigationController
				startChildCoordinator(coordinator)
				sidePanel?.selectedViewController = navigationController
				
			case .visitorPass:

				let destination = VisitorPassStartViewController(viewModel: VisitorPassStartViewModel(coordinator: self))
				navigationController = NavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = navigationController

			default:
				self.logInfo("User tapped on \(identifier), not implemented")

				let destinationViewController = PlaceholderViewController()
				destinationViewController.placeholder = "\(identifier)"
				let navigationController = NavigationController(rootViewController: destinationViewController)
				sidePanel?.selectedViewController = navigationController
		}
		fixRotation()
	}

	func fixRotation() {
		
		if let frame = sidePanel?.view.frame {
			sidePanel?.selectedViewController?.view.frame = frame
		}
	}

	/// Get the items for the top menu
	/// - Returns: the top menu items
	func getTopMenuItems() -> [MenuItem] {

		return [
			MenuItem(identifier: .overview, title: L.holderMenuDashboard()),
			MenuItem(identifier: .addCertificate, title: L.holderMenuProof()),
			MenuItem(identifier: .faq, title: L.holderMenuFaq())
		]
	}
	/// Get the items for the bottom menu
	/// - Returns: the bottom menu items
	func getBottomMenuItems() -> [MenuItem] {
		
		if Services.featureFlagManager.isVisitorPassEnabled() {
			return [
				MenuItem(identifier: .about, title: L.holderMenuAbout()),
				MenuItem(identifier: .addPaperProof, title: L.holderMenuPapercertificate()),
				MenuItem(identifier: .visitorPass, title: L.holder_menu_visitorpass())
			]
		} else {
			return [
				MenuItem(identifier: .addPaperProof, title: L.holderMenuPapercertificate()),
				MenuItem(identifier: .about, title: L.holderMenuAbout())
			]
		}
	}
}

extension HolderCoordinator: EventFlowDelegate {

	func eventFlowDidComplete() {

		/// The user completed the event flow. Go back to the dashboard.

		removeChildCoordinator()
		navigateToDashboard()
		navigationController.viewControllers = []
	}

	func eventFlowDidCancel() {

		/// The user cancelled the flow. Go back one page.

		removeChildCoordinator()

		(sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true)
	}
	
	func eventFlowDidCancelFromBackSwipe() {
		
		/// The user cancelled the flow from back swipe.
		
		removeChildCoordinator()
	}
}

extension HolderCoordinator: PaperProofFlowDelegate {
	
	func addPaperProofFlowDidFinish() {
		
		removeChildCoordinator()
		navigateToDashboard()
		navigationController.viewControllers = []
	}

	func switchToAddRegularProof() {

		removeChildCoordinator()
		openMenuItem(.addCertificate)
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let noGreenCardsAvailable = ErrorCode.ClientCode(value: "061")
	static let coreDataFetchError = ErrorCode.ClientCode(value: "062")
}
