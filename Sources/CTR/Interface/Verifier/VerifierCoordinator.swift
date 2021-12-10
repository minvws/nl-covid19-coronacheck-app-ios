/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Clcore

protocol VerifierCoordinatorDelegate: AnyObject {

	/// The user finished the start scene
	/// - Parameter result: the result of the start scene
	func didFinish(_ result: VerifierStartResult)

	func navigateToVerifierWelcome()

	func navigateToScan()

	func navigateToScanInstruction()

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: [DisplayContent])

	func userWishesMoreInfoAboutClockDeviation()
	
	func navigateToVerifiedInfo()

	func userWishesToOpenScanLog()
	
	func userWishesToLaunchThirdPartyScannerApp()
	
	func navigateToCheckIdentity(_ verificationDetails: MobilecoreVerificationDetails)
	
	func navigateToVerifiedAccess(_ verifiedType: VerifiedType)
	
	func navigateToDeniedAccess()
	
	func userWishesToSetRiskLevel(shouldSelectSetting: Bool)
}

class VerifierCoordinator: SharedCoordinator {

	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = VerifierOnboardingFactory()
	
	private var thirdPartyScannerApp: (name: String, returnURL: URL)?

	private var userSettings: UserSettingsProtocol = UserSettings()

	// Designated starter method
	override func start() {
		
		handleOnboarding(
			onboardingFactory: onboardingFactory,
			forcedInformationFactory: VerifierForcedInformationFactory()
		) {
			
			setupMenu()
			Services.scanLogManager.deleteExpiredScanLogEntries(
				seconds: Services.remoteConfigManager.storedConfiguration.scanLogStorageSeconds ?? 3600
			)
			navigateToVerifierWelcome()
		}
	}

	fileprivate func setupMenu() {
		let menu = MenuViewController(
			viewModel: MenuViewModel(delegate: self)
		)
		sidePanel = SidePanelController(sideController: NavigationController(rootViewController: menu))

		dashboardNavigationController = NavigationController()

		// Replace the root with the side panel controller
		window.rootViewController = sidePanel
	}
	
