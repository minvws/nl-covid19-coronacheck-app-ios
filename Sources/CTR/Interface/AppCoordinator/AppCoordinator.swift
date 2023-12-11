/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI

protocol AppCoordinatorDelegate: AnyObject {
	
	func openUrl(_ url: URL, completionHandler: (() -> Void)?)
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
		
		cleanupExistingData()
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
	
	func cleanupExistingData() {
		
		// CoreData
		let fileManager: FileManager = FileManager.default
		if let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
			for fileName in ["CoronaCheck.sqlite", "CoronaCheck.sqlite-shm", "CoronaCheck.sqlite-wal"] {
				let fileUrl = applicationSupport.appendingPathComponent(fileName, isDirectory: false)
				if fileManager.fileExists(atPath: fileUrl.path) {
					do {
						try fileManager.removeItem(atPath: fileUrl.path)
					} catch {
						logError("Failed to read directory \(error)")
					}
				}
			}
		}
		
		// Configuration files
		let fileStorage = FileStorage()
		for fileName in ["config.json", "public_keys.json"] {
			if fileStorage.fileExists(fileName) {
				fileStorage.remove(fileName)
			}
		}
	}
}

// MARK: - AppCoordinatorDelegate

extension AppCoordinator: AppCoordinatorDelegate {
	
	func openUrl(_ url: URL, completionHandler: (() -> Void)? = nil) {
		
		UIApplication.shared.open(url, completionHandler: { _ in completionHandler?() })
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
