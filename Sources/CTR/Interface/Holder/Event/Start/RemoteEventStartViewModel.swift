/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class RemoteEventStartViewModel: Logging {

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
			case .vaccinationassessment:
				// this is not the start scene for the assessment flow
				self.title = ""
				self.message = ""
				self.primaryButtonIcon = nil
			case .vaccination:
				self.title = L.holderVaccinationStartTitle()
				self.message = L.holderVaccinationStartMessage()
				self.primaryButtonIcon = I.digid()
			case .recovery:
				self.title = L.holderRecoveryStartTitle()
				self.message = L.holderRecoveryStartMessage()
				self.primaryButtonIcon = I.digid()
			case .paperflow:
				// this is not the start scene for the paper flow.
				self.title = ""
				self.message = ""
				self.primaryButtonIcon = nil
			case .test:
				self.title = L.holder_negativetest_ggd_title()
				self.message = L.holder_negativetest_ggd_message()
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
