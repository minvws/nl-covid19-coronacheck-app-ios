/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import ReusableViews
import Models
import Resources

typealias EventDataTuple = (identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)

extension ListRemoteEventsViewModel {

	func getViewState(from remoteEvents: [RemoteEvent]) -> ListRemoteEventsViewController.State {

		var eventDataSource = [EventDataTuple]()

		// If there is just one pending negative/positive test: Pending State.
		if remoteEvents.count == 1 &&
			remoteEvents.first?.wrapper.status == .pending &&
			(remoteEvents.first?.wrapper.events?.first?.negativeTest != nil || remoteEvents.first?.wrapper.events?.first?.positiveTest != nil) {
			return pendingEventsState()
		}

		for eventResponse in remoteEvents {
			if let events = eventResponse.wrapper.events {
				for event in events where isEventAllowed(event) {
					if let identity = eventResponse.wrapper.identity {
						eventDataSource.append(
							(
								identity: identity,
								event: event,
								providerIdentifier: eventResponse.wrapper.providerIdentifier
							)
						)
					}
				}
			}
		}

		if eventDataSource.isNotEmpty {
			return listEventsState(eventDataSource)
		}

		return emptyEventsState()
	}

	/// Only allow certain events for the event mode
	/// - Parameter event: the event
	/// - Returns: True if allowed for this event flow
	private func isEventAllowed(_ event: EventFlow.Event) -> Bool {

		switch eventMode {
			case .paperflow: return event.hasPaperCertificate
			case .vaccinationAndPositiveTest: return event.hasPositiveTest || event.hasVaccination || event.hasRecovery
			case .recovery: return event.hasPositiveTest || event.hasRecovery
			case .test: return event.hasNegativeTest
			case .vaccination: return event.hasVaccination
		}
	}

	// MARK: List State

