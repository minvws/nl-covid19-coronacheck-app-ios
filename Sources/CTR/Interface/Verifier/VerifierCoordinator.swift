/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Clcore

protocol VerifierCoordinatorDelegate: AnyObject {
	
	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome()

	/// The user finished the start scene
	/// - Parameter result: the result of the start scene
	func didFinish(_ result: VerifierStartResult)

	/// The user finished the instruction scene
	/// - Parameter result: the result of the instruction scene
	func didFinish(_ result: ScanInstructionsResult)

	func navigateToScan()

	/// Navigate to the scan result
	/// - Parameter attributes: the scanned result
	func navigateToScanResult(_ scanResult: MobilecoreVerificationResult)

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: [Content])
}

class VerifierCoordinator: SharedCoordinator {

	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = VerifierOnboardingFactory()

	private var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate() // swiftlint:disable:this weak_delegate

	// Designated starter method
	override func start() {
		
		if onboardingManager.needsOnboarding {
			/// Start with the onboarding
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
            viewModel: MenuViewModel(delegate: self)
		)
		sidePanel = SidePanelController(sideController: UINavigationController(rootViewController: menu))
		
		let dashboardViewController = VerifierStartViewController(
			viewModel: VerifierStartViewModel(
				coordinator: self,
				cryptoManager: cryptoManager,
				proofManager: proofManager
			)
		)
		dashboardNavigationController = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationController
		
		// Replace the root with the side panel controller
		window.rootViewController = sidePanel
	}

	func didFinish(_ result: VerifierStartResult) {

		switch result {
			case .userTappedProceedToScan:
				navigateToScan()

			case .userTappedProceedToScanInstructions:
				navigateToScanInstruction()
		}
	}

	/// The user finished the instruction scene
	/// - Parameter result: the result of the instruction scene
	func didFinish(_ result: ScanInstructionsResult) {

		navigateToScan()
	}
	
	/// Navigate to the scan result
	/// - Parameter attributes: the scanned result
	func navigateToScanResult(_ cryptoResults: MobilecoreVerificationResult) {
		
		let viewController = VerifierResultViewController(
			viewModel: VerifierResultViewModel(
				coordinator: self,
				cryptoResults: cryptoResults,
				maxValidity: maxValidity
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: false)
	}

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: [Content]) {

		let viewController = DisplayContentViewController(
			viewModel: DisplayContentViewModel(
				coordinator: self,
				title: title,
				content: content
			)
		)

		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		sidePanel?.selectedViewController?.present(viewController, animated: true, completion: nil)
	}

	private func navigateToScanInstruction() {

		let destination = ScanInstructionsViewController(
			viewModel: ScanInstructionsViewModel(
				coordinator: self
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(destination, animated: true)
	}

	/// Navigate to the QR scanner
	func navigateToScan() {

//		navigateToScanResult(
//			(attributes: CryptoAttributes(
//				birthDay: "27",
//				birthMonth: "5",
//				credentialVersion: "1",
//				domesticDcc: "0",
//				firstNameInitial: "G",
//				lastNameInitial: "C",
//				specimen: "0"),
//			 errorMessage: nil
//			)
//		)

		let destination = VerifierScanViewController(
			viewModel: VerifierScanViewModel(
				coordinator: self,
				cryptoManager: cryptoManager
			)
		)

		(sidePanel?.selectedViewController as? UINavigationController)?.setViewControllers([destination], animated: true)
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
				dashboardNavigationController?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationController

			case .support:
				guard let faqUrl = URL(string: L.verifierUrlFaq()) else {
					logError("No verifier faq url")
					return
				}
				openUrl(faqUrl, inApp: true)
				
			case .about :
				let destination = AboutViewController(
					viewModel: AboutViewModel(
						coordinator: self,
						versionSupplier: versionSupplier,
						flavor: AppFlavor.flavor
					)
				)
				aboutNavigationController = UINavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = aboutNavigationController
				
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
			MenuItem(identifier: .overview, title: L.verifierMenuDashboard())
		]
	}
	/// Get the items for the bottom menu
	/// - Returns: the bottom menu items
	func getBottomMenuItems() -> [MenuItem] {
		
		return [
			MenuItem(identifier: .support, title: L.verifierMenuSupport()),
			MenuItem(identifier: .about, title: L.verifierMenuAbout())
		]
	}
}
