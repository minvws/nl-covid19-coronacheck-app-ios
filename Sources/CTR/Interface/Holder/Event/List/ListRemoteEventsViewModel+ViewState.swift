/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

typealias EventDataTuple = (identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)

extension ListRemoteEventsViewModel {

	func getViewState(from remoteEvents: [RemoteEvent]) -> ListRemoteEventsViewController.State {

		var event30DataSource = [EventDataTuple]()

		// If there is just one pending negative/positive test: Pending State.
		if remoteEvents.count == 1 &&
			remoteEvents.first?.wrapper.status == .pending &&
			(remoteEvents.first?.wrapper.events?.first?.negativeTest != nil || remoteEvents.first?.wrapper.events?.first?.positiveTest != nil) {
			return pendingEventsState()
		}

		for eventResponse in remoteEvents {
			if let identity = eventResponse.wrapper.identity,
			   let events30 = eventResponse.wrapper.events {
				for event in events30 where isEventAllowed(event) {
					event30DataSource.append(
						(
							identity: identity,
							event: event,
							providerIdentifier: eventResponse.wrapper.providerIdentifier
						)
					)
				}
			}
		}

		if event30DataSource.isEmpty {

			if let event = remoteEvents.first, event.wrapper.protocolVersion == "2.0" {
				// A test 2.0
				switch event.wrapper.status {
					case .complete:
						if let result = event.wrapper.result, result.negativeResult {
							return listTest20EventsState(event)
						}
					case .pending:
						return pendingEventsState()
					default:
						break
				}
			}
		} else {
			return listEventsState(event30DataSource)
		}

		return emptyEventsState()
	}

	/// Only allow certain events for the event mode
	/// - Parameter event: the event
	/// - Returns: True if allowed for this event flow
	private func isEventAllowed(_ event: EventFlow.Event) -> Bool {

		switch eventMode {
			case .vaccinationassessment: return event.hasVaccinationAssessment
			case .paperflow: return event.hasPaperCertificate
			case .vaccinationAndPositiveTest: return event.hasPositiveTest || event.hasVaccination || event.hasRecovery
			case .recovery: return event.hasPositiveTest || event.hasRecovery
			case .test: return event.hasNegativeTest
			case .vaccination: return event.hasVaccination
		}
	}

	internal func feedbackWithDefaultPrimaryAction(title: String, subTitle: String, primaryActionTitle: String ) -> ListRemoteEventsViewController.State {

		return .feedback(
			content: Content(
				title: title,
				body: subTitle,
				primaryActionTitle: primaryActionTitle,
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	// MARK: List State

	private func listEventsState(_ dataSource: [EventDataTuple]) -> ListRemoteEventsViewController.State {

		let rows = getSortedRowsFromEvents(dataSource)
		guard !rows.isEmpty else {
			return emptyEventsState()
		}

		return .listEvents(
			content: Content(
				title: Strings.title(forEventMode: eventMode),
				body: Strings.listMessage(forEventMode: eventMode),
				primaryActionTitle: eventMode != .paperflow ? L.holderVaccinationListAction() : L.holderDccListAction(),
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR()
				},
				// No secondary action for scanned paperflow, that is moved to the body of the details.
				secondaryActionTitle: eventMode != .paperflow ? L.holderVaccinationListWrong() : nil,
				secondaryAction: eventMode != .paperflow ? { [weak self] in
					guard let self = self else { return }
					guard let body = Strings.somethingIsWrongBody(forEventMode: self.eventMode) else { return }
					self.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: L.holder_listRemoteEvents_somethingWrong_title(),
							body: body,
							hideBodyForScreenCapture: false
						)
					)
				} : nil
			),
			rows: rows
		)
	}

