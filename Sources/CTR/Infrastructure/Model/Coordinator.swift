/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI
import RestrictedBrowser

protocol Coordinator: AnyObject {
	
	/// The Child Coordinators
	var childCoordinators: [Coordinator] { get set }
	
	/// The navigation controller
	var navigationController: UINavigationController { get }
	
	// Designated starter method
	func start()
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
