/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class VisitorPassStartViewModel: Logging {
	
	/// The coordinator to open Url
	weak var coordinator: (OpenUrlProtocol & HolderCoordinatorDelegate)?

	// MARK: - Bindable

	/// The title of the information page
	@Bindable private(set) var title: String = L.visitorpass_start_title()

	/// The message of the information page
	@Bindable private(set) var message: String = L.visitorpass_start_message()
	
	/// The title of the button
	@Bindable private(set) var buttonTitle: String = L.visitorpass_start_action()

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: The coordinator to open Url
	///   - title: The title of the page
	///   - message: The message of the page
	///   - buttonTitle: The title of the button
	init(coordinator: OpenUrlProtocol & HolderCoordinatorDelegate) {

		self.coordinator = coordinator
	}

	// MARK: - Methods

	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func navigateToTokenEntry() {
		
	}
}
