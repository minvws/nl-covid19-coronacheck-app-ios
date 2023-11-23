/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI
import OpenIDConnect

protocol AppCoordinatorDelegate: AnyObject {
	
	func openUrl(_ url: URL, completionHandler: (() -> Void)?)
	
	func handleLaunchState(_ state: LaunchState)
	
	/// Retry loading the requirements
	func retry()
	
	func reset()
}

class AppCoordinator: Coordinator {
	
	let window: UIWindow
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController
	
	private var privacySnapshotWindow: UIWindow?
	
	var flavor = AppFlavor.flavor
	
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
		
		appIsPermanentlyDeactivated()
		addObservers()
	}
	
	func appIsPermanentlyDeactivated() {
		
		let urlString: String = flavor == .holder ? L.holder_deactivation_url() : L.verifier_deactivation_url()
		let destination = AppStatusViewController(viewModel: AppDeactivatedViewModel(
			coordinator: self,
			   informationUrl: URL(string: urlString),
			   flavor: flavor
		   ))
		
		// Set the root
		window.rootViewController = destination
		window.makeKeyAndVisible()
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

// MARK: - LaunchStateDelegate

extension AppCoordinator: LaunchStateManagerDelegate {
	
	func appIsDeactivated() {
		
	}
	
	func applicationShouldStart() {
		
	}
	
	func cryptoLibDidNotInitialize() {
	
	}
	
	func errorWhileLoading(_ errorTuples: [(error: ServerError, step: ErrorCode.Step)]) {

	}
	
	func updateIsRequired(appStoreUrl: URL) {

	}
	
	func updateIsRecommended(version: String, appStoreUrl: URL) {
		
	}
	
	func showPriorityNotification(_ notification: String) {
	
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
		
	}
	
	// MARK: - Retry -
	
	/// Retry loading the requirements
	func retry() {
	
	}
	
	func reset() {
		
		childCoordinators = []
		retry()
	}
}

extension AppCoordinator {
	
	private enum Constants {
		static let privacyWindowAnimationDuration: TimeInterval = 0.15
	}
	
	/// Handle the event the application will resign active
	@objc func onWillResignActiveNotification() {
		
		// Show the snapshot (logo) view to hide sensitive data
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
	
	private func addObservers() {
		
		// Back and foreground
		
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
	}
}