	override func consume(universalLink: UniversalLink) -> Bool {
		switch universalLink {
			case .thirdPartyScannerApp(let returnURL):
				guard let returnURL = returnURL,
					  let matchingMetadata = remoteConfigManager.storedConfiguration.universalLinkPermittedDomains?.first(where: { permittedDomain in
						  permittedDomain.url == returnURL.host
					  })
				else {
					return true
				}
			
				// Is the user currently permitted to scan?
				guard Services.scanLockManager.state == .unlocked && Services.riskLevelManager.state != nil
				else { return true } // handled (but ignored)
				
				thirdPartyScannerApp = (name: matchingMetadata.name, returnURL: returnURL)
				
				// On next runloop to show navigation animation and to open camera right after app launch
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					self.navigateToScan()
				}
				
				return true
			default:
				return false
		}
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {

	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome() {

		if sidePanel?.selectedViewController == dashboardNavigationController,
			let existingStartViewController = dashboardNavigationController?.viewControllers.first(where: { $0 is VerifierStartViewController }) {
			dashboardNavigationController?.popToViewController(existingStartViewController, animated: true)
		} else {

			let dashboardViewController = VerifierStartViewController(
				viewModel: VerifierStartViewModel(
					coordinator: self,
					scanLockProvider: Services.scanLockManager,
					riskLevelProvider: Services.riskLevelManager
				)
			)

			dashboardNavigationController?.setViewControllers([dashboardViewController], animated: false)
			sidePanel?.selectedViewController = dashboardNavigationController
		}
	}

	func didFinish(_ result: VerifierStartResult) {

		switch result {
			case .userTappedProceedToScan:
				navigateToScan()

			case .userTappedProceedToScanInstructions:
				navigateToScanInstruction()
		}
	}
	
	func navigateToCheckIdentity(_ verificationDetails: MobilecoreVerificationDetails) {
		
		let viewController = CheckIdentityViewController(
			viewModel: CheckIdentityViewModel(
				coordinator: self,
				verificationDetails: verificationDetails,
				isDeepLinkEnabled: thirdPartyScannerApp != nil
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: false)
	}
	
	func navigateToVerifiedAccess(_ verifiedType: VerifiedType) {
		
		let viewController = VerifiedAccessViewController(
			viewModel: VerifiedAccessViewModel(
				coordinator: self,
				verifiedType: verifiedType
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushWithFadeAnimation(with: viewController,
																							  animationDuration: VerifiedAccessViewTraits.Animation.verifiedDuration)
	}
	
	func navigateToDeniedAccess() {
		
		let viewController = DeniedAccessViewController(
			viewModel: DeniedAccessViewModel(
				coordinator: self
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: false)
	}

	/// Display content
	/// - Parameters:
	///   - title: the title
	///   - content: the content
	func displayContent(title: String, content: [DisplayContent]) {

		let viewController = DisplayContentViewController(
			viewModel: DisplayContentViewModel(
				coordinator: self,
				title: title,
				content: content
			)
		)
		sidePanel?.selectedViewController?.presentBottomSheet(viewController)
	}

	func navigateToScanInstruction() {

		let coordinator = ScanInstructionsCoordinator(
			navigationController: dashboardNavigationController!,
			delegate: self,
			isOpenedFromMenu: false
		)
		startChildCoordinator(coordinator)
	}

	/// Navigate to the QR scanner
	func navigateToScan() {

		if let existingScanViewController = dashboardNavigationController?.viewControllers.first(where: { $0 is VerifierScanViewController }) {
			dashboardNavigationController?.popToViewController(existingScanViewController, animated: true)
		} else {
			let destination = VerifierScanViewController(
				viewModel: VerifierScanViewModel(
					coordinator: self
				)
			)
			dashboardNavigationController?.pushOrReplaceTopViewController(with: destination, animated: true)
		}
	}

	func userWishesMoreInfoAboutClockDeviation() {
		let title: String = L.verifierClockDeviationDetectedTitle()
		let message: String = L.verifierClockDeviationDetectedMessage(UIApplication.openSettingsURLString)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: false)
	}

	func userWishesToOpenScanLog() {

		let viewController = ScanLogViewController(
			viewModel: ScanLogViewModel(
				coordinator: self,
				configuration: remoteConfigManager.storedConfiguration,
				now: { Date() }
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}
	
	func navigateToVerifiedInfo() {
		
		let viewController = VerifiedInfoViewController(
			viewModel: VerifiedInfoViewModel(
				coordinator: self,
				isDeepLinkEnabled: thirdPartyScannerApp != nil
			)
		)
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}
	
	func userWishesToLaunchThirdPartyScannerApp() {
		if let thirdPartyScannerApp = thirdPartyScannerApp {
			openUrl(thirdPartyScannerApp.returnURL, inApp: false)
		} else {
			navigateToScan()
		}
	}
	
	func userWishesToSetRiskLevel(shouldSelectSetting: Bool) {
		
		let viewController: UIViewController
		if shouldSelectSetting {
			viewController = RiskSettingUnselectedViewController(
				viewModel: RiskSettingUnselectedViewModel(
					coordinator: self
				)
			)
		} else {
			viewController = RiskSettingSelectedViewController(
				viewModel: RiskSettingSelectedViewModel(
					coordinator: self,
					configuration: remoteConfigManager.storedConfiguration
				)
			)
		}
		(sidePanel?.selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
	}
}

// MARK: ScanInstructions Delegate

extension VerifierCoordinator: ScanInstructionsDelegate {

	/// User completed (or skipped) the Scan Instructions flow
	func scanInstructionsDidFinish(hasScanLock: Bool) {
		userSettings.scanInstructionShown = true

		removeScanInstructionsCoordinator()
		
		if hasScanLock {
			navigateToVerifierWelcome()
		} else {
			navigateToScan()
		}
	}

	/// User cancelled the flow (i.e. back button), thus don't proceed to scan.
	func scanInstructionsWasCancelled() {
		removeScanInstructionsCoordinator()
		dashboardNavigationController?.popToRootViewController(animated: true)
	}

	private func removeScanInstructionsCoordinator() {
		guard let childCoordinator = self.childCoordinators.first(
			where: { $0 is ScanInstructionsCoordinator }
		) else { return }
		
		self.removeChildCoordinator(childCoordinator)
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
				
			case .scanInstructions:
				sidePanel?.selectedViewController = dashboardNavigationController
				let coordinator = ScanInstructionsCoordinator(
					navigationController: dashboardNavigationController!,
					delegate: self,
					isOpenedFromMenu: true
				)
				startChildCoordinator(coordinator)
				
			case .riskSetting:
				let destination = RiskSettingStartViewController(
					viewModel: RiskSettingStartViewModel(
						coordinator: self
					)
				)
				navigationController = UINavigationController(rootViewController: destination)
				sidePanel?.selectedViewController = navigationController

			case .support:
				guard let faqUrl = URL(string: L.verifierUrlFaq()) else {
					logError("No verifier faq url")
					return
				}
				openUrl(faqUrl, inApp: true)
				
			case .about :
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

		var list = [
			MenuItem(identifier: .overview, title: L.verifierMenuDashboard()),
			MenuItem(identifier: .scanInstructions, title: L.verifierMenuScaninstructions())
		]
		if Services.featureFlagManager.isVerificationPolicyEnabled() {
			list.append(MenuItem(identifier: .riskSetting, title: L.verifier_menu_risksetting()))
		}
		return list
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
