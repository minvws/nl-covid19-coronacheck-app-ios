/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

/// The Application flavor
enum AppFlavor: String {
	
	/// We are a holder
	case holder
	
	/// We are a verifier
	case verifier
	
	/// The flavor of the app
	static var flavor: AppFlavor {
		
		if let value = Bundle.main.infoDictionary?["APP_FLAVOR"] as? String,
		   let fls = AppFlavor(rawValue: value ) {
			return fls
		}
		return .holder
	}
}

protocol AppCoordinatorDelegate: AnyObject {

	/// Open a url
	func openUrl(_ url: URL)
}

class AppCoordinator: Coordinator, Logging {

	/// The logging category
	var loggingCategory: String = "AppCoordinator"

	/// The UI Window
	let window: UIWindow

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

		guard !ProcessInfo.processInfo.isTesting else {
			return
		}

		// Setup Logging
		LogHandler.setup()

		// Check if the app is the minimum version. If not, show the app update screen
		updateConfiguration()

		// Set the root
		window.rootViewController = navigationController
		window.makeKeyAndVisible()

		switch AppFlavor.flavor {
			case .holder:
				startAsHolder()
			default:
				startAsVerifier()
		}
	}

	/// Start the app as a holder
	func startAsHolder() {

		let coordinator = HolderCoordinator(navigationController: navigationController, window: window)
		startChildCoordinator(coordinator)
	}

	/// Start the app as a verifiier
	func startAsVerifier() {

		let coordinator = VerifierCoordinator(navigationController: navigationController, window: window)
		startChildCoordinator(coordinator)
	}

	/// flag for updating configuration
	private var isUpdatingConfiguration = false

	/// The remote config manager
	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager

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
