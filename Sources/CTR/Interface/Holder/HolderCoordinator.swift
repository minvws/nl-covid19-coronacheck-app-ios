/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol HolderCoordinatorDelegate: AnyObject {

	// MARK: Navigation

	/// Navigate to enlarged QR
	func navigateToEnlargedQR()

	/// Navigate to appointment
	func navigateToAppointment()

	/// Navigate to choose provider
	func navigateToChooseProvider()

	/// Navigate to the token overview scene
	func navigateToTokenOverview()

	/// Navigate to the token scanner
	func navigateToTokenScan()

	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken?)

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
	///   - showBottomCloseButton: True if the bottom close button should be shown
	func presentInformationPage(title: String, body: String, showBottomCloseButton: Bool)
}
// swiftlint:enable class_delegate_protocol

class HolderCoordinator: SharedCoordinator {

	var networkManager: NetworkManaging = Services.networkManager
	var openIdManager: OpenIdManaging = Services.openIdManager
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()

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
				maxValidity: maxValidity
			)
		)
		dashboardNavigationContoller = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationContoller

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel

        DispatchQueue.main.async {
            completion?()
        }
	}

	/// Navigate to enlarged QR
	func navigateToEnlargedQR() {

		let destination = EnlargedQRViewController(
			viewModel: EnlargedQRViewModel(
				coordinator: self,
				cryptoManager: cryptoManager,
				proofManager: proofManager,
				configuration: generalConfiguration,
				maxValidity: maxValidity
			)
		)
		destination.modalPresentationStyle = .fullScreen
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to appointment
	func navigateToAppointment() {

		let destination = AppointmentViewController(
			viewModel: AppointmentViewModel(
				coordinator: self,
				maxValidity: maxValidity
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to choose provider
	func navigateToChooseProvider() {

		let destination = ChooseProviderViewController(
			viewModel: ChooseProviderViewModel(
				coordinator: self,
				openIdManager: openIdManager
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to the token overview scene
	func navigateToTokenOverview() {

		let destination = TokenOverviewViewController(
			viewModel: TokenOverviewViewModel(
				coordinator: self
			)
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

	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken? = nil) {

		let destination = TokenEntryViewController(
			viewModel: TokenEntryViewModel(
				coordinator: self,
				proofManager: proofManager,
				requestToken: token
			),
			alertPresenter: { [weak self] alertController in
				self?.sidePanel?.selectedViewController?.present(alertController, animated: true, completion: nil)
			}
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

	/// Navigate to About test Result Scene
	func navigateToAboutTestResult() {

		let destination = AboutTestResultViewController(
			viewModel: AboutTestResultViewModel(
				coordinator: self,
				proofManager: proofManager
			)
		)

		let navController = UINavigationController(rootViewController: destination)

		(sidePanel?.selectedViewController as? UINavigationController)?.viewControllers.last?.present(
			navController,
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
	///   - showBottomCloseButton: True if the bottom close button should be shown
	func presentInformationPage(title: String, body: String, showBottomCloseButton: Bool) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				showBottomCloseButton: showBottomCloseButton
			)
		)
		let destination = UINavigationController(rootViewController: viewController)
		sidePanel?.selectedViewController?.present(destination, animated: true, completion: nil)
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
				dashboardNavigationContoller?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationContoller

			case .faq:
				guard let faqUrl = URL(string: .holderUrlFAQ) else {
					logError("No holder FAQ url")
					return
				}
				openUrl(faqUrl, inApp: true)

			case .about :
				let destination = AboutViewController(
					viewModel: AboutViewModel(
						versionSupplier: versionSupplier,
						flavor: AppFlavor.flavor
					)
				)
				aboutNavigationController = UINavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = aboutNavigationController

			case .privacy :
				guard let privacyUrl = URL(string: .holderUrlPrivacy) else {
					logError("No holder privacy url")
					return
				}
				openUrl(privacyUrl, inApp: true)

			default:
				self.logInfo("User tapped on \(identifier), not implemented")

				let destinationViewController = PlaceholderViewController()
				destinationViewController.placeholder = "\(identifier)"
				let navigationController = UINavigationController(rootViewController: destinationViewController)
				sidePanel?.selectedViewController = navigationController
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
			MenuItem(identifier: .faq, title: .holderMenuFaq),
			MenuItem(identifier: .about, title: .holderMenuAbout),
			MenuItem(identifier: .privacy, title: .holderMenuPrivacy)
		]
	}
}
