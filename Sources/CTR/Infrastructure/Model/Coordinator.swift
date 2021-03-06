/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

protocol Coordinator: AnyObject {

	/// The Child Coordinators
	var childCoordinators: [Coordinator] { get set }

	/// The navigation controller
	var navigationController: UINavigationController { get set }

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
}

// MARK: - Universal Links

extension Coordinator {

    /// Receives the universal link activity. Attempts to get any child coordinator
    /// to deal with it but, if they do not, will attempt for `self` to handle it.
    ///
    /// - Returns bool: true if `self` or a child has handled the activity.
    @discardableResult
    func receive(universalLink: UniversalLink) -> Bool {

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
