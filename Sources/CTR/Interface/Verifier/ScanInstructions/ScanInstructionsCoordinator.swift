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
}

protocol ScanInstructionsDelegate: AnyObject {
	func scanInstructionsWasCancelled()
	func scanInstructionsDidFinish()
}

class ScanInstructionsCoordinator: Coordinator, Logging, ScanInstructionsCoordinatorDelegate {

	weak var delegate: ScanInstructionsDelegate?

	var loggingCategory: String = "ScanInstructionsCoordinator"
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController

	private let pagesFactory: ScanInstructionsFactoryProtocol = ScanInstructionsFactory()
	private let pages: [ScanInstructionsPage]

	init(navigationController: UINavigationController, delegate: ScanInstructionsDelegate) {

		self.navigationController = navigationController
		self.delegate = delegate

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
		navigationController.pushOrReplaceTopViewController(with: viewController, animated: true)
	}

	func userDidCompletePages() {
		delegate?.scanInstructionsDidFinish()
	}

	func userDidCancelScanInstructions() {
		delegate?.scanInstructionsWasCancelled()
	}

	// MARK: - Universal Link handling

	/// Override point for coordinators which wish to deal with universal links.
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}
