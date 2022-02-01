/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ScanInstructionsCoordinatorDelegate: AnyObject {

	/// The user pressed continue on the currently displayed page
	func userDidCompletePages(hasScanLock: Bool)

	/// User pressed back on first page, thus cancelling this flow
	func userDidCancelScanInstructions()
	
	func userWishesToSelectRiskSetting()
	
	func userWishesToReadPolicyInformation()
}

protocol ScanInstructionsDelegate: AnyObject {
	func scanInstructionsWasCancelled()
	func scanInstructionsDidFinish(hasScanLock: Bool)
}

class ScanInstructionsCoordinator: Coordinator, Logging, ScanInstructionsCoordinatorDelegate, OpenUrlProtocol {

	weak var delegate: ScanInstructionsDelegate?

	var loggingCategory: String = "ScanInstructionsCoordinator"
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController

	private let pagesFactory: ScanInstructionsFactoryProtocol = ScanInstructionsFactory()
	private let pages: [ScanInstructionsPage]
	private let isOpenedFromMenu: Bool
	private let allowSkipInstruction: Bool
	private let riskLevelManager: RiskLevelManaging
	private let userSettings: UserSettingsProtocol

	init(
		navigationController: UINavigationController,
		delegate: ScanInstructionsDelegate,
		isOpenedFromMenu: Bool,
		allowSkipInstruction: Bool,
		userSettings: UserSettingsProtocol = UserSettings(),
		riskLevelManager: RiskLevelManaging = Current.riskLevelManager
	) {

		self.navigationController = navigationController
		self.delegate = delegate
		self.isOpenedFromMenu = isOpenedFromMenu
		self.allowSkipInstruction = allowSkipInstruction
		self.userSettings = userSettings
		self.riskLevelManager = riskLevelManager

		pages = pagesFactory.create()
	}

	// Designated starter method
	func start() {

		let viewController: UIViewController
		
		if !isOpenedFromMenu,
		   allowSkipInstruction,
		   userSettings.scanInstructionShown {
			if !userSettings.policyInformationShown, Current.featureFlagManager.is1GPolicyEnabled() {
				let viewModel = PolicyInformationViewModel(coordinator: self)
				viewController = PolicyInformationViewController(viewModel: viewModel)
			} else {
				let viewModel = RiskSettingInstructionViewModel(coordinator: self)
				viewController = RiskSettingInstructionViewController(viewModel: viewModel)
			}
		} else {
			let viewModel = ScanInstructionsViewModel(
				coordinator: self,
				pages: pages
			)
			viewController = ScanInstructionsViewController(viewModel: viewModel)
		}
		
		navigationController.pushViewController(viewController, animated: !isOpenedFromMenu)
	}

	func userDidCompletePages(hasScanLock: Bool) {
		delegate?.scanInstructionsDidFinish(hasScanLock: hasScanLock)
	}

	func userDidCancelScanInstructions() {
		delegate?.scanInstructionsWasCancelled()
	}
	
	func userWishesToSelectRiskSetting() {
		let viewController = RiskSettingInstructionViewController(
			viewModel: RiskSettingInstructionViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToReadPolicyInformation() {
		let viewController = PolicyInformationViewController(
			viewModel: PolicyInformationViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	// MARK: - Universal Link handling

	/// Override point for coordinators which wish to deal with universal links.
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}
