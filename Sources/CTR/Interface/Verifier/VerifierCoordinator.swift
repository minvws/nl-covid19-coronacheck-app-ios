/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Clcore
import Transport
import Shared
import ReusableViews
import Models
import Managers
import Resources

protocol VerifierCoordinatorDelegate: AnyObject {
	
	/// The user finished the start scene
	/// - Parameter result: the result of the start scene
	func didFinish(_ result: VerifierStartResult)
	
	func openUrl(_ url: URL)
	
	func navigateToAboutThisApp()
	
	func navigateToVerifierWelcome()
	
	func navigateToOpenRiskLevelSettings()
	
	func navigateToScan()
	
	func navigateToScanInstruction(allowSkipInstruction: Bool)
	
	func userWishesMoreInfoAboutClockDeviation()
	
	func navigateToVerifiedInfo()
	
	func userWishesToOpenTheMenu()
	
	func userWishesToLaunchThirdPartyScannerApp()
	
	func navigateToCheckIdentity(_ verificationDetails: MobilecoreVerificationDetails)
	
	func navigateToVerifiedAccess(_ verifiedAccess: VerifiedAccess)
	
	func navigateToDeniedAccess()
	
	func userWishesToSetRiskLevel(shouldSelectSetting: Bool)
	
	func userWishesMoreInfoAboutDeniedQRScan()
	
	func userWishesToSeeHelpdesk()
}

class VerifierCoordinator: SharedCoordinator {
	
	/// The factory for onboarding pages
	var onboardingFactory: OnboardingFactoryProtocol = VerifierOnboardingFactory()
	
	internal var thirdPartyScannerApp: (name: String, returnURL: URL)?
	
	private var verificationPolicyEnablerObserverToken: Observatory.ObserverToken?
	
	// Designated starter method
	override func start() {
		
		verificationPolicyEnablerObserverToken = Current.verificationPolicyEnabler.observatory.append { [weak self] _ in
			guard let self, self.navigationController.viewControllers.contains(where: { $0 is VerifierStartScanningViewController }) else { return }
			self.navigateToVerifierWelcome()
		}
		
		handleOnboarding(
			onboardingFactory: onboardingFactory,
			newFeaturesFactory: VerifierNewFeaturesFactory()
		) {
			navigateToVerifierWelcome()
		}
	}
	
	// MARK: - Universal Links
	
	override func consume(universalLink: UniversalLink) -> Bool {
		switch universalLink {
			case .thirdPartyScannerApp(let returnURL):
				return consumeThirdPartyScanner(returnURL)
			default:
				return false
		}
	}
	
	private func consumeThirdPartyScanner(_ returnURL: URL?) -> Bool {
		
		guard let returnURL = returnURL,
			  let matchingMetadata = remoteConfigManager.storedConfiguration.universalLinkPermittedDomains?.first(where: { permittedDomain in
				  permittedDomain.url == returnURL.host
			  })
		else {
			return true
		}
		
		// Is the user currently permitted to scan?
		guard Current.scanLockManager.state == .unlocked && Current.verificationPolicyManager.state != nil
		else { return true } // handled (but ignored)
		
		thirdPartyScannerApp = (name: matchingMetadata.name, returnURL: returnURL)
		
		// On next runloop to show navigation animation and to open camera right after app launch
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			self.navigateToScan()
		}
		
		return true
	}
	
	deinit {
		verificationPolicyEnablerObserverToken.map(Current.verificationPolicyEnabler.observatory.remove)
	}
}

// MARK: - VerifierCoordinatorDelegate

extension VerifierCoordinator: VerifierCoordinatorDelegate {
	
	/// Navigate to verifier welcome scene
	func navigateToVerifierWelcome() {
		
		if let existingStartViewController = navigationController.viewControllers.first(where: { $0 is VerifierStartScanningViewController }) {
			navigationController.popToViewController(existingStartViewController, animated: true)
		} else {
			
			let dashboardViewController = VerifierStartScanningViewController(
				viewModel: VerifierStartScanningViewModel(coordinator: self)
			)
			
			navigationController.setViewControllers([dashboardViewController], animated: false)
			window.replaceRootViewController(with: navigationController)
		}
	}
	
