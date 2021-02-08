/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppointmentViewModel: Logging {

	var loggingCategory: String = "AppointmentViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var title: String
	@Bindable private(set) var body: String
	@Bindable private(set) var linkedBody: String
	@Bindable private(set) var buttonTitle: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate

	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		self.title = .holderAppointmentTitle
		self.body = .holderAppointmentBody
		self.linkedBody = .holderAppointmentLink
		self.buttonTitle = .holderAppointmentButtonTitle
		self.image = UIImage.appointment
	}

	func linkedClick() {

		logInfo("Clicked on read more about test appointment")
	}

	func buttonClick() {

		logInfo("Create appointment clicked")
	}
}