	/// Filter all duplicate vaccination events (same provider, same hpkCode, same manufacturer, same date)
	/// - Parameter dataSource: the remote events
	/// - Returns: filtered events
	private func filterDuplicateVaccinationEvents(_ dataSource: [EventDataTuple]) -> [EventDataTuple] {

		var filteredDataSource = [EventDataTuple]()
		var counter = 0

		while counter <= dataSource.count - 1 {
			let currentRow = dataSource[counter]
			if counter < dataSource.count - 1,
			   let currentVaccinationEvent = currentRow.event.vaccination,
			   let nextVaccinationEvent = dataSource[counter + 1].event.vaccination {
				// Two vaccination rows, let's check for duplicates.
				let nextRow = dataSource[counter + 1]
				if currentVaccinationEvent.doesMatchEvent(nextVaccinationEvent) {
					if currentRow.providerIdentifier != nextRow.providerIdentifier {
						// Next row matches, but is not the same provider
						filteredDataSource.append(currentRow)
					}
				} else {
					// Next row does not match
					filteredDataSource.append(currentRow)
				}
			} else {
				// Next row or this row is not a vaccination
				filteredDataSource.append(currentRow)
			}
			counter += 1
		}
		return filteredDataSource
	}

	private func filterDuplicateTests(_ dataSource: [EventDataTuple]) -> [EventDataTuple] {

		var filteredDataSource = [EventDataTuple]()
		var uniqueIdentifiers: [String] = []
		filteredDataSource = dataSource.filter { tuple in
			guard let uniqueIdentifier = tuple.event.unique else {
				return true
			}
			guard tuple.event.hasNegativeTest || tuple.event.hasPositiveTest else {
				return true
			}
			guard !uniqueIdentifiers.contains(uniqueIdentifier) else {
				return false
			}
			uniqueIdentifiers.append(uniqueIdentifier)
			return true
		}
		return filteredDataSource
	}

