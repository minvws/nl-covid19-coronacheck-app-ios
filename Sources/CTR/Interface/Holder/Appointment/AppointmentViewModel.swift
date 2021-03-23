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

	/// The general configuration
	var generalConfiguration: ConfigurationGeneralProtocol

	/// The header image
	@Bindable private(set) var image: UIImage?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The header of the scene
	@Bindable private(set) var header: String

	/// The information body of the scene
	@Bindable private(set) var body: String

	/// The underlined and linked part of the body
	@Bindable private(set) var linkedBody: String

	/// The title on the button
	@Bindable private(set) var buttonTitle: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate

	init(coordinator: OpenUrlProtocol, maxValidity: String, configuration: ConfigurationGeneralProtocol) {

		self.coordinator = coordinator
		self.generalConfiguration = configuration

		self.title = .holderAppointmentTitle
		self.header = .holderAppointmentHeader
		self.body = String(format: .holderAppointmentBody, maxValidity)
		self.linkedBody = .holderAppointmentLink
		self.buttonTitle = .holderAppointmentButtonTitle
		self.image = UIImage.appointmentBig
	}

	/// The user wants more information
	func linkedTapped() {

		logInfo("Tapped on read more about test appointment")
		coordinator?.openUrl(generalConfiguration.getHolderFAQURL(), inApp: true)
	}

	/// The user wants to create an appointment
	func buttonTapped() {

		logInfo("Create appointment tapped")
		if let url = URL(string: "https://coronacheck.nl/nl/testaanbieders-fieldlab-in-de-app") {
			coordinator?.openUrl(url, inApp: true)
		}
	}
}
