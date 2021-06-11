/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol AppCoordinatorDelegate: AnyObject {

	func openUrl(_ url: URL)

    func handleLaunchState(_ state: LaunchState)

	/// Retry loading the requirements
	func retry()
}

class AppCoordinator: Coordinator, Logging {

	var loggingCategory: String = "AppCoordinator"

	let window: UIWindow

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	private var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager

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

    // MARK: - Private functions

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

        navigationController.viewControllers = [destination]
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

        if let universalLink = self.unhandledUniversalLink {
           coordinator.receive(universalLink: universalLink)
        }
    }

    /// Start the app as a verifiier
    private func startAsVerifier() {

        let coordinator = VerifierCoordinator(navigationController: navigationController, window: window)
        startChildCoordinator(coordinator)
    }

	/// Show the Action Required View
	/// - Parameter versionInformation: the version information
	private func showActionRequired(with versionInformation: RemoteInformation) {
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

    // MARK: - Universal Link handling

    /// If set, this should be handled at the first opportunity:
    private var unhandledUniversalLink: UniversalLink?

    func consume(universalLink: UniversalLink) -> Bool {

        switch universalLink {
            case .redeemHolderToken:
                /// If we reach here it means that there was no holderCoordinator initialized at the time
                /// the universal link was received. So hold onto it here, for when it is ready.
                unhandledUniversalLink = universalLink
                return true
        }
    }
}

// MARK: - AppCoordinatorDelegate

extension AppCoordinator: AppCoordinatorDelegate {

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

		if let presentedViewController = navigationController.presentedViewController {
			presentedViewController.dismiss(animated: true) { [weak self] in
				self?.startLauncher()
			}
		} else {
			startLauncher()
		}
    }
}

// MARK: - Notification observations

extension AppCoordinator {

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
}