	private func getSortedRowsFromEvents(_ dataSource: [EventDataTuple]) -> [ListRemoteEventsViewController.Row] {

		var sortedDataSource = dataSource.sorted { lhs, rhs in
			if let lhsDate = lhs.event.getSortDate(with: ListRemoteEventsViewModel.iso8601DateFormatter),
			   let rhsDate = rhs.event.getSortDate(with: ListRemoteEventsViewModel.iso8601DateFormatter) {

				if lhsDate == rhsDate {
					return lhs.providerIdentifier < rhs.providerIdentifier
				}
				return lhsDate > rhsDate
			}
			return false
		}

		sortedDataSource = filterDuplicateVaccinationEvents(sortedDataSource)
		sortedDataSource = filterDuplicateTests(sortedDataSource)

		var rows = [ListRemoteEventsViewController.Row]()
		var counter = 0

		while counter <= sortedDataSource.count - 1 {
			let currentRow = sortedDataSource[counter]

			if currentRow.event.hasRecovery {
				rows.append(getRowFromRecoveryEvent(dataRow: currentRow))
			} else if currentRow.event.hasVaccinationAssessment {
				rows.append(getRowFromAssessementEvent(dataRow: currentRow))
			} else if currentRow.event.hasPositiveTest {
				rows.append(getRowFromPositiveTestEvent(dataRow: currentRow))
			} else if currentRow.event.hasVaccination {

				if counter < sortedDataSource.count - 1,
				   let currentVaccinationEvent = currentRow.event.vaccination,
				   let nextVaccinationEvent = sortedDataSource[counter + 1].event.vaccination {
					let nextRow = sortedDataSource[counter + 1]

					if currentVaccinationEvent.doesMatchEvent(nextVaccinationEvent) {
						if currentRow.providerIdentifier != nextRow.providerIdentifier {
							logVerbose("Matching vaccinations, different provider. Skipping next row \(nextRow.providerIdentifier) \(nextRow.event.type) \(nextVaccinationEvent.dateString ?? "n/a")")
							rows.append(getRowFromVaccinationEvent(dataRow: currentRow, combineWith: nextRow))
							counter += 1
						}
					} else {
						logVerbose("not Matching vaccinations")
						rows.append(getRowFromVaccinationEvent(dataRow: currentRow))
					}
				} else {
					// Next row is not an vaccination
					logVerbose("nextRow is not a vaccination")
					rows.append(getRowFromVaccinationEvent(dataRow: currentRow))
				}
			} else if currentRow.event.hasNegativeTest {
				rows.append(getRowFromNegativeTestEvent(dataRow: currentRow))
			} else if currentRow.event.hasPaperCertificate {
				if let credentialData = currentRow.event.dccEvent?.credential.data(using: .utf8),
				   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
					if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
						rows.append(getRowFromDCCVaccinationEvent(dataRow: currentRow, vaccination: vaccination, isForeign: euCredentialAttributes.isForeignDCC))
					} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
						rows.append(getRowFromDCCRecoveryEvent(dataRow: currentRow, recovery: recovery, isForeign: euCredentialAttributes.isForeignDCC))
					} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
						rows.append(getRowFromDCCTestEvent(dataRow: currentRow, test: test, isForeign: euCredentialAttributes.isForeignDCC))
					}
				}
			}
			counter += 1
		}
		return rows
	}

	private func getRowFromNegativeTestEvent(dataRow: EventDataTuple) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printTestDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")

		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderEventAboutTitle(),
						details: NegativeTestDetailsGenerator.getDetails(identity: dataRow.identity, event: dataRow.event),
						footer: nil
					)
				)
			}
		)
	}

	private func getRowFromVaccinationEvent(dataRow: EventDataTuple, combineWith: EventDataTuple? = nil) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedShotMonth: String = dataRow.event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printMonthFormatter.string) ?? ""
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier

		var details = VaccinationDetailsGenerator.getDetails(
			identity: dataRow.identity,
			event: dataRow.event,
			providerIdentifier: dataRow.providerIdentifier
		)

		let title = L.holder_listRemoteEvents_listElement_vaccination_title("\(formattedShotMonth)")
		var listDetails: [String] = [
			L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
			L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
		]
		
		if let nextRow = combineWith {
			let otherProviderString: String = mappingManager.getProviderIdentifierMapping(nextRow.providerIdentifier) ?? nextRow.providerIdentifier
			listDetails.append(L.holder_listRemoteEvents_listElement_retrievedFrom_plural(provider, otherProviderString))
			details += [EventDetails(field: EventDetailsVaccination.separator, value: nil)]
			details += VaccinationDetailsGenerator.getDetails(
				identity: nextRow.identity,
				event: nextRow.event,
				providerIdentifier: nextRow.providerIdentifier
			)
		} else {
			listDetails.append(L.holder_listRemoteEvents_listElement_retrievedFrom_single(provider))
		}

		return ListRemoteEventsViewController.Row(
			title: title,
			details: listDetails,
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderEventAboutTitle(),
						details: details,
						footer: nil
					)
				)
			}
		)
	}

	private func getRowFromAssessementEvent(dataRow: EventDataTuple) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.vaccinationAssessment?.dateTimeString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printAssessmentDateFormatter.string) ?? (dataRow.event.vaccinationAssessment?.dateTimeString ?? "")

		return ListRemoteEventsViewController.Row(
			title: L.holder_event_vaccination_assessment_element_title(),
			details: [
				L.holder_listRemoteEvents_listElement_assessmentDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderEventAboutTitle(),
						details: VaccinationAssessementDetailsGenerator.getDetails(identity: dataRow.identity, event: dataRow.event),
						footer: nil
					)
				)
			}
		)
	}
	
	private func getRowFromRecoveryEvent(dataRow: EventDataTuple) -> ListRemoteEventsViewController.Row {
		
		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printTestDateYearFormatter.string) ?? (dataRow.event.recovery?.sampleDate ?? "")
		
		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderEventAboutTitle(),
						details: RecoveryDetailsGenerator.getDetails(identity: dataRow.identity, event: dataRow.event),
						footer: nil
					)
				)
			}
		)
	}

	private func getRowFromPositiveTestEvent(dataRow: EventDataTuple) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printTestDateYearFormatter.string) ?? (dataRow.event.positiveTest?.sampleDateString ?? "")

		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderEventAboutTitle(),
						details: PositiveTestDetailsGenerator.getDetails(identity: dataRow.identity, event: dataRow.event),
						footer: nil
					)
				)
			}
		)
	}

	private func getRowFromDCCVaccinationEvent(
		dataRow: EventDataTuple,
		vaccination: EuCredentialAttributes.Vaccination,
		isForeign: Bool) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")

		var title: String = L.general_vaccinationcertificate().capitalizingFirstLetter()
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			title = L.holderDccVaccinationListTitle("\(doseNumber)", "\(totalDose)")
		}

		return ListRemoteEventsViewController.Row(
			title: title,
			details: [
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderDccVaccinationDetailsTitle(),
						details: DCCVaccinationDetailsGenerator.getDetails(
							identity: dataRow.identity,
							vaccination: vaccination
						),
						footer: isForeign ? nil : L.holderDccVaccinationFooter()
					)
				)
			}
		)
	}

	private func getRowFromDCCRecoveryEvent(
		dataRow: EventDataTuple,
		recovery: EuCredentialAttributes.RecoveryEntry,
		isForeign: Bool) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")

		return ListRemoteEventsViewController.Row(
			title: L.general_recoverycertificate().capitalizingFirstLetter(),
			details: [
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderDccRecoveryDetailsTitle(),
						details: DCCRecoveryDetailsGenerator.getDetails(identity: dataRow.identity, recovery: recovery),
						footer: isForeign ? nil : L.holderDccRecoveryFooter()
					)
				)
			}
		)
	}

	private func getRowFromDCCTestEvent(
		dataRow: EventDataTuple,
		test: EuCredentialAttributes.TestEntry,
		isForeign: Bool) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")

		return ListRemoteEventsViewController.Row(
			title: L.general_testcertificate().capitalizingFirstLetter(),
			details: [
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderDccTestDetailsTitle(),
						details: DCCTestDetailsGenerator.getDetails(identity: dataRow.identity, test: test),
						footer: isForeign ? nil : L.holderDccTestFooter()
					)
				)
			}
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

