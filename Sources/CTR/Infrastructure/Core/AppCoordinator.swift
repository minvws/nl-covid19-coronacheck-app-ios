/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

protocol AppCoordinatorDelegate: AnyObject {

	/// Open a url
	func openUrl(_ url: URL)
}

class AppCoordinator: Coordinator {

	/// The UI Window
	private let window: UIWindow

	/// The Child Coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// For use with iOS 13 and higher
	@available(iOS 13.0, *)
	init(scene: UIWindowScene, navigationController: UINavigationController) {

		window = UIWindow(windowScene: scene)
		self.navigationController = navigationController
	}

	/// For use with iOS 12.
	init(navigationController: UINavigationController) {

		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.navigationController = navigationController
	}

	/// Designated starter method
	func start() {

		// Setup Logging
		LogHandler.setup()

		// Check if the app is the minimum version. If not, show the app update screen
		updateConfiguration()

		// Set the root
		window.rootViewController = navigationController
		window.makeKeyAndVisible()

		// Start the mainCoordinator
		let mainCoordinator = MainCoordinator(navigationController: navigationController)
		startChildCoordinator(mainCoordinator)
	}

	/// flag for updating configuration
	private var isUpdatingConfiguration = false

	var remoteConfigManager: RemoteConfigManagerProtocol = RemoteConfigManager()

	/// Update the configuration
	func updateConfiguration() {

		// Execute once.
		guard !isUpdatingConfiguration else {
			return
		}

		isUpdatingConfiguration = true

		remoteConfigManager.update { [unowned self] updateState in
			switch updateState {
				case .actionRequired(let versionInformation):
					showActionRequired(with: versionInformation)
				case .noActionNeeded:
					break
			}

			isUpdatingConfiguration = false
		}
	}

	/// Show the Action Required View
	/// - Parameter versionInformation: the version information
	private func showActionRequired(with versionInformation: AppVersionInformation) {

		guard var topController = window.rootViewController else { return }

		while let newTopController = topController.presentedViewController {
			topController = newTopController
		}

		guard !(topController is AppUpdateViewController) else { return }

		var viewModel = AppUpdateViewModel(coordinator: self, versionInformation: versionInformation)

		if versionInformation.isDeactivated {
			viewModel = EndOfLifeViewModel(coordinator: self, versionInformation: versionInformation)
		}
		let updateController = AppUpdateViewController(viewModel: viewModel)
		topController.present(updateController, animated: true)
	}
}

// MARK: - AppCoordinatorDelegate

extension AppCoordinator: AppCoordinatorDelegate {

	/// Open a url
	func openUrl(_ url: URL) {

		UIApplication.shared.open(url)
	}
}
