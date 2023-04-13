/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Resources

final class VisitorPassStartViewModel {
	
	/// The coordinator to open Url
	weak var coordinator: (OpenUrlProtocol & HolderCoordinatorDelegate)?

	// MARK: - Bindable

	/// The title of the information page
	@Bindable private(set) var title: String = L.visitorpass_start_title()

	/// The message of the information page
	@Bindable private(set) var message: String
	
	/// The title of the button
	@Bindable private(set) var buttonTitle: String = L.visitorpass_start_action()

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: The holder coordinator
	init(coordinator: OpenUrlProtocol & HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		message = L.visitorpass_start_message()
	}

	// MARK: - Methods

	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url)
	}
	
	func navigateToTokenEntry() {
		
		coordinator?.userWishesToCreateAVisitorPass()
	}
}
