/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

protocol Dismissable: AnyObject {

	/// Dismiss the presented viewcontroller
	func dismiss()
}

protocol OpenUrlProtocol: AnyObject {

	/// Open a url
	func openUrl(_ url: URL, inApp: Bool)
}

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

	/// Navigate to Birthday entry Scene
	func navigateToBirthdate()

	/// Navigate to List Results Scene
	func navigateToListResults()

	/// Navigate to create proof
	func navigateToCreateProof()

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

class HolderCoordinator: Coordinator, Logging {

	var loggingCategory: String = "HolderCoordinator"

	/// The UI Window
	private var window: UIWindow

	/// The side panel controller
	var sidePanel: SidePanelController?

	/// The onboardings manager
	var onboardingManager: OnboardingManaging = Services.onboardingManager

	/// The proof manager
	var proofManager: ProofManaging = Services.proofManager

	/// The crypto manager
	var cryptoManager: CryptoManaging = Services.cryptoManager

	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager

	/// The open ID manager
	var openIdManager: OpenIdManaging = Services.openIdManager

	/// The general configuration
	var generalConfiguration: ConfigurationGeneralProtocol = Configuration()

	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The dashboard navigation controller
	var dashboardNavigationContoller: UINavigationController?

	/// The about navigation controller
	var aboutNavigationContoller: UINavigationController?

	/// Initiatilzer
	init(navigationController: UINavigationController, window: UIWindow) {

		self.navigationController = navigationController
		self.window = window
	}

	// Designated starter method
	func start() {

		if onboardingManager.needsOnboarding {
			/// Start with the onboarding
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory
			)
			startChildCoordinator(coordinator)

		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent()
		} else {

			// Start with the holder app
			navigateToHolderStart()
		}
	}
}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {

	// MARK: Navigation

	func navigateToHolderStart() {

		let menu = MenuViewController(
			viewModel: MenuViewModel(
				delegate: self
			)
		)
		sidePanel = CustomSidePanelController(sideController: UINavigationController(rootViewController: menu))
		let dashboardViewController = HolderDashboardViewController(
			viewModel: HolderDashboardViewModel(
				coordinator: self,
				cryptoManager: cryptoManager,
				proofManager: proofManager,
				configuration: generalConfiguration
			)
		)
		dashboardNavigationContoller = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationContoller

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel
	}

	/// Navigate to enlarged QR
	func navigateToEnlargedQR() {

		let destination = EnlargedQRViewController(
			viewModel: EnlargedQRViewModel(
				coordinator: self,
				cryptoManager: cryptoManager,
				proofManager: proofManager,
				configuration: generalConfiguration
			)
		)
		let navController = UINavigationController(rootViewController: destination)
		navController.view.backgroundColor = .white

		(sidePanel?.selectedViewController as? UINavigationController)?.viewControllers.last?.present(
			navController,
			animated: true,
			completion: nil
		)
	}

	/// Navigate to appointment
	func navigateToAppointment() {

		let destination = AppointmentViewController(
			viewModel: AppointmentViewModel(
				coordinator: self
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

		if proofManager.getBirthDate() == nil {
			// Fill in the birhtday if there is none on the commercial token flow.
			navigateToBirthdate()
		} else {

			let destination = TokenOverviewViewController(
				viewModel: TokenOverviewViewModel(
					coordinator: self
				)
			)
			(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
		}
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
				scannedToken: token
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to Birthdate Scene
	func navigateToBirthdate() {

		let coordinator = BirthdateCoordinator(
			navigationController: navigationController,
			presentingViewController: sidePanel?.selectedViewController,
			birthdateSceneDelegate: self
		)

		startChildCoordinator(coordinator)
	}

	/// Navigate to List Results Scene
	func navigateToListResults() {

		let viewController = ListResultsViewController(
			viewModel: ListResultsViewModel(
				coordinator: self,
				proofManager: proofManager,
				configuration: generalConfiguration
			)
		)
		let destination = UINavigationController(rootViewController: viewController)
		navigationController = destination
		if #available(iOS 13.0, *) {
			destination.isModalInPresentation = true
		}
		sidePanel?.selectedViewController?.present(destination, animated: true, completion: nil)
	}

	/// Navigate to create proof
	func navigateToCreateProof() {
		
		let viewController = CreateProofViewController(
			viewModel: CreateProofViewModel(
				coordinator: self,
				cryptoManager: cryptoManager
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	/// Navigate to the start fo the holder flow
	func navigateBackToStart() {
		childCoordinators.forEach {
			removeChildCoordinator($0)
		}

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

// MARK: - OpenUrlProtocol

extension HolderCoordinator: OpenUrlProtocol {

	/// Open a url
	func openUrl(_ url: URL, inApp: Bool) {

		if inApp {
			let safariController = SFSafariViewController(url: url)
			safariController.preferredControlTintColor = Theme.colors.primary
			sidePanel?.selectedViewController?.present(safariController, animated: true)
		} else {
			UIApplication.shared.open(url)
		}
	}
}

// MARK: - Dismissable

extension HolderCoordinator: Dismissable {

	func dismiss() {

//		if let nav = sidePanel?.presentedViewController as? UINavigationController {
////			nav.popViewController(animated: true)
//			nav.viewControllers.first?.dismiss(animated: true, completion: nil)
//		}

//		dashboardNavigationContoller?.dismiss(animated: true, completion: nil)
		sidePanel?.selectedViewController?.dismiss(animated: true, completion: nil)
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
				let faqUrl = generalConfiguration.getHolderFAQURL()
				openUrl(faqUrl, inApp: true)

			case .about :
				let aboutUrl = generalConfiguration.getHolderAboutAppURL()
				openUrl(aboutUrl, inApp: true)
//				let destination = AboutViewController(
//					viewModel: AboutViewModel(
//						coordinator: self,
//						configuration: generalConfiguration
//					)
//				)
//				aboutNavigationContoller = UINavigationController(rootViewController: destination)
//				sidePanel?.selectedViewController = aboutNavigationContoller

			case .privacy :
				let privacyUrl = generalConfiguration.getPrivacyPolicyURL()
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

// MARK: - OnboardingDelegate

extension HolderCoordinator: OnboardingDelegate {

	/// User has seen all the onboarding pages
	func finishOnboarding() {

		onboardingManager.finishOnboarding()
	}

	/// The onboarding is finished
	func consentGiven() {

		// Mark as complete
		onboardingManager.consentGiven()

		// Remove child coordinator
		if let onboardingCoorinator = childCoordinators.first {
			removeChildCoordinator(onboardingCoorinator)
		}

		// Navigate to Holder Start.
		navigateToHolderStart()
	}
}

// MARK: - BirthdateSceneDelegate

extension HolderCoordinator: BirthdateSceneDelegate {

	/// User confirmed the birthdate
	func birthdateConfirmed() {

		if let birthdateCoordinator = childCoordinators.first {
			removeChildCoordinator(birthdateCoordinator)
		}
		navigateToTokenOverview()
	}
}