// MARK: Test 2.0

private extension ListRemoteEventsViewModel {

	func pendingEventsState() -> ListRemoteEventsViewController.State {

		return feedbackWithDefaultPrimaryAction(
			title: L.holderTestresultsPendingTitle(),
			subTitle: L.holderTestresultsPendingText(),
			primaryActionTitle: L.general_toMyOverview()
		)
	}

	func listTest20EventsState(_ remoteEvent: RemoteEvent) -> ListRemoteEventsViewController.State {

		var rows = [ListRemoteEventsViewController.Row]()
		if let row = getTest20Row(remoteEvent) {
			rows.append(row)
		}

		return .listEvents(
			content: Content(
				title: L.holder_listRemoteEvents_title(),
				body: L.holderTestresultsResultsText(),
				primaryActionTitle: L.holderTestresultsResultsButton(),
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR()
				},
				secondaryActionTitle: L.holderVaccinationListWrong(),
				secondaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: L.holder_listRemoteEvents_somethingWrong_title(),
							body: L.holder_listRemoteEvents_somethingWrong_test_body(),
							hideBodyForScreenCapture: false
						)
					)
				}
			),
			rows: rows
		)
	}

	func getTest20Row(_ remoteEvent: RemoteEvent) -> ListRemoteEventsViewController.Row? {

		guard let result = remoteEvent.wrapper.result,
			  let sampleDate = Formatter.getDateFrom(dateString8601: result.sampleDate) else {
			return nil
		}

		let printSampleDate: String = ListRemoteEventsViewModel.printTestDateFormatter.string(from: sampleDate)
		let holderID = NegativeTestV2DetailsGenerator.getDisplayIdentity(result.holder)
		
		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(printSampleDate),
				L.holder_listRemoteEvents_listElement_yourDetails(holderID)
			],
			action: { [weak self] in
				
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderEventAboutTitle(),
						details: NegativeTestV2DetailsGenerator.getDetails(testResult: result),
						footer: nil
					)
				)
			}
		)
	}
}
