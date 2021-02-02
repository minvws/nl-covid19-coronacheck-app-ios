/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class MainViewModel {

	weak var coordinator: MainCoordinatorDelegate?

	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var secondaryButtonTitle: String

	init(coordinator: MainCoordinatorDelegate) {

		self.coordinator = coordinator
		primaryButtonTitle = .mainHolder
		secondaryButtonTitle = .mainVerifier
	}

	func primaryButtonTapped() {

		coordinator?.navigateToHolder()
	}

	func secondaryButtonTapped() {

		coordinator?.navigateToVerifier()
	}
}
