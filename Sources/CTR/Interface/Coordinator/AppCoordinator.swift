/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol AppCoordinatorDelegate: AnyObject {

	func openUrl(_ url: URL, completionHandler: (() -> Void)?)

    func handleLaunchState(_ state: LaunchState)

	/// Retry loading the requirements
	func retry()

	func reset()
}

class AppCoordinator: Coordinator, Logging {

	let window: UIWindow

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController
	
	private var privacySnapshotWindow: UIWindow?

	private var shouldUsePrivacySnapShot = true

	// Flag to prevent showing the recommended update dialog twice
	// which can happen with the config being fetched within the TTL.
	private var isPresentingRecommendedUpdate = false
	
	// Flag to prevent showing the recommended update dialog twice
	// which can happen with the config being fetched within the TTL.
	private var isPresentingCryptoLibError = false

	var versionSupplier: AppVersionSupplierProtocol = AppVersionSupplier()

	var flavor = AppFlavor.flavor
	
	var launchStateManager: LaunchStateManaging

	/// For use with iOS 13 and higher
	@available(iOS 13.0, *)
	init(scene: UIWindowScene, navigationController: UINavigationController) {

		window = UIWindow(windowScene: scene)
		self.navigationController = navigationController
		self.launchStateManager = LaunchStateManager()
		self.launchStateManager.delegate = self
	}

	/// For use with iOS 12.
	init(navigationController: UINavigationController) {

		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.navigationController = navigationController
		self.launchStateManager = LaunchStateManager()
		self.launchStateManager.delegate = self
	}
	
	/// Designated starter method
	func start() {

		guard !ProcessInfo.processInfo.isTesting else {
			return
		}
		
		if CommandLine.arguments.contains("-resetOnStart") {
			Current.wipePersistedData(flavor: AppFlavor.holder)
		}

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
                flavor: flavor
            )
        )
        // Set the root
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        navigationController.viewControllers = [destination]
    }

    /// Start the real application
    private func startApplication() {
		
		// Start listeners after launching is done (willEnterForegroundNotification will mess up launch)
		Current.remoteConfigManager.registerTriggers()
		Current.cryptoLibUtility.registerTriggers()

        switch flavor {
            case .holder:
                startAsHolder()
            default:
                startAsVerifier()
        }
    }

    /// Start the app as a holder
    private func startAsHolder() {

		guard childCoordinators.isEmpty else {
			if childCoordinators.first is HolderCoordinator {
				childCoordinators.first?.start()
			}
			return
		}

        let coordinator = HolderCoordinator(navigationController: navigationController, window: window)
        startChildCoordinator(coordinator)

        if let universalLink = self.unhandledUniversalLink {
           coordinator.receive(universalLink: universalLink)
        }
    }

    /// Start the app as a verifier
    private func startAsVerifier() {

		guard childCoordinators.isEmpty else {
			if childCoordinators.first is VerifierCoordinator {
				childCoordinators.first?.start()
			}
			return
		}

        let coordinator = VerifierCoordinator(navigationController: navigationController, window: window)
        startChildCoordinator(coordinator)

		if let universalLink = self.unhandledUniversalLink {
		   coordinator.receive(universalLink: universalLink)
		}
    }
	
	/// Show the Internet Required View
	private func showInternetRequired() {

		let viewModel = InternetRequiredViewModel(coordinator: self)
		navigateToAppUpdate(with: viewModel)
	}
	
	/// Show the error alert when crypto library is not initialized
	private func showCryptoLibNotInitializedError() {
		
		guard !isPresentingCryptoLibError else {
			return
		}
		
		isPresentingCryptoLibError = true

		let errorCode = ErrorCode(flow: .onboarding, step: .publicKeys, clientCode: .failedToLoadCryptoLibrary)
		let message = L.generalErrorCryptolibMessage("\(errorCode)")
		
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
					self?.isPresentingCryptoLibError = false
				}
			)
		)
		window.rootViewController?.present(alertController, animated: true)
	}

	/// Show an alert for the recommended update
	private func showRecommendedUpdate(updateURL: URL) {

		isPresentingRecommendedUpdate = true

		let alertController = UIAlertController(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.recommendedUpdateAppActionCancel(),
				style: .cancel,
				handler: { [weak self] _ in
					self?.isPresentingRecommendedUpdate = false
					self?.startApplication()
				}
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: L.recommendedUpdateAppActionOk(),
				style: .default,
				handler: { [weak self] _ in
					self?.openUrl(updateURL) {
						self?.isPresentingRecommendedUpdate = false
						self?.startApplication()
					}
				}
			)
		)
		window.rootViewController?.present(alertController, animated: true)
	}

	/// Show the Action Required View
	/// - Parameter versionInformation: the version information
	private func navigateToAppUpdate(with viewModel: AppStatusViewModel) {

		guard var topController = window.rootViewController else { return }

		while let newTopController = topController.presentedViewController {
			topController = newTopController
		}
		guard !(topController is AppStatusViewController) else { return }
		let updateController = AppStatusViewController(viewModel: viewModel)

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
				.redeemVaccinationAssessment,
				.thirdPartyTicketApp,
				.tvsAuth,
				.thirdPartyScannerApp:
				/// If we reach here it means that there was no holder/verifierCoordinator initialized at the time
				/// the universal link was received. So hold onto it here, for when it is ready.
				unhandledUniversalLink = universalLink
				return true
		}
	}
}

