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

	internal func originMismatchState(flow: ErrorCode.Flow) -> ListRemoteEventsViewController.State {
		
		let errorCode = ErrorCode(
			flow: flow,
			step: .signer,
			clientCode: .originMismatch
		)
		
		return feedbackWithDefaultPrimaryAction(
			title: L.holderEventOriginmismatchTitle(),
			subTitle: Strings.originsMismatchBody(errorCode: errorCode, forEventMode: eventMode),
			primaryActionTitle: L.general_toMyOverview()
		)
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
	
	internal func negativeTestInVaccinationAssessmentFlow() -> ListRemoteEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holder_event_negativeTestEndstate_addVaccinationAssessment_title(),
				body: L.holder_event_negativeTestEndstate_addVaccinationAssessment_body(),
				primaryActionTitle: L.holder_event_negativeTestEndstate_addVaccinationAssessment_button_complete(),
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.shouldCompleteVaccinationAssessment)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
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

	// MARK: international QR Only

	internal func internationalQROnly() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holder_listRemoteEvents_endStateInternationalQROnly_title(),
			subTitle: L.holder_listRemoteEvents_endStateInternationalQROnly_message(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	// MARK: Positive test end states

	internal func positiveTestFlowRecoveryAndVaccinationCreated() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_title(),
			subTitle: L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_message(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	internal func positiveTestFlowRecoveryAndInternationalVaccinationCreated() -> ListRemoteEventsViewController.State {
		
		return feedbackWithDefaultPrimaryAction(
			title: L.holder_listRemoteEvents_endStateInternationalVaccinationAndRecovery_title(),
			subTitle: L.holder_listRemoteEvents_endStateInternationalVaccinationAndRecovery_message(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}
	
	internal func positiveTestFlowInternationalVaccinationCreated() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holder_listRemoteEvents_endStateInternationalQROnly_title(),
			subTitle: L.holder_listRemoteEvents_endStateCombinedFlowInternationalQROnly_message(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	internal func positiveTestFlowRecoveryOnlyCreated() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holder_listRemoteEvents_endStateRecoveryOnly_title(),
			subTitle: L.holder_listRemoteEvents_endStateRecoveryOnly_message(),
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

	internal func recoveryFlowRecoveryAndVaccinationCreated() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderRecoveryRecoveryAndVaccinationTitle(),
			subTitle: L.holderRecoveryRecoveryAndVaccinationMessage(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	internal func recoveryFlowVaccinationOnly() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderRecoveryVaccinationOnlyTitle(),
			subTitle: L.holderRecoveryVaccinationOnlyMessage(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	internal func recoveryFlowPositiveTestTooOld() -> ListRemoteEventsViewController.State {
		
		return feedbackWithDefaultPrimaryAction(
			title: L.holder_listRemoteEvents_endStateRecoveryTooOld_title(),
			subTitle: L.holder_listRemoteEvents_endStateRecoveryTooOld_message(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}
}
