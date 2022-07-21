/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension ListRemoteEventsViewModel {
	
	// MARK: Helper
	
	private func feedbackWithDefaultPrimaryAction(title: String, subTitle: String, primaryActionTitle: String ) -> ListRemoteEventsViewController.State {

		return .feedback(
			content: Content(
				title: title,
				body: subTitle,
				primaryActionTitle: primaryActionTitle,
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				}
			)
		)
	}
	
	// MARK: Pending

	internal func pendingEventsState() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderTestresultsPendingTitle(),
			subTitle: L.holderTestresultsPendingText(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	// MARK: Empty States

	internal func emptyEventsState() -> ListRemoteEventsViewController.State {

		switch eventMode {
			case .vaccinationassessment: return emptyAssessmentState()
			case .paperflow: return emptyDccState()
			case .vaccinationAndPositiveTest, .vaccination: return emptyVaccinationState()
			case .recovery: return emptyRecoveryState()
			case .test: return emptyTestState()
		}
	}

	// MARK: Vaccination End State

	internal func emptyVaccinationState() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderVaccinationNolistTitle(),
			subTitle: L.holderVaccinationNolistMessage(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	// MARK: Negative Test End State

	internal func emptyTestState() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderTestNolistTitle(),
			subTitle: L.holderTestNolistMessage(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}
	
	// MARK: Assessment End State
	
	internal func emptyAssessmentState() -> ListRemoteEventsViewController.State {
		
		return feedbackWithDefaultPrimaryAction(
			title: L.holder_event_vaccination_assessment_nolist_title(),
			subTitle: L.holder_event_vaccination_assessment_nolist_message(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	// MARK: Paper Flow End State

	internal func emptyDccState() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderCheckdccExpiredTitle(),
			subTitle: L.holderCheckdccExpiredMessage(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	// MARK: Recovery end states

	internal func emptyRecoveryState() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderRecoveryNolistTitle(),
			subTitle: L.holderRecoveryNolistMessage(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}
}