	private func listEventsState(_ dataSource: [EventDataTuple]) -> ListRemoteEventsViewController.State {

		let rows = getSortedRowsFromEvents(dataSource)
		guard !rows.isEmpty else {
			return emptyEventsState()
		}
		// No secondary action for scanned paperflow, that is moved to the body of the details.
		let secondaryActionTitle: String? = {
			guard !(eventMode == .paperflow) else { return nil }
			return L.holderVaccinationListWrong()
		}()

		return .listEvents(
			content: Content(
				title: Strings.title(forEventMode: eventMode),
				body: Strings.listMessage(forEventMode: eventMode),
				primaryActionTitle: Strings.actionTitle(forEventMode: eventMode),
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR()
				},

				secondaryActionTitle: secondaryActionTitle,
				secondaryAction: secondaryActionTitle != nil ? { [weak self] in
					guard let self else { return }
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
			if let lhsDate = lhs.event.getSortDate(with: DateFormatter.Event.iso8601),
			   let rhsDate = rhs.event.getSortDate(with: DateFormatter.Event.iso8601) {

				if lhsDate == rhsDate {
					return lhs.providerIdentifier < rhs.providerIdentifier
				}
				return lhsDate > rhsDate
			}
			return false
		}

		sortedDataSource = filterDuplicateVaccinationEvents(sortedDataSource)
		sortedDataSource = filterDuplicateTests(sortedDataSource)

		var combinedEventsThatMustBeSkipped = [EventFlow.Event]()
		var rows = [ListRemoteEventsViewController.Row]()

		sortedDataSource.forEach { currentRow in
			
			if currentRow.event.hasRecovery {
				rows.append(getRowFromRecoveryEvent(dataRow: currentRow))
			} else if currentRow.event.hasPositiveTest {
				rows.append(getRowFromPositiveTestEvent(dataRow: currentRow))
			} else if currentRow.event.hasVaccination {
				// is the event already been used?
				if !combinedEventsThatMustBeSkipped.contains(currentRow.event),
				   let vaccination = currentRow.event.vaccination {
					var similarTuples = [EventDataTuple]()
					// loop over all events to find similar vaccinations
					dataSource
						.filter { $0.event.hasVaccination }
						.forEach { tuple in
						if let tupleVaccination = tuple.event.vaccination,
						   // if the vaccinations are similar (same HPKCode, same date, same manufacturer)
						   vaccination.doesMatchEvent(tupleVaccination),
						   // exclude ourself.
						   currentRow.providerIdentifier != tuple.providerIdentifier {
							combinedEventsThatMustBeSkipped.append(tuple.event)
							similarTuples.append(tuple)
						}
					}
					rows.append(getRowFromVaccinationEvent(dataRow: currentRow, combineWith: similarTuples))
				}

			} else if currentRow.event.hasNegativeTest {
				rows.append(getRowFromNegativeTestEvent(dataRow: currentRow))
			} else if currentRow.event.hasPaperCertificate {
				if let credentialData = currentRow.event.dccEvent?.credential.data(using: .utf8),
				   let isForeignDcc = cryptoManager?.isForeignDCC(credentialData),
				   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
					if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
						rows.append(getRowFromDCCVaccinationEvent(dataRow: currentRow, vaccination: vaccination, isForeign: isForeignDcc))
					} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
						rows.append(getRowFromDCCRecoveryEvent(dataRow: currentRow, recovery: recovery, isForeign: isForeignDcc))
					} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
						rows.append(getRowFromDCCTestEvent(dataRow: currentRow, test: test, isForeign: isForeignDcc))
					}
				}
			}
		}
		return rows
	}

	private func getRowFromNegativeTestEvent(dataRow: EventDataTuple) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayNameDayNumericMonthYearWithTime.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier
		
		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate),
				L.holder_listRemoteEvents_listElement_retrievedFrom_single(provider)
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

	private func getRowFromVaccinationEvent(dataRow: EventDataTuple, combineWith otherEventTuples: [EventDataTuple] = []) -> ListRemoteEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedShotDate: String = dataRow.event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.event.vaccination?.dateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier
		
		var details = VaccinationDetailsGenerator.getDetails(
			identity: dataRow.identity,
			event: dataRow.event,
			providerIdentifier: dataRow.providerIdentifier
		)

		let title = L.holder_listRemoteEvents_listElement_title_vaccination()
		var listDetails: [String] = [
			L.holder_listRemoteEvents_listElement_vaccinationDate(formattedShotDate),
			L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
			L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
		]
		
		var retrievedFrom = L.holder_listRemoteEvents_listElement_retrievedFrom_single(provider)
		if otherEventTuples.isNotEmpty {
			otherEventTuples.forEach { otherEventTuple in
				// Data retrieved from provider A and otherProvider B (and....)
				let otherProviderString: String = mappingManager.getProviderIdentifierMapping(otherEventTuple.providerIdentifier) ?? otherEventTuple.providerIdentifier
				retrievedFrom += " \(L.general_and()) \(otherProviderString)"
				// Event data for the detail view
				details += [EventDetails(field: EventDetailsVaccination.separator, value: nil)]
				details += VaccinationDetailsGenerator.getDetails(
					identity: otherEventTuple.identity,
					event: otherEventTuple.event,
					providerIdentifier: otherEventTuple.providerIdentifier
				)
			}
		}
		listDetails.append(retrievedFrom)
		
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
	
	private func getRowFromRecoveryEvent(dataRow: EventDataTuple) -> ListRemoteEventsViewController.Row {
		
		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayNameDayNumericMonthYearWithTime.string) ?? (dataRow.event.recovery?.sampleDate ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier
		
		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate),
				L.holder_listRemoteEvents_listElement_retrievedFrom_single(provider)
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
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayNameDayNumericMonthYearWithTime.string) ?? (dataRow.event.positiveTest?.sampleDateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier
		
		return ListRemoteEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate),
				L.holder_listRemoteEvents_listElement_retrievedFrom_single(provider)
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
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
			
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(DateFormatter.Format.dayMonthYear.string) ?? vaccination.dateOfVaccination

		var title: String = L.general_vaccinationcertificate().capitalizingFirstLetter()
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			title = L.holderDccVaccinationListTitle("\(doseNumber)", "\(totalDose)")
		}

		return ListRemoteEventsViewController.Row(
			title: title,
			details: [
				L.holder_listRemoteEvents_listElement_vaccinationDate(formattedVaccinationDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderDccVaccinationDetailsTitle(),
						details: DCCVaccinationDetailsGenerator.getDetails(identity: dataRow.identity, vaccination: vaccination),
						footer: isForeign ? L.holder_listRemoteEvents_somethingWrong_foreignDCC_body() : L.holderDccVaccinationFooter()
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
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
			
		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(DateFormatter.Format.dayMonthYear.string) ?? recovery.firstPositiveTestDate

		return ListRemoteEventsViewController.Row(
			title: L.general_recoverycertificate().capitalizingFirstLetter(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderDccRecoveryDetailsTitle(),
						details: DCCRecoveryDetailsGenerator.getDetails(identity: dataRow.identity, recovery: recovery),
						footer: isForeign ? L.holder_listRemoteEvents_somethingWrong_foreignDCC_body() : L.holderDccRecoveryFooter()
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
			.map(DateFormatter.Format.dayMonthYear.string) ?? (dataRow.identity.birthDateString ?? "")
			
		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(DateFormatter.Format.dayNameDayNumericMonthYearWithTime.string) ?? test.sampleDate

		return ListRemoteEventsViewController.Row(
			title: L.general_testcertificate().capitalizingFirstLetter(),
			details: [
				L.holder_listRemoteEvents_listElement_testDate(formattedTestDate),
				L.holder_listRemoteEvents_listElement_name(dataRow.identity.fullName),
				L.holder_listRemoteEvents_listElement_birthDate(formattedBirthDate)
			],
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(
						title: L.holderDccTestDetailsTitle(),
						details: DCCTestDetailsGenerator.getDetails(identity: dataRow.identity, test: test),
						footer: isForeign ? L.holder_listRemoteEvents_somethingWrong_foreignDCC_body() : L.holderDccTestFooter()
					)
				)
			}
		)
	}
}
