/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Persistence
import Resources

class RemoteEventStartViewModel {

	// MARK: - Private variables

	weak private var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	internal var eventMode: EventMode
	private var didCheckCheckbox: Bool = false
	
	// MARK: - Bindable

	@Bindable private(set) var title: String?
	@Bindable private(set) var message: String?
	@Bindable private(set) var combineVaccinationAndPositiveTest: String?
	@Bindable private(set) var primaryButtonIcon: UIImage?
	@Bindable private(set) var checkboxTitle: String?
	
	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode

		switch eventMode {
			case .vaccination:
				setupForVaccination()
			case .recovery:
				setupForRecovery()
			case .test:
				setupForNegativeTest()
			default:
				// No setup, the other flows do not start with this scene
				return
		}
	}
	
	private func setupForVaccination() {
		
		self.title = L.holder_addVaccination_title()
		self.message = L.holder_addVaccination_message()
		self.primaryButtonIcon = I.digid()
		self.combineVaccinationAndPositiveTest = L.holder_addVaccination_alsoCollectPositiveTestResults_message()
		self.checkboxTitle = L.holder_addVaccine_alsoCollectPositiveTestResults_checkbox()
	}
	
	private func setupForRecovery() {
		
		self.title = L.holderRecoveryStartTitle()
		self.message = L.holderRecoveryStartMessage()
		self.primaryButtonIcon = I.digid()
	}
	
	private func setupForNegativeTest() {
		
		self.title = L.holder_negativetest_ggd_title()
		self.message = L.holder_negativetest_ggd_message()
		self.primaryButtonIcon = I.digid()
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
	
	func secondaryButtonTapped() {
		
		coordinator?.eventStartScreenDidFinish(.alternativeRoute(eventMode: didCheckCheckbox ? .vaccinationAndPositiveTest : eventMode))
	}
}
