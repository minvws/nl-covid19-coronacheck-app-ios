/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews
import Models

protocol MigrationFlowDelegate: AnyObject {

	func dataMigrationCancelled()

//	func dataMigrationExportCompleted()
//
//	func dataMigrationImportCompleted()
}
//
protocol MigrationCoordinatorDelegate: AnyObject {
	
	func userCompletedStart()

	func userWishesToSeeImportInstructions()

	func userWishesToSeeExportInstructions()
//
//	func userWishesToStartImport()
//
//	func userWishesToStartExport()
}

class MigrationCoordinator: NSObject, Coordinator {

//	private let version: String = "CC1"
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController
	
	weak var delegate: MigrationFlowDelegate?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the migration flow delegate
	init(navigationController: UINavigationController, delegate: MigrationFlowDelegate) {
		
		self.navigationController = navigationController
		self.delegate = delegate
		super.init()
		self.navigationController.delegate = self
	}
	
	func start() {
		
		let viewController = ContentWithImageViewController(
			viewModel: MigrationStartViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	// MARK: - Universal Link handling
	
	func consume(universalLink: Models.UniversalLink) -> Bool {
		
		return false
	}
}

extension MigrationCoordinator: MigrationCoordinatorDelegate {
	
	func userCompletedStart() {
		
		if Current.walletManager.listEventGroups().isNotEmpty {

			// We have events -> make the user choose
			let viewController = ListOptionsViewController(viewModel: MigrationTransferOptionsViewModel(self))
			navigationController.pushViewController(viewController, animated: true)
		} else {
			
			// We have no events -> import only
			userWishesToSeeImportInstructions()
		}
	}
	
	func userWishesToSeeImportInstructions() {

		logDebug("userWishesToSeeImportInstructions")
	}

	func userWishesToSeeExportInstructions() {

		logDebug("userWishesToSeeExportInstructions")
	}
//
//	func userWishesToStartImport() {
//
//		logDebug("userWishesToStartImport")
//	}
//
//	func userWishesToStartExport() {
//
//		logDebug("userWishesToStartExport")
//	}
}

extension MigrationCoordinator: UINavigationControllerDelegate {

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

		if !navigationController.viewControllers.contains(where: { $0.isKind(of: ContentWithImageViewController.self) }) {
			// If there is no more ContentWithIconViewController in the stack, we are done here.
			// Works for both back swipe and back button
			delegate?.dataMigrationCancelled()
		}
	}
}
