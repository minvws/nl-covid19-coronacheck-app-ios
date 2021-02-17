/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class AboutViewModel {

	/// Dismissable Delegate
	weak var coordinator: OpenUrlProtocol?

	/// The configuration
	weak var configuration: ConfigurationGeneralProtocol?

	/// The title of the about page
	@Bindable private(set) var title: String

	/// The message of the about page
	@Bindable private(set) var message: String

	/// The link of the about page
	@Bindable private(set) var link: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - configuration: the configuration
	init(
		coordinator: OpenUrlProtocol,
		configuration: ConfigurationGeneralProtocol) {

		self.coordinator = coordinator
		self.configuration = configuration
		self.title = .holderAboutTitle
		self.message = .holderAboutText
		self.link = .holderAboutLink
	}

	/// The user clicked on the next button
	func linkTapped() {

		if let url = configuration?.getPrivacyPolicyURL() {
			coordinator?.openUrl(url, inApp: true)
		}
	}
}