// MARK: - LaunchStateDelegate

extension AppCoordinator: LaunchStateManagerDelegate {
	
	func appIsDeactivated() {
		
		navigateToAppUpdate(
			with: EndOfLifeViewModel(
				coordinator: self,
				appStoreUrl: nil
			)
		)
	}
	
	func applicationShouldStart() {
		
		startApplication()
	}
	
	func cryptoLibDidNotInitialize() {
		
		showCryptoLibNotInitializedError()
	}
	
	func errorWhileLoading(errors: [ServerError]) {
		// For now, show internet required.
		// Todo: add error state.
		
		showInternetRequired()
	}
	
	func updateIsRequired(appStoreUrl: URL) {
		
		navigateToAppUpdate(
			with: AppStatusViewModel(
				coordinator: self,
				appStoreUrl: appStoreUrl
			)
		)
	}
	
	func updateIsRecommended(version: String, appStoreUrl: URL) {
		
		handleRecommendedUpdate(recommendedVersion: version, appStoreUrl: appStoreUrl)
	}
}

// MARK: - AppCoordinatorDelegate

extension AppCoordinator: AppCoordinatorDelegate {

	func openUrl(_ url: URL, completionHandler: (() -> Void)? = nil) {

		UIApplication.shared.open(url, completionHandler: { _ in completionHandler?() })
	}

    /// Handle the launch state
    /// - Parameter state: the launch state
    func handleLaunchState(_ state: LaunchState) {
		
		launchStateManager.handleLaunchState(state)
	}

	// MARK: - Recommended Update -

	private func handleRecommendedUpdate(recommendedVersion: String, appStoreUrl: URL) {

		guard !isPresentingRecommendedUpdate else {
			// Do not proceed if we are presenting the recommended update dialog.
			return
		}

		switch flavor {
			case .holder: handleRecommendedUpdateForHolder(
				recommendedVersion: recommendedVersion,
				appStoreUrl: appStoreUrl
			)
			case .verifier: handleRecommendedUpdateForVerifier(
				appStoreUrl: appStoreUrl
			)
		}
	}

	private func handleRecommendedUpdateForHolder(recommendedVersion: String, appStoreUrl: URL) {

		if let lastSeenRecommendedUpdate = Current.userSettings.lastSeenRecommendedUpdate,
		   lastSeenRecommendedUpdate == recommendedVersion {
			logDebug("The recommended version \(recommendedVersion) is the last seen version")
			startApplication()
		} else {
			// User has not seen a dialog for this recommended Version
			logDebug("The recommended version \(recommendedVersion) is not the last seen version")
			Current.userSettings.lastSeenRecommendedUpdate = recommendedVersion
			showRecommendedUpdate(updateURL: appStoreUrl)
		}
	}

	private func handleRecommendedUpdateForVerifier(appStoreUrl: URL) {

		let now = Date().timeIntervalSince1970
		let interval: Double = Double(Current.remoteConfigManager.storedConfiguration.recommendedNagIntervalHours ?? 24) * 3600
		let lastSeen: TimeInterval = Current.userSettings.lastRecommendUpdateDismissalTimestamp ?? now

		if lastSeen == now || lastSeen + interval < now {
			showRecommendedUpdate(updateURL: appStoreUrl)
			Current.userSettings.lastRecommendUpdateDismissalTimestamp = Date().timeIntervalSince1970
		} else {
			startApplication()
		}
	}

	// MARK: - Retry -
	
    /// Retry loading the requirements
    func retry() {

		launchStateManager.enableRestart()
		if let presentedViewController = navigationController.presentedViewController {
			presentedViewController.dismiss(animated: true) { [weak self] in
				self?.startLauncher()
			}
		} else {
			startLauncher()
		}
    }

	func reset() {
		
		childCoordinators = []
		retry()
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
				flavor: flavor
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

extension ErrorCode.ClientCode {

	static let failedToLoadCryptoLibrary = ErrorCode.ClientCode(value: "057")

}
