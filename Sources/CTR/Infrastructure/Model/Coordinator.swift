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
