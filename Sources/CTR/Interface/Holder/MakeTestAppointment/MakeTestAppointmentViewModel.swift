/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class MakeTestAppointmentViewModel: Logging {
	
	/// The coordinator to open Url
	weak var coordinator: OpenUrlProtocol?

	// MARK: - Bindable

	/// The title of the information page
	@Bindable private(set) var title: String

	/// The message of the information page
	@Bindable private(set) var message: String
	
	/// The title of the button
	@Bindable private(set) var buttonTitle: String

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: The coordinator to open Url
	///   - title: The title of the page
	///   - message: The message of the page
	///   - buttonTitle: The title of the button
	init(
		coordinator: OpenUrlProtocol,
		title: String,
		message: String,
		buttonTitle: String) {

		self.coordinator = coordinator
		self.title = title
		self.message = message
		self.buttonTitle = buttonTitle
	}

	// MARK: - Methods

	/// The user tapped on the button
	@objc func onTap() {

		// Notify the coordinator
		if let url = URL(string: L.holderUrlAppointment()) {
			coordinator?.openUrl(url, inApp: true)
		}
	}
}
