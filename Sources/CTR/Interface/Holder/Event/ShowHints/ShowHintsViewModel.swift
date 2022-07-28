/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class ShowHintsViewModel {
	
	weak var coordinator: (OpenUrlProtocol & EventCoordinatorDelegate)?

	// MARK: - Bindable

	@Bindable private(set) var title: String = "" // L.holder_eventHints_title()
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String = L.general_toMyOverview()

	// MARK: - Initializer

	init(hints: [String], coordinator: OpenUrlProtocol & EventCoordinatorDelegate) {

		self.coordinator = coordinator
		self.message = hints
			.map { "<p>\($0)</p>" }
			.joined(separator: "\n")
	}

	// MARK: - Methods

	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func navigateToDashboard() {
		
		coordinator?.showHintsScreenDidFinish(.stop)
	}
}
