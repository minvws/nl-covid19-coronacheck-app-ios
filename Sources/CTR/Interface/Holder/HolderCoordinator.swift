/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

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

	func userWishesToMakeQRFromNegativeTest(_ remoteEvent: RemoteEvent)

	func userWishesToCreateAQR()

	func userWishesToCreateANegativeTestQR()

	func userWishesToChooseLocation()

	func userHasNotBeenTested()

	func userWishesToCreateANegativeTestQRFromGGD()

	func userWishesToCreateAVaccinationQR()

	func userWishesToCreateARecoveryQR()

	func userDidScanRequestToken(requestToken: RequestToken)

	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion)

	func userWishesMoreInfoAboutClockDeviation()

	func userWishesMoreInfoAboutUpgradingEUVaccinations()

	func openUrl(_ url: URL, inApp: Bool)

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID])

	func userWishesToLaunchThirdPartyTicketApp()

	func displayError(content: Content, backAction: @escaping () -> Void)
}

// swiftlint:enable class_delegate_protocol

class HolderCoordinator: SharedCoordinator {

	var userSettings: UserSettingsProtocol = UserSettings()
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()

	///	A (whitelisted) third-party can open the app & - if they provide a return URL, we will
	///	display a "return to Ticket App" button on the ShowQR screen
	/// Docs: https://shrtm.nu/oc45
	private var thirdpartyTicketApp: (name: String, returnURL: URL)?

	/// If set, this should be handled at the first opportunity:
	private var unhandledUniversalLink: UniversalLink?

	/// Restricts access to GGD test provider login
	private var isGGDEnabled: Bool {
		return remoteConfigManager.getConfiguration().isGGDEnabled == true
	}
	
	// Designated starter method
	override func start() {

		handleOnboarding(factory: onboardingFactory) {

			if forcedInformationManager.needsUpdating {
				// Show Forced Information
				let coordinator = ForcedInformationCoordinator(
					navigationController: navigationController,
					forcedInformationManager: forcedInformationManager,
					delegate: self
				)
				startChildCoordinator(coordinator)
			} else if let unhandledUniversalLink = unhandledUniversalLink {

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

			case .thirdPartyTicketApp(let returnURL):
				guard let returnURL = returnURL,
					  let matchingMetadata = remoteConfigManager.getConfiguration().universalLinkPermittedDomains?.first(where: { permittedDomain in
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
				   let appDelegate = UIApplication.shared.delegate as? AppDelegate,
				   let authorizationFlow = appDelegate.currentAuthorizationFlow,
				   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
					appDelegate.currentAuthorizationFlow = nil
				}
				return true
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

	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken? = nil) {

		let destination = TokenEntryViewController(
			viewModel: TokenEntryViewModel(
				coordinator: self,
				requestToken: token,
				tokenValidator: TokenValidator(isLuhnCheckEnabled: remoteConfigManager.getConfiguration().isLuhnCheckEnabled ?? false)
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
					minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: remoteConfigManager.getConfiguration().credentialRenewalDays ?? 5,
					reachability: try? Reachability(),
					now: { Date() }
				),
				userSettings: UserSettings(),
				now: { Date() }
			)
		)
		dashboardNavigationController = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationController
	}
	
	private func removeChildCoordinator() {
		
		guard let coordinator = childCoordinators.last else { return }
		removeChildCoordinator(coordinator)
	}
	
	private func presentAsBottomSheet(_ viewController: UIViewController) {
		
		(sidePanel?.selectedViewController as? UINavigationController)?.visibleViewController?.presentBottomSheet(viewController)
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
		sidePanel = SidePanelController(sideController: UINavigationController(rootViewController: menu))
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

	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool = true) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: openURLsInApp)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		presentAsBottomSheet(viewController)
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

	func userWishesToMakeQRFromNegativeTest(_ remoteEvent: RemoteEvent) {

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

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithTVS(eventMode: EventMode.test)
		}
	}

	func userWishesToCreateAVaccinationQR() {
		startEventFlowForVaccination()
	}

	func userWishesToCreateARecoveryQR() {
		startEventFlowForRecovery()
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
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: false)
	}

	func userWishesMoreInfoAboutUpgradingEUVaccinations() {
		let viewController = UpgradeEUVaccinationViewController(viewModel: UpgradeEUVaccinationViewModel())
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID]) {

		let result = GreenCardModel.fetchByIds(objectIDs: greenCardObjectIDs)
		switch result {
			case let .success(greenCards):
				if greenCards.isEmpty {
					showAlertWithErrorCode("i 610 000 061")
			} else {
				navigateToShowQRs(greenCards)
			}
			case .failure:
			showAlertWithErrorCode("i 610 000 062")
		}
	}

	private func showAlertWithErrorCode(_ code: String) {
		
		let alertController = UIAlertController(
			title: L.generalErrorTitle(),
			message: String(format: L.generalErrorTechnicalCustom(code)),
			preferredStyle: .alert)

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
				let destination = AboutViewController(
					viewModel: AboutViewModel(
						coordinator: self,
						versionSupplier: versionSupplier,
						flavor: AppFlavor.flavor
					)
				)
				aboutNavigationController = UINavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = aboutNavigationController

			case .addCertificate:
				let destination = ChooseQRCodeTypeViewController(
					viewModel: ChooseQRCodeTypeViewModel(
						coordinator: self
					),
					isRootViewController: true
				)
				navigationController = UINavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = navigationController
				
			case .addPaperCertificate:
				let coordinator = PaperCertificateCoordinator(delegate: self)
				let destination = PaperCertificateStartViewController(viewModel: .init(coordinator: coordinator))
				navigationController = UINavigationController(rootViewController: destination)
				coordinator.navigationController = navigationController
				startChildCoordinator(coordinator)
				sidePanel?.selectedViewController = navigationController

			default:
				self.logInfo("User tapped on \(identifier), not implemented")

				let destinationViewController = PlaceholderViewController()
				destinationViewController.placeholder = "\(identifier)"
				let navigationController = UINavigationController(rootViewController: destinationViewController)
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
			MenuItem(identifier: .addCertificate, title: L.holderMenuProof())
		]
	}
	/// Get the items for the bottom menu
	/// - Returns: the bottom menu items
	func getBottomMenuItems() -> [MenuItem] {

		return [
			MenuItem(identifier: .addPaperCertificate, title: L.holderMenuPapercertificate()),
			MenuItem(identifier: .faq, title: L.holderMenuFaq()),
			MenuItem(identifier: .about, title: L.holderMenuAbout())
		]
	}
}

extension HolderCoordinator: EventFlowDelegate {

	func eventFlowDidComplete() {

		/// The user completed the event flow. Go back to the dashboard.

		removeChildCoordinator()

		navigateToDashboard()
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

extension HolderCoordinator: PaperCertificateFlowDelegate {
	
	func addCertificateFlowDidFinish() {
		
		removeChildCoordinator()
		
		navigateToDashboard()
	}
}
