/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

/// The app follows a MVVM+C architecture, where (C)oordinators take on the task of managing flow between view controllers,
/// and supplying those controllers with the appropriate ViewModels.
/// To ensure coordinators stay retained they are added as a child to an array managed by the parent. The Coordinator class facilitates this mechanic.
/// Coordinators should inherit from this class.
///
/// Coordinators typically communicate to each other via delegates.
class Coordinator: NSObject {

    private(set) var children = [Coordinator]()

    /// Start the coordinator. Usually this presents or pushes the (initial) viewcontroller managed by the coordinator.
    func start() {

        preconditionFailure("Override start() in your subclass")
    }

	/// Add a child coordinator
	/// - Parameter coordinator: the coordinator to add
    func addChildCoordinator(_ coordinator: Coordinator) {

        if !children.contains(where: { $0 === coordinator }) {
            children.append(coordinator)
        }
    }

	/// Remove a child coordinator
	/// - Parameter coordinator: the coordinator to remove
    func removeChildCoordinator(_ coordinator: Coordinator) {

        if let index = children.firstIndex(where: { $0 === coordinator }) {
            children.remove(at: index)
        }
    }
}

extension Coordinator {

	/// Add a child coordinator and start it.
	/// - Parameter coordinator: the coordinator to add and start
    func startChildCoordinator(_ coordinator: Coordinator) {

        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
