/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppointmentViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "AppointmentViewModel"

	/// Coordination Delegate
	weak var coordinator: OpenUrlProtocol?

	/// The header image
	@Bindable private(set) var image: UIImage?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The information body of the scene
	@Bindable private(set) var body: String

	/// The underlined and linked part of the body
	@Bindable private(set) var linkedBody: String

	/// The title on the button
	@Bindable private(set) var buttonTitle: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate

	init(coordinator: OpenUrlProtocol) {

		self.coordinator = coordinator
		self.title = .holderAppointmentTitle
		self.body = .holderAppointmentBody
		self.linkedBody = .holderAppointmentLink
		self.buttonTitle = .holderAppointmentButtonTitle
		self.image = UIImage.appointment
	}

	/// The user wants more information
	func linkedClick() {

		logInfo("Clicked on read more about test appointment")
		if let url = URL(string: "https://www.rijksoverheid.nl/coronatest") {
			coordinator?.openUrl(url, inApp: false)
		}
	}

	/// The user wants to create an appointment
	func buttonClick() {

		logInfo("Create appointment clicked")
		if let url = URL(string: "https://coronatest.nl/") {
			coordinator?.openUrl(url, inApp: false)
		}
	}
}
