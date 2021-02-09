/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum MenuIdentifier {

	case overview
	case settings
	case faq
	case about
	case feedback
}

struct MenuItem {

	let identifier: MenuIdentifier
	let title: String
}

class HolderMenuViewModel {

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var topMenu: [MenuItem]
	@Bindable private(set) var bottomMenu: [MenuItem]

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate

	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		self.topMenu = [
			MenuItem(identifier: .overview, title: .holderMenuDashboard),
			MenuItem(identifier: .settings, title: .holderMenuSettings)
		]
		self.bottomMenu = [
			MenuItem(identifier: .faq, title: .holderMenuFaq),
			MenuItem(identifier: .about, title: .holderMenuAbout),
			MenuItem(identifier: .feedback, title: .holderMenuFeedback)
		]
	}

	func menuItemClicked(_ identifier: MenuIdentifier) {

		coordinator?.openMenuItem(identifier)
	}

	/// Close the menu
	func clossButtonTapped() {

		coordinator?.closeMenu()
	}
}
