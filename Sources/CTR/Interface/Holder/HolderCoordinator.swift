/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData

protocol HolderCoordinatorDelegate: AnyObject {

	// MARK: Navigation

	/// Navigate to About Making a QR
	func navigateToAboutMakingAQR()

	/// Navigate to the token scanner
	func navigateToTokenScan()

	/// Navigate to List Results Scene
	func navigateToListResults()

	/// Navigate to About test Result Scene
	func navigateToAboutTestResult()

	/// Navigate to the start fo the holder flow
	func navigateBackToStart()

	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	func presentInformationPage(title: String, body: String)

	func userWishesToMakeQRFromNegativeTest(_ remoteTestEvent: RemoteTestEvent)

	func userWishesToCreateAQR()

	func userWishesToCreateANegativeTestQR()

	func userWishesToChooseLocation()

	func userHasNotBeenTested()

	func userWishesToCreateANegativeTestQRFromGGD()

	func userWishesToCreateAVaccinationQR()

	func userDidScanRequestToken(requestToken: RequestToken)

	func userWishesToChangeRegion(currentRegion: QRCodeValidityRegion, completion: @escaping (QRCodeValidityRegion) -> Void)

	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion)
	
	func openUrl(_ url: URL, inApp: Bool)

	func userWishesToViewQR(greenCardObjectID: NSManagedObjectID) // probably some other params also.
}

// swiftlint:enable class_delegate_protocol

class HolderCoordinator: SharedCoordinator {

	var networkManager: NetworkManaging = Services.networkManager
	var openIdManager: OpenIdManaging = Services.openIdManager
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()
	private var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate() // swiftlint:disable:this weak_delegate

