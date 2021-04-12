/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ForcedInformationCoordinator: Coordinator {

	/// The child coordinators
	var childCoordinators: [Coordinator] = []

	/// The navigation controller
	var navigationController: UINavigationController

	/// The forced information manager
	var forcedInformationManager: ForcedInformationManaging

	/// Initiatilzer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - forcedInformationManager: the forced information manager
	init(
		navigationController: UINavigationController,
		forcedInformationManager: ForcedInformationManaging) {

		self.navigationController = navigationController
		self.forcedInformationManager = forcedInformationManager
	}

	func start() {

	}
}
