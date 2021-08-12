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
	
	private var privacySnapshotWindow: UIWindow?

	private var shouldUsePrivacySnapShot = true

	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()

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
                versionSupplier: versionSupplier,
                flavor: AppFlavor.flavor,
				walletManager: AppFlavor.flavor == .holder ? Services.walletManager : nil
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

    /// Start the app as a verifier
    private func startAsVerifier() {

        let coordinator = VerifierCoordinator(navigationController: navigationController, window: window)
        startChildCoordinator(coordinator)
    }
	
	/// Show the Internet Required View
	private func showInternetRequired() {

		let viewModel = InternetRequiredViewModel(coordinator: self)
		navigateToAppUpdate(with: viewModel)
	}
	
	/// Show the error alert when crypto library is not initialized
	private func showCryptoLibNotInitializedError() {
		
		let message = L.generalErrorCryptolibMessage("\(142)")
		
		let alertController = UIAlertController(
			title: L.generalErrorCryptolibTitle(),
			message: message,
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.generalErrorCryptolibRetry(),
				style: .cancel,
				handler: { [weak self] _ in
					self?.retry()
				}
			)
		)
		window.rootViewController?.present(alertController, animated: true)
	}

	/// Show an alert for the recommended update
	private func showRecommendedUpdate(updateURL: URL) {

		let alertController = UIAlertController(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.recommendedUpdateAppActionCancel(),
				style: .cancel,
				handler: nil
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: L.recommendedUpdateAppActionOk(),
				style: .default,
				handler: { [weak self] _ in
					self?.logDebug("Should implement update")
					self?.openUrl(updateURL)
					
				}
			)
		)
		window.rootViewController?.present(alertController, animated: true)
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
			case .redeemHolderToken,
				 .thirdPartyTicketApp:
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
			case .noActionNeeded, .withinTTL:
				startApplication()
				
			case .internetRequired:
				showInternetRequired()

			case let .actionRequired(remoteConfiguration):

				let requiredVersion = remoteConfiguration.minimumVersion.fullVersionString()
				let recommendedVersion = remoteConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
				let currentVersion = versionSupplier.getCurrentVersion().fullVersionString()

				if remoteConfiguration.isDeactivated {
					navigateToAppUpdate(
						with: EndOfLifeViewModel(
							coordinator: self,
							versionInformation: remoteConfiguration
						)
					)
				} else if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
					navigateToAppUpdate(
						with: AppUpdateViewModel(
							coordinator: self,
							versionInformation: remoteConfiguration
						)
					)
				} else if recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending {

					// Todo: 24 hour nag check.
					guard let updateURL = remoteConfiguration.appStoreURL else {
						startApplication()
						return
					}
					showRecommendedUpdate(updateURL: updateURL)
				} else {
					startApplication()
				}
			case .cryptoLibNotInitialized:
				showCryptoLibNotInitializedError()
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

public extension Notification.Name {

	static let disablePrivacySnapShot = Notification.Name("nl.rijksoverheid.ctr.disablePrivacySnapShot")
	static let enablePrivacySnapShot = Notification.Name("nl.rijksoverheid.ctr.enablePrivacySnapShot")
}

extension AppCoordinator {
	
	private enum Constants {
		static let privacyWindowAnimationDuration: TimeInterval = 0.15
	}

    /// Handle the event the application will resign active
	@objc func onWillResignActiveNotification() {

		guard shouldUsePrivacySnapShot else {
			return
		}
		
		/// Show the snapshot (logo) view to hide sensitive data
		if #available(iOS 13.0, *) {
			guard let windowScene = window.windowScene else {
				return
			}
			privacySnapshotWindow = UIWindow(windowScene: windowScene)
		} else {
			// Fallback on earlier versions
			privacySnapshotWindow = UIWindow(frame: UIScreen.main.bounds)
		}

		let shapshotViewController = SnapshotViewController(
			viewModel: SnapshotViewModel(
				versionSupplier: versionSupplier,
				flavor: AppFlavor.flavor
			)
		)
		privacySnapshotWindow?.rootViewController = shapshotViewController
		// Present window above alert controllers
		privacySnapshotWindow?.windowLevel = .alert + 1
		privacySnapshotWindow?.alpha = 0
		privacySnapshotWindow?.makeKeyAndVisible()
		UIView.animate(withDuration: Constants.privacyWindowAnimationDuration) {
			self.privacySnapshotWindow?.alpha = 1
		}
    }
	
	/// Handle the event the application did become active
	@objc func onDidBecomeActiveNotification() {
		
		// Hide when app becomes active
		UIView.animate(withDuration: Constants.privacyWindowAnimationDuration) {
			self.privacySnapshotWindow?.alpha = 0
		} completion: { _ in
			self.privacySnapshotWindow?.isHidden = true
			self.privacySnapshotWindow = nil
		}
	}

	@objc private func enablePrivacySnapShot() {
		shouldUsePrivacySnapShot = true
	}

	@objc private func disablePrivacySnapShot() {
		shouldUsePrivacySnapShot = false
	}

    private func addObservers() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onWillResignActiveNotification),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onDidBecomeActiveNotification),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(disablePrivacySnapShot),
			name: Notification.Name.disablePrivacySnapShot,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(enablePrivacySnapShot),
			name: Notification.Name.enablePrivacySnapShot,
			object: nil
		)
    }
}