	// Designated starter method
	override func start() {

		if onboardingManager.needsOnboarding {
			// Start with the onboarding
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory,
				maxValidity: maxValidity
			)
			startChildCoordinator(coordinator)

		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory,
				maxValidity: maxValidity
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent(shouldHideBackButton: true)
		} else if forcedInformationManager.needsUpdating {
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

    // MARK: - Universal Links

    /// If set, this should be handled at the first opportunity:
    private var unhandledUniversalLink: UniversalLink?

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
        }
    }

	func startEventFlow() {

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			startChildCoordinator(eventCoordinator)
		}
	}

	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken? = nil) {

		let destination = TokenEntryViewController(
			viewModel: TokenEntryViewModel(
				coordinator: self,
				proofManager: proofManager,
				requestToken: token
			)
		)

		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	// "Waar wil je een QR-code van maken?"
	func navigateToChooseQRCodeType() {
		let destination = ChooseQRCodeTypeViewController(
			viewModel: ChooseQRCodeTypeViewModel(
				coordinator: self
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	func presentChangeRegionBottomSheet(currentRegion: QRCodeValidityRegion, callback: @escaping (QRCodeValidityRegion) -> Void) {
		let viewController = ToggleRegionViewController(viewModel: ToggleRegionViewModel(currentRegion: currentRegion, didChangeCallback: callback))
		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		(sidePanel?.selectedViewController as? UINavigationController)?.present(viewController, animated: true, completion: nil)
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
		let dashboardViewController = HolderDashboardViewController(
			viewModel: HolderDashboardViewModel(
				coordinator: self,
				cryptoManager: cryptoManager,
				proofManager: proofManager,
				configuration: generalConfiguration,
				dataStoreManager: Services.dataStoreManager
			)
		)
		dashboardNavigationController = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationController

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel

        DispatchQueue.main.async {
            completion?()
        }
	}

	/// Navigate to enlarged QR
	private func navigateToShowQR(_ greenCard: GreenCard) {

		let destination = ShowQRViewController(
			viewModel: ShowQRViewModel(
				coordinator: self,
				greenCard: greenCard,
				cryptoManager: cryptoManager,
				configuration: generalConfiguration
			)
		)
		destination.modalPresentationStyle = .fullScreen
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to choose provider
	func navigateToAboutMakingAQR() {

		let destination = AboutMakingAQRViewController(
			viewModel: AboutMakingAQRViewModel(coordinator: self)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to the token scanner
	func navigateToTokenScan() {

		let destination = TokenScanViewController(
			viewModel: TokenScanViewModel(
				coordinator: self
			)
		)

		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to List Results Scene
	func navigateToListResults() {

		let destination = ListResultsViewController(
			viewModel: ListResultsViewModel(
				coordinator: self,
				proofManager: proofManager,
				maxValidity: maxValidity
			)
		)
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

	/// Navigate to About test Result Scene
	func navigateToAboutTestResult() {

		let destination = AboutTestResultViewController(
			viewModel: AboutTestResultViewModel(
				coordinator: self,
				proofManager: proofManager
			)
		)

		destination.transitioningDelegate = bottomSheetTransitioningDelegate
		destination.modalPresentationStyle = .custom
		destination.modalTransitionStyle = .coverVertical

		(sidePanel?.selectedViewController as? UINavigationController)?.viewControllers.last?.present(
			destination,
			animated: true,
			completion: nil
		)
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
	func presentInformationPage(title: String, body: String) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body
			)
		)
		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		(sidePanel?.selectedViewController as? UINavigationController)?.viewControllers.last?
			.present(viewController, animated: true, completion: nil)
	}

	func userWishesToMakeQRFromNegativeTest(_ remoteTestEvent: RemoteTestEvent) {

		if let navController = (sidePanel?.selectedViewController as? UINavigationController) {
			let eventCoordinator = EventCoordinator(
				navigationController: navController,
				delegate: self
			)
			addChildCoordinator(eventCoordinator)
			eventCoordinator.startWithListTestEvents(testEvents: [remoteTestEvent])
		}
	}

	func userWishesToCreateANegativeTestQR() {
		navigateToTokenEntry()
	}

	func userWishesToChooseLocation() {
		navigateToChooseTestLocation()
	}

	func userHasNotBeenTested() {
		logInfo("userHasNotBeenTested")
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
		startEventFlow()
	}

	func userWishesToCreateAQR() {
		navigateToChooseQRCodeType()
	}

	func userDidScanRequestToken(requestToken: RequestToken) {
		navigateToTokenEntry(requestToken)
	}

	func userWishesToChangeRegion(currentRegion: QRCodeValidityRegion, completion: @escaping (QRCodeValidityRegion) -> Void) {
		presentChangeRegionBottomSheet(currentRegion: currentRegion, callback: completion)
	}

	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) {

		let title: String = .holderDashboardNotValidInThisRegionScreenTitle(originType: originType, currentRegion: currentRegion, availableRegion: availableRegion)
		let message: String = .holderDashboardNotValidInThisRegionScreenMessage(originType: originType, currentRegion: currentRegion, availableRegion: availableRegion)
		presentInformationPage(title: title, body: message)
	}

	func userWishesToViewQR(greenCardObjectID: NSManagedObjectID) {

		do {
			if let greenCard = try Services.dataStoreManager.managedObjectContext().existingObject(with: greenCardObjectID) as? GreenCard {
				navigateToShowQR(greenCard)
			} else {
				print("oops")
			}
		} catch {
			// No card
			print("oops")
		}
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

		switch identifier {
			case .overview:
				dashboardNavigationController?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationController

			case .faq:
				guard let faqUrl = URL(string: .holderUrlFAQ) else {
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

			case .qrCodeMaken:
				let destination = AboutMakingAQRViewController(
					viewModel: AboutMakingAQRViewModel(coordinator: self)
				)
				navigationController = UINavigationController(rootViewController: destination)
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
			MenuItem(identifier: .overview, title: .holderMenuDashboard)
		]
	}
	/// Get the items for the bottom menu
	/// - Returns: the bottom menu items
	func getBottomMenuItems() -> [MenuItem] {

		return [
			MenuItem(identifier: .qrCodeMaken, title: .holderAboutMakingAQRTitle),
			MenuItem(identifier: .faq, title: .holderMenuFaq),
			MenuItem(identifier: .about, title: .holderMenuAbout)
		]
	}
}

extension HolderCoordinator: EventFlowDelegate {

	func eventFlowDidComplete() {

		/// The user canceled the vaccination flow. Go back to the dashboard.

		if let vaccinationCoordinator = childCoordinators.last {
			removeChildCoordinator(vaccinationCoordinator)
		}

		let dashboardViewController = HolderDashboardViewController(
			viewModel: HolderDashboardViewModel(
				coordinator: self,
				cryptoManager: cryptoManager,
				proofManager: proofManager,
				configuration: generalConfiguration,
				dataStoreManager: Services.dataStoreManager
			)
		)
		dashboardNavigationController = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationController
	}

	func eventFlowDidCancel() {

		/// The user cancelled the flow. Go back one page

		if let vaccinationCoordinator = childCoordinators.last {
			removeChildCoordinator(vaccinationCoordinator)
		}

		(sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: true)
	}
}
