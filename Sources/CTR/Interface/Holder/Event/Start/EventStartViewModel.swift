/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class EventStartViewModel: Logging {

	// MARK: - Private variables

	weak private var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var eventMode: EventMode

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String

	init(coordinator: EventCoordinatorDelegate & OpenUrlProtocol, eventMode: EventMode) {

		self.coordinator = coordinator
		self.eventMode = eventMode

		self.title = .holderVaccinationStartTitle
		self.message = .holderVaccinationStartMessage
	}

	func backButtonTapped() {
		
		coordinator?.eventStartScreenDidFinish(.back(eventMode: eventMode))
	}

	func primaryButtonTapped() {

		coordinator?.eventStartScreenDidFinish(
			.continue(
				value: nil,
				eventMode: eventMode
			)
		)
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}
