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
	private var shouldShowRiskSetting = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: ScanInstructionsCoordinatorDelegate,
		pages: [ScanInstructionsPage],
		userSettings: UserSettingsProtocol
	) {
		
		self.coordinator = coordinator
		self.pages = pages
		self.userSettings = userSettings
		self.currentPage = 0
		
		shouldShowRiskSetting = userSettings.scanRiskLevelValue == nil
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
			coordinator?.userDidCompletePages()
		}
	}
	
	func finishSelectRiskSetting() {
		
		coordinator?.userDidCompletePages()
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
			nextButtonTitle = L.verifierScaninstructionsButtonStartscanning()
		} else {
			nextButtonTitle = L.generalNext()
		}
	}
}
