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
	@Bindable private(set) var pages: [ScanInstructionsPage]

	@Bindable private(set) var shouldShowSkipButton: Bool = true

	@Bindable private(set) var nextButtonTitle: String?

	private var currentPage: Int {
		didSet {
			updateState()
		}
	}

	private let userSettings: UserSettingsProtocol
	private let riskLevelManager: RiskLevelManaging
	private let scanLogManager: ScanLogManaging
	private var shouldShowRiskSetting = false
	private var hasScanLock = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: ScanInstructionsCoordinatorDelegate,
		pages: [ScanInstructionsPage],
		userSettings: UserSettingsProtocol,
		riskLevelManager: RiskLevelManaging = Services.riskLevelManager,
		scanLogManager: ScanLogManaging = Services.scanLogManager,
		configuration: RemoteConfiguration
	) {
		
		self.coordinator = coordinator
		self.pages = pages
		self.userSettings = userSettings
		self.riskLevelManager = riskLevelManager
		self.scanLogManager = scanLogManager
		self.currentPage = 0
		
		shouldShowRiskSetting = riskLevelManager.state == nil
		if let scanLock = configuration.scanLockWarningSeconds {
			hasScanLock = scanLogManager.didWeScanQRs(seconds: scanLock)
		}
		
		updateState()
	}
	
	func scanInstructionsViewController(forPage page: ScanInstructionsPage) -> ScanInstructionsPageViewController {
		let viewController = ScanInstructionsPageViewController(
			viewModel: ScanInstructionsPageViewModel(page: page)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}
	
	func finishScanInstructions() {
		
		if shouldShowRiskSetting {
			coordinator?.userWishesToSelectRiskSetting()
		} else {
			coordinator?.userDidCompletePages(hasScanLock: hasScanLock)
		}
	}
	
	func finishSelectRiskSetting() {
		
		coordinator?.userDidCompletePages(hasScanLock: hasScanLock)
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
		
		if currentPage == lastPage, !shouldShowRiskSetting {
			if hasScanLock {
				nextButtonTitle = L.verifier_scan_instructions_back_to_start()
			} else {
				nextButtonTitle = L.verifierScaninstructionsButtonStartscanning()
			}
		} else {
			nextButtonTitle = L.generalNext()
		}
	}
}
