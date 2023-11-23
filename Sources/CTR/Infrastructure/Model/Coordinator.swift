/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI
import SafariServices
import RestrictedBrowser

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
		
		return false
	}
}

// MARK: - OpenUrlProtocol

extension Coordinator {
	
	/// Open a url
	/// - Parameters:
	///   - url: The url to open
	func openUrl(_ url: URL) {
		
		var releaseAdjustedURL: URL? = url
		var allowedDomains: [String] = ["coronacheck.nl"]
		switch Configuration().getRelease() {
			case .production:
				break
			case .acceptance, .development:
				releaseAdjustedURL = URL(string: url.absoluteString
					.replacingOccurrences(of: "https://www.coronacheck.nl/", with: "https://web.acc.coronacheck.nl/")
					.replacingOccurrences(of: "https://coronacheck.nl/", with: "https://web.acc.coronacheck.nl/")
				)
				allowedDomains.append("web.acc.coronacheck.nl")
		}
		
		guard let releaseAdjustedURL else { return }
		let browser = RestrictedBrowser(
			navigationController: navigationController,
			title: "CoronaCheck",
			allowedDomains: allowedDomains
		)
		browser.openUrl(releaseAdjustedURL)
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
					self?.openUrl(url)
				}
			)
		)
		navigationController.pushViewController(viewController, animated: animated)
	}
}