	func didFinish(_ result: VerifierStartResult) {
		
		switch result {
			case .userTappedProceedToScan:
				
				if !Current.userSettings.scanInstructionShown ||
					(!Current.userSettings.policyInformationShown && Current.featureFlagManager.is1GVerificationPolicyEnabled()) ||
					(Current.verificationPolicyManager.state == nil && Current.featureFlagManager.areMultipleVerificationPoliciesEnabled()) {
					// Show the scan instructions the first time no matter what link was tapped
					navigateToScanInstruction(allowSkipInstruction: true)
				} else {
					navigateToScan()
				}
			case .userTappedProceedToScanInstructions:
				navigateToScanInstruction(allowSkipInstruction: false)
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
		navigationController.pushViewController(viewController, animated: false)
	}
	
	func navigateToVerifiedAccess(_ verifiedAccess: VerifiedAccess) {
		
		let viewController = VerifiedAccessViewController(
			viewModel: VerifiedAccessViewModel(
				coordinator: self,
				verifiedAccess: verifiedAccess
			)
		)
		navigationController.pushWithFadeAnimation(
			with: viewController,
			animationDuration: VerifiedAccessViewTraits.Animation.verifiedDuration
		)
	}
	
	func navigateToDeniedAccess() {
		
		let viewController = DeniedAccessViewController(
			viewModel: DeniedAccessViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}
	
	func navigateToScanInstruction(allowSkipInstruction: Bool) {
		
		let coordinator = ScanInstructionsCoordinator(
			navigationController: navigationController,
			delegate: self,
			isOpenedFromMenu: false,
			allowSkipInstruction: allowSkipInstruction
		)
		startChildCoordinator(coordinator)
	}
	
	/// Navigate to the QR scanner
	func navigateToScan() {
		
		if let existingScanViewController = navigationController.viewControllers.first(where: { $0 is VerifierScanViewController }) {
			navigationController.popToViewController(existingScanViewController, animated: true)
		} else {
			let destination = VerifierScanViewController(
				viewModel: VerifierScanViewModel(
					coordinator: self
				)
			)
			navigationController.pushOrReplaceTopViewController(with: destination, animated: true)
		}
	}
	
	func userWishesToOpenTheMenu() {
		
		let viewController = MenuViewController(viewModel: VerifierMainMenuViewModel(self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToSeeHelpdesk() {
		
		let viewController = HelpdeskViewController(
			viewModel: HelpdeskViewModel(
				flavor: AppFlavor.flavor,
				versionSupplier: self.versionSupplier,
				urlHandler: { [weak self] url in
					self?.openUrl(url)
				}
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesMoreInfoAboutClockDeviation() {
		let title: String = L.verifierClockDeviationDetectedTitle()
		let message: String = L.verifierClockDeviationDetectedMessage(UIApplication.openSettingsURLString)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false)
	}
	
	func userWishesToOpenScanLog() {
		
		let viewController = ScanLogViewController(
			viewModel: ScanLogViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func navigateToOpenRiskLevelSettings() {
		let viewController = RiskSettingStartViewController(
			viewModel: RiskSettingStartViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func navigateToAboutThisApp() {
		let viewModel = AboutThisAppViewModel(versionSupplier: versionSupplier, flavor: AppFlavor.flavor) { [weak self] outcome in
			guard let self else { return }
			switch outcome {
				case let .openURL(url):
					self.openUrl(url)
				case .userWishesToOpenScanLog:
					self.userWishesToOpenScanLog()
				case .coordinatorShouldRestart:
					self.restart()
			}
		}
		let viewController = AboutThisAppViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func navigateToVerifiedInfo() {
		
		let viewController = VerifiedInfoViewController(
			viewModel: VerifiedInfoViewModel(
				coordinator: self,
				isDeepLinkEnabled: thirdPartyScannerApp != nil
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToLaunchThirdPartyScannerApp() {
		if let thirdPartyScannerApp {
			openUrl(thirdPartyScannerApp.returnURL)
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
					coordinator: self
				)
			)
		}
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesMoreInfoAboutDeniedQRScan() {
		let viewController = DeniedQRScanMoreInfoViewController(
			viewModel: DeniedQRScanMoreInfoViewModel(coordinator: self)
		)
		presentAsBottomSheet(viewController)
	}
}

// MARK: ScanInstructions Delegate

extension VerifierCoordinator: ScanInstructionsDelegate {
	
	/// User completed (or skipped) the Scan Instructions flow
	func scanInstructionsDidFinish(hasScanLock: Bool) {
		
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
		navigationController.popViewController(animated: true)
	}
	
	private func removeScanInstructionsCoordinator() {
		guard let childCoordinator = self.childCoordinators.first(
			where: { $0 is ScanInstructionsCoordinator }
		) else { return }
		
		self.removeChildCoordinator(childCoordinator)
	}
}
