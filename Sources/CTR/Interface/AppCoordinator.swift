/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol AppCoordinatorDelegate: AnyObject {

	/// Open a url
	func openUrl(_ url: URL)

	/// Handle the launch state
	/// - Parameter state: the launch state
	func handleLaunchState(_ state: LaunchState)

	/// Retry loading the requirements
	func retry()
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

	/// The remote config manager
	private var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager

	/// The proof manager
	private var proofManager: ProofManaging = Services.proofManager

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

		// Start the launcher for update checks
		startLauncher()
		addObservers()
	}

    /// Handle the event the application did enter the background
    @objc func onApplicationDidEnterBackground() {

        /// Show the snapshot (logo) view to hide sensitive data
        let shapshotViewController = SnapshotViewController(
            viewModel: SnapshotViewModel(
                versionSupplier: AppVersionSupplier(),
                flavor: AppFlavor.flavor
            )
        )
        shapshotViewController.modalPresentationStyle = .fullScreen
        guard let topController = window.rootViewController else { return }
        if topController is UINavigationController {
            (topController as? UINavigationController)?.viewControllers.last?.present(shapshotViewController, animated: true)
        } else {
            topController.present(shapshotViewController, animated: true)
        }
    }

    private func addObservers() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onApplicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    /// Launch the launcher
    private func startLauncher() {

        let destination = LaunchViewController(
            viewModel: LaunchViewModel(
                coordinator: self,
                versionSupplier: AppVersionSupplier(),
                flavor: AppFlavor.flavor,
                remoteConfigManager: remoteConfigManager,
                proofManager: proofManager
            )
        )
        // Set the root
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        navigationController.pushViewController(destination, animated: false)
    }

    /// Start the real application
    private func startApplication() {

        switch AppFlavor.flavor {
            case .holder:
                startAsHolder()
            default:
                startAsVerifier()
        }
    }

    /// Start the app as a holder
    private func startAsHolder() {

        let coordinator = HolderCoordinator(navigationController: navigationController, window: window)
        startChildCoordinator(coordinator)
    }

    /// Start the app as a verifiier
    private func startAsVerifier() {

        let coordinator = VerifierCoordinator(navigationController: navigationController, window: window)
        startChildCoordinator(coordinator)
    }

	/// Show the Action Required View
	/// - Parameter versionInformation: the version information
	private func showActionRequired(with versionInformation: AppVersionInformation) {
		var viewModel = AppUpdateViewModel(coordinator: self, versionInformation: versionInformation)
		if versionInformation.isDeactivated {
			viewModel = EndOfLifeViewModel(coordinator: self, versionInformation: versionInformation)
		}
		navigateToAppUpdate(with: viewModel)
	}

	private func showInternetRequired() {

		let viewModel = InternetRequiredViewModel(coordinator: self)
		navigateToAppUpdate(with: viewModel)
	}

	/// Show the Action Required View
	/// - Parameter versionInformation: the version information
	private func navigateToAppUpdate(with viewModel: AppUpdateViewModel) {

		guard var topController = window.rootViewController else { return }

		while let newTopController = topController.presentedViewController {
			topController = newTopController
		}
		guard !(topController is AppUpdateViewController) else { return }
		let updateController = AppUpdateViewController(viewModel: viewModel)

		if topController is UINavigationController {
			(topController as? UINavigationController)?.viewControllers.last?.present(updateController, animated: true)
		} else {
			topController.present(updateController, animated: true)
		}
	}
}

// MARK: - AppCoordinatorDelegate

extension AppCoordinator: AppCoordinatorDelegate {

	/// Open a url
	func openUrl(_ url: URL) {

		UIApplication.shared.open(url)
	}

    /// Handle the launch state
    /// - Parameter state: the launch state
    func handleLaunchState(_ state: LaunchState) {

        switch state {
        case .noActionNeeded:
            startApplication()

        case .internetRequired:
            showInternetRequired()

        case let .actionRequired(versionInformation):
            showActionRequired(with: versionInformation)
        }
    }

    /// Retry loading the requirements
    func retry() {

        guard let topController = window.rootViewController else { return }

        topController.dismiss(animated: true) {
            ((topController as? UINavigationController)?.viewControllers.first as? LaunchViewController)?.checkRequirements()
        }
    }
}
