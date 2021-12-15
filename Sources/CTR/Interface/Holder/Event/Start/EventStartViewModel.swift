/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EventStartViewModel: Logging {

	// MARK: - Private variables

	weak private var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var eventMode: EventMode

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var primaryButtonIcon: UIImage?

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode

		switch eventMode {
			case .vaccination:
				self.title = L.holderVaccinationStartTitle()
				self.message = L.holderVaccinationStartMessage()
				self.primaryButtonIcon = I.digid()
			case .recovery:
				self.title = L.holderRecoveryStartTitle()
				self.message = L.holderRecoveryStartMessage()
				self.primaryButtonIcon = I.digid()
			case .paperflow:
				// Should be changed when we want test 3.0 to use this page. Skipped in the current flow.
				self.title = ""
				self.message = ""
				self.primaryButtonIcon = nil
			case .test:
				self.title = "A"
				self.message = "B"
				self.primaryButtonIcon = I.digid()
			case .positiveTest:
				self.title = L.holderPositiveTestStartTitle()
				self.message = L.holderPositiveTestStartMessage()
				self.primaryButtonIcon = I.digid()
		}
	}

	func backButtonTapped() {
		
		coordinator?.eventStartScreenDidFinish(.back(eventMode: eventMode))
	}
	
	func backSwipe() {
		
		coordinator?.eventStartScreenDidFinish(.backSwipe)
	}

	func primaryButtonTapped() {

		coordinator?.eventStartScreenDidFinish(.continue(eventMode: eventMode))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}
