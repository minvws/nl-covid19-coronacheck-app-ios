/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsViewModel {
	
	/// Coordination Delegate
	weak var coordinator: ScanInstructionsCoordinatorDelegate?
	
	/// The pages for onboarding
	@Bindable private(set) var pages: [ScanInstructionsItem]

	@Bindable private(set) var shouldShowSkipButton: Bool = true

	@Bindable private(set) var nextButtonTitle: String?

	private var currentPage: Int {
		didSet {
			updateState()
		}
	}

	private let userSettings: UserSettingsProtocol = Current.userSettings
	private let riskLevelManager: VerificationPolicyManaging = Current.riskLevelManager
	private let scanLockManager: ScanLockManaging = Current.scanLockManager
	private var shouldShowRiskSetting = false
	private var hasScanLock = false
	private var scanLockObserverToken: ScanLockManager.ObserverToken?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: ScanInstructionsCoordinatorDelegate,
		pages: [ScanInstructionsItem]
	) {
		
		self.coordinator = coordinator
		self.pages = pages
		self.currentPage = 0

		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			shouldShowRiskSetting = riskLevelManager.state == nil
		}
		
		hasScanLock = scanLockManager.state != .unlocked
		updateState()
		
		scanLockObserverToken = scanLockManager.appendObserver { [weak self] lockState in
			self?.hasScanLock = lockState != .unlocked
			self?.updateState()
		}
	}
	
	func scanInstructionsViewController(forPage page: ScanInstructionsItem) -> ScanInstructionsItemViewController {
		let viewController = ScanInstructionsItemViewController(
			viewModel: ScanInstructionsItemViewModel(page: page)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}
	
	func finishScanInstructions() {
		
		userSettings.scanInstructionShown = true

		if !userSettings.policyInformationShown, Current.featureFlagManager.is1GVerificationPolicyEnabled() {
			coordinator?.userWishesToReadPolicyInformation()
		} else if shouldShowRiskSetting {
			coordinator?.userWishesToSelectRiskSetting()
		} else {
			coordinator?.userDidCompletePages(hasScanLock: hasScanLock)
		}
	}

	/// i.e. exit the Scan Instructions
	func userTappedBackOnFirstPage() {
		coordinator?.userDidCancelScanInstructions()
	}

	func userDidChangeCurrentPage(toPageIndex pageIndex: Int) {
		currentPage = pageIndex
	}

	private func updateState() {
		let lastPage = pages.count - 1
		
		shouldShowSkipButton = {
			guard !userSettings.scanInstructionShown else { return false }
			return currentPage < lastPage
		}()
		
		if currentPage == lastPage {
			if hasScanLock {
				nextButtonTitle = L.verifier_scan_instructions_back_to_start()
			} else if (!userSettings.policyInformationShown && Current.featureFlagManager.is1GVerificationPolicyEnabled()) || shouldShowRiskSetting {
				nextButtonTitle = L.generalNext()
			} else {
				nextButtonTitle = L.verifierScaninstructionsButtonStartscanning()
			}
		} else {
			nextButtonTitle = L.generalNext()
		}
	}
}
