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
	
	func navigateToScanInstruction(allowSkipInstruction: Bool)
	
	func userWishesMoreInfoAboutClockDeviation()
	
	func navigateToVerifiedInfo()
	
	func userWishesToOpenTheMenu()
	
	func userWishesToOpenScanLog()
	
	func userWishesToLaunchThirdPartyScannerApp()
	
	func navigateToCheckIdentity(_ verificationDetails: MobilecoreVerificationDetails)
	
	func navigateToVerifiedAccess(_ verifiedAccess: VerifiedAccess)
	
	func navigateToDeniedAccess(_ deniedAccessReason: DeniedAccessReason)
	
	func userWishesToSetRiskLevel(shouldSelectSetting: Bool)
	
	func userWishesMoreInfoAboutDeniedQRScan()
	
	func navigateToScanNextInstruction(_ scanNext: ScanNext)
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
			
			Current.scanLogManager.deleteExpiredScanLogEntries(
				seconds: Current.remoteConfigManager.storedConfiguration.scanLogStorageSeconds ?? 3600
			)
			navigateToVerifierWelcome()
		}
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
				guard Current.scanLockManager.state == .unlocked && Current.riskLevelManager.state != nil
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
		
		if let existingStartViewController = navigationController.viewControllers.first(where: { $0 is VerifierStartViewController }) {
			navigationController.popToViewController(existingStartViewController, animated: true)
		} else {
			
			let dashboardViewController = VerifierStartViewController(
				viewModel: VerifierStartViewModel(coordinator: self)
			)
			
			navigationController.setViewControllers([dashboardViewController], animated: false)
		}
	}
	
	func didFinish(_ result: VerifierStartResult) {
		
		switch result {
			case .userTappedProceedToScan:
				navigateToScan()
				
			case .userTappedProceedToScanInstructions:
				navigateToScanInstruction(allowSkipInstruction: false)
				
			case .userTappedProceedToInstructionsOrRiskSetting:
				navigateToScanInstruction(allowSkipInstruction: true)
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
	
	func navigateToDeniedAccess(_ deniedAccessReason: DeniedAccessReason) {
		
		let viewController = DeniedAccessViewController(
			viewModel: DeniedAccessViewModel(
				coordinator: self,
				deniedAccessReason: deniedAccessReason
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
		
		let itemHowItWorks: NewMenuViewModel.Item = .row(title: L.verifierMenuScaninstructions(), icon: I.icon_menu_howitworks()!, action: { [weak self] in
			self?.navigateToScanInstruction(allowSkipInstruction: false)
		})
		
		let itemFAQ: NewMenuViewModel.Item = .row(title: L.verifierMenuSupport(), icon: I.icon_menu_faq()!, action: { [weak self] in
			guard let faqUrl = URL(string: L.verifierUrlFaq()) else { return }
			self?.openUrl(faqUrl, inApp: true)
		})
		
		let itemRiskSetting: NewMenuViewModel.Item = .row(title: L.verifier_menu_risksetting(), icon: I.icon_menu_risklevel()!, action: { [weak self] in
			self?.navigateToOpenRiskLevelSettings()
		})
		
		let itemAboutThisApp: NewMenuViewModel.Item = .row(title: L.verifierMenuAbout(), icon: I.icon_menu_aboutthisapp()!, action: { [weak self] in
			 self?.navigateToAboutThisApp()
		})
		
		let items: [NewMenuViewModel.Item] = {
			if Current.featureFlagManager.isVerificationPolicyEnabled() {
				return [
					itemHowItWorks,
					itemFAQ,
					itemRiskSetting,
					itemAboutThisApp
				]
			} else {
				return [
					itemHowItWorks,
					itemFAQ,
					itemAboutThisApp
				]
			}
		}()
		
		let viewController = NewMenuViewController(viewModel: NewMenuViewModel(items: items))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesMoreInfoAboutClockDeviation() {
		let title: String = L.verifierClockDeviationDetectedTitle()
		let message: String = L.verifierClockDeviationDetectedMessage(UIApplication.openSettingsURLString)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: false)
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
		let viewController = AboutThisAppViewController(
			viewModel: AboutThisAppViewModel(
				coordinator: self,
				versionSupplier: versionSupplier,
				flavor: AppFlavor.flavor
			)
		)
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
					coordinator: self
				)
			)
		}
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func navigateToScanNextInstruction(_ scanNext: ScanNext) {
		
		let viewController = ScanNextInstructionViewController(
			viewModel: ScanNextInstructionViewModel(
				coordinator: self,
				scanNext: scanNext
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesMoreInfoAboutDeniedQRScan() {
		let viewController = DeniedQRScanMoreInfoViewController(
			viewModel: DeniedQRScanMoreInfoViewModel(coordinator: self)
		)
		navigationController.presentBottomSheet(viewController)
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
