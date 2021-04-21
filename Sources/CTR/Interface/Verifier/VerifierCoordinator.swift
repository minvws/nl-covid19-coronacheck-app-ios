/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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
	/// - Parameter attributes: the scanned attributes
	func navigateToScanResult(_ scanResult: CryptoResult)

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: [Content])
}

class VerifierCoordinator: SharedCoordinator {

	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = VerifierOnboardingFactory()

	// Designated starter method
	override func start() {
		
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
		} else if forcedInformationManager.needsUpdating {
			// Show Forced Information
			let coordinator = ForcedInformationCoordinator(
				navigationController: navigationController,
				forcedInformationManager: forcedInformationManager,
				delegate: self
			)
			startChildCoordinator(coordinator)

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
		dashboardNavigationContoller = UINavigationController(rootViewController: dashboardViewController)
		sidePanel?.selectedViewController = dashboardNavigationContoller
		
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
	/// - Parameter attributes: the scanned attributes
	func navigateToScanResult(_ cryptoResults: CryptoResult) {
		
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
		let destination = UINavigationController(rootViewController: viewController)
		sidePanel?.selectedViewController?.present(destination, animated: true, completion: nil)
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
		//			CryptoResult(
		//				attributes:
		//					Attributes(
		//						cryptoAttributes:
		//							CrypoAttributes(
		//								birthDay: "27",
		//								birthMonth: "5",
		//								firstNameInitial: nil, // "R",
		//								lastNameInitial: "P",
		//								sampleTime: "1617689091",
		//								testType: "PCR",
		//								specimen: "1",
		//								paperProof: "0"
		//							),
		//						unixTimeStamp: Int64(Date().timeIntervalSince1970)
		//					),
		//				errorMessage: nil
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
				dashboardNavigationContoller?.popToRootViewController(animated: false)
				sidePanel?.selectedViewController = dashboardNavigationContoller
				
			case .support:
				let faqUrl = generalConfiguration.getVerifierFAQURL()
				openUrl(faqUrl, inApp: true)
				
			case .about :
				let destination = AboutViewController(
					viewModel: AboutViewModel(
						versionSupplier: versionSupplier,
						flavor: AppFlavor.flavor
					)
				)
				aboutNavigationContoller = UINavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = aboutNavigationContoller
				
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
