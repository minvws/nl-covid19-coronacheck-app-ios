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
	private var didCheckCheckbox: Bool = false
	
	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var primaryButtonIcon: UIImage?
	@Bindable private(set) var checkboxTitle: String?
	
	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode

		switch eventMode {
			case .vaccinationassessment, .paperflow, .vaccinationAndPositiveTest:
				// this is not the start scene for this flow
				self.title = ""
				self.message = ""
				self.primaryButtonIcon = nil
				self.checkboxTitle = nil
			case .vaccination:
				self.title = L.holderVaccinationStartTitle()
				self.message = L.holderVaccinationStartMessage()
				self.primaryButtonIcon = I.digid()
			self.checkboxTitle = L.holder_addVaccine_alsoCollectPositiveTestResults_checkbox()
			case .recovery:
				self.title = L.holderRecoveryStartTitle()
				self.message = L.holderRecoveryStartMessage()
				self.primaryButtonIcon = I.digid()
				self.checkboxTitle = nil
			case .test:
				self.title = L.holder_negativetest_ggd_title()
				self.message = L.holder_negativetest_ggd_message()
				self.primaryButtonIcon = I.digid()
				self.checkboxTitle = nil
		}
	}

	func backButtonTapped() {
		
		coordinator?.eventStartScreenDidFinish(.back(eventMode: eventMode))
	}
	
	func backSwipe() {
		
		coordinator?.eventStartScreenDidFinish(.backSwipe)
	}

	func primaryButtonTapped() {

		coordinator?.eventStartScreenDidFinish(.continue(eventMode: didCheckCheckbox ? .vaccinationAndPositiveTest : eventMode))
	}
	
	func checkboxToggled(value: Bool) {
		
		didCheckCheckbox = value
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}
