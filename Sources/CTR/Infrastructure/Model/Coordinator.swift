/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import SafariServices
import Shared
import ReusableViews

protocol Coordinator: AnyObject {
	
	/// The Child Coordinators
	var childCoordinators: [Coordinator] { get set }
	
	/// The navigation controller
	var navigationController: UINavigationController { get }
	
	// Designated starter method
	func start()
	
	/// Used for propagating a universal link to either the childCoordinators,
	///  or to be handled by `self`:
	@discardableResult
	func receive(universalLink: UniversalLink) -> Bool
	
	/// Actually handle the given universal link.
	///  Note: is only intended to be called by `self`, but must be defined in the `protocol`,
	///  because otherwise we can only call the protocol extension's stub implementation
	///  rather than any concrete implementation of `consume(universalLink:)`.
	func consume(universalLink: UniversalLink) -> Bool
}

extension Coordinator {
	
	/// Add a child coordinator
	/// - Parameter coordinator: the coordinator to add
	func addChildCoordinator(_ coordinator: Coordinator) {
		
		if !childCoordinators.contains(where: { $0 === coordinator }) {
			childCoordinators.append(coordinator)
		}
	}
	
	/// Remove a child coordinator
	/// - Parameter coordinator: the coordinator to remove
	func removeChildCoordinator(_ coordinator: Coordinator) {
		
		if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
			childCoordinators.remove(at: index)
		}
	}
	
	/// Add a child coordinator and start it.
	/// - Parameter coordinator: the coordinator to add and start
	func startChildCoordinator(_ coordinator: Coordinator) {
		
		addChildCoordinator(coordinator)
		coordinator.start()
	}
	
	func presentAsBottomSheet(_ viewController: UIViewController) {
		
		navigationController.visibleViewController?.presentBottomSheet(viewController)
	}
}

// MARK: - Universal Links

extension Coordinator {
	
	/// Receives the universal link activity. Attempts to get any child coordinator
	/// to deal with it but, if they do not, will attempt for `self` to handle it.
	///
	/// - Returns bool: true if `self` or a child has handled the activity.
	@discardableResult
	func receive(universalLink: UniversalLink) -> Bool {
		
		guard !Current.remoteConfigManager.storedConfiguration.isDeactivated else {
			return true
		}
		
		var handled = false
		
		// Find a child which will agree to handle the activity:
		for child in childCoordinators where child.receive(universalLink: universalLink) {
			handled = true
			break
		}
		
		// If a child coordinator handled the link, return true
		// else, maybe this coordinator would like to consume the universal link:
		return handled || consume(universalLink: universalLink)
	}
}

// MARK: - OpenUrlProtocol

extension Coordinator {
	
	/// Open a url
	/// - Parameters:
	///   - url: The url to open
	///   - inApp: True if we should open the url in a in-app browser, False if we want the OS to handle the url
	func openUrl(_ url: URL, inApp: Bool) {
		
		let shouldOpenInApp = {
			// Other URL schemes can't be opened in SFSafariViewController, - it doesn't work & will crash.
			guard url.scheme == "http" || url.scheme == "https" else {
				return false
			}
			return inApp
		}()
		
		guard #available(iOS 13.0, *), shouldOpenInApp else {
			UIApplication.shared.open(url)
			return
		}
		
		let safariController = SFSafariViewController(url: url)
		
		if let presentedViewController = navigationController.presentedViewController {
			presentedViewController.presentingViewController?.dismiss(animated: true) {
				self.navigationController.present(safariController, animated: true)
			}
		} else {
			navigationController.present(safariController, animated: true)
		}
	}
}

extension Coordinator {
	
	func presentContent(
		content: Content,
		backAction: (() -> Void)? = nil,
		allowsSwipeBack: Bool = false,
		animated: Bool = false) {
			
		let viewController = ContentViewController(
			viewModel: ContentViewModel(
				content: content,
				backAction: backAction,
				allowsSwipeBack: allowsSwipeBack,
				linkTapHander: { [weak self] url in
					self?.openUrl(url, inApp: true)
				}
			)
		)
		navigationController.pushViewController(viewController, animated: animated)
	}
}
