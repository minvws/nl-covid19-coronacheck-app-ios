/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ScanInstructionsCoordinatorDelegate: AnyObject {

	/// The user pressed continue on the currently displayed page
	func userDidCompletePages()

	/// User pressed back on first page, thus cancelling this flow
	func userDidCancelScanInstructions()
	
	func userWishesToSelectRiskSetting()
}

protocol ScanInstructionsDelegate: AnyObject {
	func scanInstructionsWasCancelled()
	func scanInstructionsDidFinish()
}

class ScanInstructionsCoordinator: Coordinator, Logging, ScanInstructionsCoordinatorDelegate, OpenUrlProtocol {

	weak var delegate: ScanInstructionsDelegate?

	var loggingCategory: String = "ScanInstructionsCoordinator"
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController

	private let pagesFactory: ScanInstructionsFactoryProtocol = ScanInstructionsFactory()
	private let pages: [ScanInstructionsPage]
	private let isOpenedFromMenu: Bool

	init(navigationController: UINavigationController, delegate: ScanInstructionsDelegate, isOpenedFromMenu: Bool) {

		self.navigationController = navigationController
		self.delegate = delegate
		self.isOpenedFromMenu = isOpenedFromMenu

		pages = pagesFactory.create()
	}

	// Designated starter method
	func start() {

		let viewModel = ScanInstructionsViewModel(
			coordinator: self,
			pages: pages,
			userSettings: UserSettings()
		)
		let viewController = ScanInstructionsViewController(viewModel: viewModel)
		navigationController.pushOrReplaceTopViewController(with: viewController, animated: !isOpenedFromMenu)
	}

	func userDidCompletePages() {
		delegate?.scanInstructionsDidFinish()
	}

	func userDidCancelScanInstructions() {
		delegate?.scanInstructionsWasCancelled()
	}
	
	func userWishesToSelectRiskSetting() {
		let viewModel = RiskSettingViewModel(coordinator: self,
											 userSettings: UserSettings())
		let viewController = RiskSettingViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}

	// MARK: - Universal Link handling

	/// Override point for coordinators which wish to deal with universal links.
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}
