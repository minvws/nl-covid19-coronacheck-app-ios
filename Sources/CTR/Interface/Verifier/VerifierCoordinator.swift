/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices
import SheetPresentation

protocol VerifierCoordinatorDelegate: AnyObject {
	
	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome()
	
	/// Show the scan instructions
	/// - Parameter present: present
	func navigateToScanInstruction(present: Bool)
	
	/// Navigate to the QR scanner
	func navigateToScan()
	
	/// Navigate to the scan result
	/// - Parameter attributes: the scanned attributes
	func navigateToScanResult(_ attributes: Attributes)

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: Content)
}

class VerifierCoordinator: Coordinator, Logging {
	
	var loggingCategory: String = "VerifierCoordinator"
	
	/// The UI Window
	private var window: UIWindow
	
	/// The side panel controller
	var sidePanel: SidePanelController?
	
	/// The onboardings manager
	var onboardingManager: OnboardingManaging = Services.onboardingManager
	
	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = VerifierOnboardingFactory()
	
	/// The crypto manager
	var cryptoManager: CryptoManaging = Services.cryptoManager

	/// The general configuration
	var generalConfiguration: ConfigurationGeneralProtocol = Configuration()

	/// The remote config manager
	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	
	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []
	
	/// The navigation controller
	var navigationController: UINavigationController
	
	/// The dashboard navigation controller
	var dashboardNavigationContoller: UINavigationController?

	var sheetPresentationManager = SheetPresentationManager()

	var maxValidity: Int {
		remoteConfigManager.getConfiguration().maxValidityHours ?? 48
	}
	
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
				factory: onboardingFactory,
				maxValidity: String(maxValidity)
			)
			startChildCoordinator(coordinator)
			
		} else if onboardingManager.needsConsent {
			// Show the consent page
			let coordinator = OnboardingCoordinator(
				navigationController: navigationController,
				onboardingDelegate: self,
				factory: onboardingFactory,
				maxValidity: String(maxValidity)
			)
			addChildCoordinator(coordinator)
			coordinator.navigateToConsent()
		} else {
			
			navigateToVerifierWelcome()
		}
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {
	
	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome() {
		
		let menu = MenuViewController(
			viewModel: MenuViewModel(
				delegate: self
			)
		)
		sidePanel = CustomSidePanelController(sideController: UINavigationController(rootViewController: menu))
		
		let dashboardViewController = VerifierStartViewController(
			viewModel: VerifierStartViewModel(
				coordinator: self,
				cryptoManager: cryptoManager
			)
		)
		dashboardNavigationContoller = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationContoller
		
		// Replace the root with the side panel controller
		window.rootViewController = sidePanel
	}
	
	/// Show the scan instructions
	/// - Parameter present: present
	func navigateToScanInstruction(present: Bool = false) {
		
		let destination = ScanInstructionsViewController(
			viewModel: ScanInstructionsViewModel(
				coordinator: self,
				presented: present,
				maxValidity: String(maxValidity)
			)
		)
		if present {
			let navigationController = UINavigationController(rootViewController: destination)
			sidePanel?.selectedViewController?.present(navigationController, animated: true, completion: nil)
		} else {
			(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
		}
	}
	
	/// Navigate to the QR scanner
	func navigateToScan() {

		navigateToScanResult(
			Attributes(
				cryptoAttributes:
					CrypoAttributes(
						birthDay: "27",
						birthMonth: "5",
						firstNameInitial: nil, //"R",
						lastNameInitial: "P",
						sampleTime: "1615467990",
						testType: "PCR"
					),
				unixTimeStamp: Int64(Date().timeIntervalSince1970)
			)
		)

//		let destination = VerifierScanViewController(
//			viewModel: VerifierScanViewModel(
//				coordinator: self,
//				cryptoManager: cryptoManager
//			)
//		)
//
//		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}
	
	/// Navigate to the scan result
	/// - Parameter attributes: the scanned attributes
	func navigateToScanResult(_ attributes: Attributes) {
		
		let viewController = VerifierResultViewController(
			viewModel: VerifierResultViewModel(
				coordinator: self,
				attributes: attributes,
				maxValidity: maxValidity
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: false)
	}

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: Content) {

		let viewController = DisplayContentViewController(
			viewModel: DisplayContentViewModel(
				coordinator: self,
				title: title,
				content: content
			)
		)
		let destination = UINavigationController(rootViewController: viewController)
		sidePanel?.selectedViewController?.present(destination, animated: true, completion: nil)

		//		let presentationManager = SheetPresentationManager(
		//			options: SheetPresentationOptions(
		//				cornerOptions: SheetPresentationOptions.CornerOptions.roundAllCorners(radius: 10),
		//				dimmingViewAlpha: 0.5,
		//				edgeInsets: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0),
		//				ignoredEdgesForMargins: [DirectionalViewEdge.bottom, DirectionalViewEdge.leading, DirectionalViewEdge.trailing],
		//				presentationLayout: PresentationLayout(horizontalLayout: .fill, verticalLayout: .automatic(alignment: .bottom)),
		//				animationBehavior: .system
		//			)
		//		)
		//
		//		destination.transitioningDelegate = presentationManager
		//		destination.modalPresentationStyle = .custom
		//		sheetPresentationManager = presentationManager
	}
}

// MARK: - Dismissable

extension VerifierCoordinator: Dismissable {
	
	func dismiss() {
		
		if sidePanel?.selectedViewController?.presentedViewController != nil {
			sidePanel?.selectedViewController?.dismiss(animated: true, completion: nil)
		} else {
			(sidePanel?.selectedViewController as? UINavigationController)?.popViewController(animated: false)
		}
	}
}

// MARK: - MenuDelegate

extension VerifierCoordinator: MenuDelegate {
	
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
				
			case .support:
				let faqUrl = generalConfiguration.getVerifierFAQURL()
				openUrl(faqUrl, inApp: true)
				
			case .about :
				let aboutUrl = generalConfiguration.getVerifierAboutAppURL()
				openUrl(aboutUrl, inApp: true)
				
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
			MenuItem(identifier: .overview, title: .verifierMenuDashboard)
		]
	}
	/// Get the items for the bottom menu
	/// - Returns: the bottom menu items
	func getBottomMenuItems() -> [MenuItem] {
		
		return [
			MenuItem(identifier: .support, title: .verifierMenuSupport),
			MenuItem(identifier: .about, title: .verifierMenuAbout),
			MenuItem(identifier: .privacy, title: .verifierMenuPrivacy)
		]
	}
}

// MARK: - OpenUrlProtocol

extension VerifierCoordinator: OpenUrlProtocol {
	
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

// MARK: - OnboardingDelegate

extension VerifierCoordinator: OnboardingDelegate {
	
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
		
		// Navigate to Verifier Welcome.
		navigateToVerifierWelcome()
	}
}
