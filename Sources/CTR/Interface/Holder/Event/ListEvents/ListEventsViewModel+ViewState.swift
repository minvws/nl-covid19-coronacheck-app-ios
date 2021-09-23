/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length

import Foundation

typealias EventDataTuple = (identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)

extension ListEventsViewModel {

	func getViewState(from remoteEvents: [RemoteEvent]) -> ListEventsViewController.State {

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
				for event in events30 {
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
			return listEventsState(event30DataSource, remoteEvents: remoteEvents)
		}

		return emptyEventsState()
	}

	// MARK: Empty State

	private func emptyEventsState() -> ListEventsViewController.State {

		switch eventMode {
			case .recovery:
				return emptyRecoveryState()
			case .test:
				return emptyTestState()
			case .vaccination:
				return emptyVaccinationState()
			case .paperflow:
				return emptyDccState()
		}
	}

	private func emptyVaccinationState() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderVaccinationNolistTitle(),
				subTitle: L.holderVaccinationNolistMessage(),
				primaryActionTitle: L.holderVaccinationNolistAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func emptyTestState() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderTestNolistTitle(),
				subTitle: L.holderTestNolistMessage(),
				primaryActionTitle: L.holderTestNolistAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func emptyDccState() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderCheckdccExpiredTitle(),
				subTitle: L.holderCheckdccExpiredMessage(),
				primaryActionTitle: L.holderCheckdccExpiredActionTitle(),
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func emptyRecoveryState() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderRecoveryNolistTitle(),
				subTitle: L.holderRecoveryNolistMessage(),
				primaryActionTitle: L.holderRecoveryNolistAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func recoveryEventsTooOld() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderRecoveryTooOldTitle(),
				subTitle: L.holderRecoveryTooOldMessage(),
				primaryActionTitle: L.holderTestNolistAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	internal func cannotCreateEventsState() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderEventOriginmismatchTitle(),
				subTitle: Strings.originsMismatchBody(forEventMode: eventMode),
				primaryActionTitle: eventMode == .vaccination ? L.holderVaccinationNolistAction() : L.holderTestNolistAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	// MARK: List State

	private func listEventsState(
		_ dataSource: [EventDataTuple],
		remoteEvents: [RemoteEvent]) -> ListEventsViewController.State {

		var dataSource = dataSource
		if eventMode == .recovery {

			let recoveryExpirationDays = remoteConfigManager.getConfiguration().recoveryExpirationDays ?? 180
			let result = filterTooOldRecoveryEvents(dataSource, recoveryEventExpirationDays: recoveryExpirationDays)
			if result.hasTooOldEvents && result.filteredDataSource.isEmpty {
				return recoveryEventsTooOld()
			} else {
				dataSource = result.filteredDataSource
			}
		}

		let rows = getSortedRowsFromEvents(dataSource)
		guard !rows.isEmpty else {
			return emptyEventsState()
		}

		return .listEvents(
			content: Content(
				title: EventStrings.title(forEventMode: eventMode),
				subTitle: Strings.text(forEventMode: eventMode),
				primaryActionTitle: L.holderVaccinationListAction(),
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
						if !success {
							self?.showEventError(remoteEvents: remoteEvents)
						}
					}
				},
				secondaryActionTitle: L.holderVaccinationListWrong(),
				secondaryAction: { [weak self] in
					guard let self = self else { return }
					self.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: L.holderVaccinationWrongTitle(),
							body: Strings.somethingIsWrongBody(forEventMode: self.eventMode, dataSource: dataSource),
							hideBodyForScreenCapture: false
						)
					)
				}
			),
			rows: rows
		)
	}

	/// Filter out all recovery / positive tests that are older than 180 days (config recoveryEventValidity)
	/// - Parameter dataSource: the complete data source
	/// - Returns: the filtered data source
	private func filterTooOldRecoveryEvents(
		_ dataSource: [EventDataTuple],
		recoveryEventExpirationDays: Int) -> (filteredDataSource: [EventDataTuple], hasTooOldEvents: Bool) {

		let now = Date()

		let filteredSource = dataSource.filter { dataRow in
			if let sampleDate = dataRow.event.positiveTest?.getDate(with: dateFormatter),
			   let validUntil = Calendar.current.date(byAdding: .day, value: recoveryEventExpirationDays, to: sampleDate) {
				return validUntil > now

			} else if let validUntilString = dataRow.event.recovery?.validUntil,
					  let validUntilDate = dateFormatter.date(from: validUntilString) {
				return validUntilDate > now
			}
			return false
		}
		return (filteredDataSource: filteredSource, hasTooOldEvents: filteredSource.count != dataSource.count)
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

	private func getSortedRowsFromEvents(_ dataSource: [EventDataTuple]) -> [ListEventsViewController.Row] {

		var sortedDataSource = dataSource.sorted { lhs, rhs in
			if let lhsDate = lhs.event.getSortDate(with: dateFormatter),
			   let rhsDate = rhs.event.getSortDate(with: dateFormatter) {

				if lhsDate == rhsDate {
					return lhs.providerIdentifier < rhs.providerIdentifier
				}
				return lhsDate < rhsDate
			}
			return false
		}

		sortedDataSource = filterDuplicateVaccinationEvents(sortedDataSource)

		var rows = [ListEventsViewController.Row]()
		var counter = 0

		while counter <= sortedDataSource.count - 1 {
			let currentRow = sortedDataSource[counter]

			if currentRow.event.recovery != nil {
				rows.append(getRowFromRecoveryEvent(dataRow: currentRow))
			} else if currentRow.event.positiveTest != nil {
				rows.append(getRowFromPositiveTestEvent(dataRow: currentRow))
			} else if currentRow.event.vaccination != nil {

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
			} else if currentRow.event.negativeTest != nil {
				rows.append(getRowFromNegativeTestEvent(dataRow: currentRow))
			} else if currentRow.event.dccEvent != nil {
				if let credentialData = currentRow.event.dccEvent?.credential.data(using: .utf8),
				   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
					if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
						rows.append(getRowFromDCCVaccinationEvent(dataRow: currentRow, vaccination: vaccination))
					} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
						rows.append(getRowFromDCCRecoveryEvent(dataRow: currentRow, recovery: recovery))
					} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
						rows.append(getRowFromDCCTestEvent(dataRow: currentRow, test: test))
					}
				}
			}
			counter += 1
		}
		return rows
	}

	private func getRowFromNegativeTestEvent(dataRow: EventDataTuple) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(printTestDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")
		let formattedTestLongDate: String = dataRow.event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(printTestDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")

		let testType = remoteConfigManager.getConfiguration().getTestTypeMapping(
			dataRow.event.negativeTest?.type) ?? (dataRow.event.negativeTest?.type ?? "")
		let manufacturer = remoteConfigManager.getConfiguration().getTestManufacturerMapping(
			dataRow.event.negativeTest?.manufacturer) ?? (dataRow.event.negativeTest?.manufacturer ?? "")
		
		let details: [EventDetails] = [
			EventDetails(field: EventDetailsTest.subtitle, value: nil),
			EventDetails(field: EventDetailsTest.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsTest.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsTest.testType, value: testType),
			EventDetails(field: EventDetailsTest.testName, value: dataRow.event.negativeTest?.name),
			EventDetails(field: EventDetailsTest.date, value: formattedTestLongDate),
			EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestNegative()),
			EventDetails(field: EventDetailsTest.facility, value: dataRow.event.negativeTest?.facility),
			EventDetails(field: EventDetailsTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsTest.uniqueIdentifer, value: dataRow.event.unique)
		]

		return ListEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	private func getRowFromVaccinationEvent(dataRow: EventDataTuple, combineWith: EventDataTuple? = nil) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedShotMonth: String = dataRow.event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(printMonthFormatter.string) ?? ""
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier

		var details = getEventDetail(dataRow: dataRow)

		let title = L.holderVaccinationElementTitle("\(formattedShotMonth)")
		var subTitle = L.holderVaccinationElementSubtitle(dataRow.identity.fullName, formattedBirthDate)
		if let nextRow = combineWith {
			let otherProviderString: String = mappingManager.getProviderIdentifierMapping(nextRow.providerIdentifier) ?? nextRow.providerIdentifier
			subTitle += L.holderVaccinationElementCombined(provider, otherProviderString)
			details += [EventDetails(field: EventDetailsVaccination.separator, value: nil)]
			details += getEventDetail(dataRow: nextRow)
		} else {
			subTitle += L.holderVaccinationElementSingle(provider)
		}

		return ListEventsViewController.Row(
			title: title,
			subTitle: subTitle,
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	private func getEventDetail(dataRow: EventDataTuple) -> [EventDetails] {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedShotDate: String = dataRow.event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.event.vaccination?.dateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(dataRow.providerIdentifier) ?? dataRow.providerIdentifier

		var vaccinName: String?
		var vaccineType: String?
		var vaccineManufacturer: String?
		if let hpkCode = dataRow.event.vaccination?.hpkCode, !hpkCode.isEmpty {
			let hpkData = remoteConfigManager.getConfiguration().getHpkData(hpkCode)
			vaccinName = remoteConfigManager.getConfiguration().getBrandMapping(hpkData?.mp)
			vaccineType = remoteConfigManager.getConfiguration().getTypeMapping(hpkData?.vp)
			vaccineManufacturer = remoteConfigManager.getConfiguration().getVaccinationManufacturerMapping(hpkData?.ma)
		}

		if vaccinName == nil, let brand = dataRow.event.vaccination?.brand {
			vaccinName = remoteConfigManager.getConfiguration().getBrandMapping(brand)
		}
		if vaccineType == nil {
			vaccineType = remoteConfigManager.getConfiguration()
				.getTypeMapping(dataRow.event.vaccination?.type)
				?? dataRow.event.vaccination?.type
		}
		if vaccineManufacturer == nil {
			vaccineManufacturer = remoteConfigManager.getConfiguration()
				.getVaccinationManufacturerMapping(dataRow.event.vaccination?.manufacturer)
				?? dataRow.event.vaccination?.manufacturer
		}

		var dosage: String?
		if let doseNumber = dataRow.event.vaccination?.doseNumber,
		   let totalDose = dataRow.event.vaccination?.totalDoses {
			dosage = L.holderVaccinationAboutOff("\(doseNumber)", "\(totalDose)")
		}

		let country = getDisplayCountry(dataRow.event.vaccination?.country ?? "")

		let details: [EventDetails] = [
			EventDetails(field: EventDetailsVaccination.subtitle(provider: provider), value: nil),
			EventDetails(field: EventDetailsVaccination.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsVaccination.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsVaccination.pathogen, value: L.holderEventAboutVaccinationPathogenvalue()),
			EventDetails(field: EventDetailsVaccination.vaccineBrand, value: vaccinName),
			EventDetails(field: EventDetailsVaccination.vaccineType, value: vaccineType),
			EventDetails(field: EventDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer),
			EventDetails(field: EventDetailsVaccination.dosage, value: dosage),
			EventDetails(field: EventDetailsVaccination.completionReason, value: dataRow.event.vaccination?.completionStatus),
			EventDetails(field: EventDetailsVaccination.date, value: formattedShotDate),
			EventDetails(field: EventDetailsVaccination.country, value: country),
			EventDetails(field: EventDetailsVaccination.uniqueIdentifer, value: dataRow.event.unique)
		]

		return details
	}

	private func getRowFromRecoveryEvent(dataRow: EventDataTuple) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(printTestDateFormatter.string) ?? (dataRow.event.recovery?.sampleDate ?? "")
		let formattedShortTestDate: String = dataRow.event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.event.recovery?.sampleDate ?? "")
		let formattedShortValidFromDate: String = dataRow.event.recovery?.validFrom
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.event.recovery?.validFrom ?? "")
		let formattedShortValidUntilDate: String = dataRow.event.recovery?.validUntil
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.event.recovery?.validUntil ?? "")
		
		let details: [EventDetails] = [
			EventDetails(field: EventDetailsRecovery.subtitle, value: nil),
			EventDetails(field: EventDetailsRecovery.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsRecovery.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsRecovery.date, value: formattedShortTestDate),
			EventDetails(field: EventDetailsRecovery.validFrom, value: formattedShortValidFromDate),
			EventDetails(field: EventDetailsRecovery.validUntil, value: formattedShortValidUntilDate),
			EventDetails(field: EventDetailsRecovery.uniqueIdentifer, value: dataRow.event.unique)
		]

		return ListEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	private func getRowFromPositiveTestEvent(dataRow: EventDataTuple) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = dataRow.event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(printTestDateFormatter.string) ?? (dataRow.event.positiveTest?.sampleDateString ?? "")
		let formattedTestLongDate: String = dataRow.event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(printTestDateFormatter.string) ?? (dataRow.event.positiveTest?.sampleDateString ?? "")

		let testType = remoteConfigManager.getConfiguration().getTestTypeMapping(
			dataRow.event.positiveTest?.type) ?? (dataRow.event.positiveTest?.type ?? "")
		let manufacturer = remoteConfigManager.getConfiguration().getTestManufacturerMapping(
			dataRow.event.positiveTest?.manufacturer) ?? (dataRow.event.positiveTest?.manufacturer ?? "")
		
		let details: [EventDetails] = [
			EventDetails(field: EventDetailsTest.subtitle, value: nil),
			EventDetails(field: EventDetailsTest.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsTest.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsTest.testType, value: testType),
			EventDetails(field: EventDetailsTest.testName, value: dataRow.event.positiveTest?.name),
			EventDetails(field: EventDetailsTest.date, value: formattedTestLongDate),
			EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestPostive()),
			EventDetails(field: EventDetailsTest.facility, value: dataRow.event.positiveTest?.facility),
			EventDetails(field: EventDetailsTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsTest.uniqueIdentifer, value: dataRow.event.unique)
		]

		return ListEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	private func getRowFromDCCVaccinationEvent(
		dataRow: EventDataTuple,
		vaccination: EuCredentialAttributes.Vaccination) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")

		var dosage: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = L.holderVaccinationAboutOff("\(doseNumber)", "\(totalDose)")
		}

		let vaccineType = remoteConfigManager.getConfiguration().getTypeMapping(
			vaccination.vaccineOrProphylaxis) ?? vaccination.vaccineOrProphylaxis
		let vaccineBrand = remoteConfigManager.getConfiguration().getBrandMapping(
			vaccination.medicalProduct) ?? vaccination.medicalProduct
		let vaccineManufacturer = remoteConfigManager.getConfiguration().getVaccinationManufacturerMapping(
			vaccination.marketingAuthorizationHolder) ?? vaccination.marketingAuthorizationHolder
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(printDateFormatter.string) ?? vaccination.dateOfVaccination
		
		let issuer = getDisplayIssuer(vaccination.issuer)
		let country = getDisplayCountry(vaccination.country)
		
		let details: [EventDetails] = [
			EventDetails(field: EventDetailsDCCVaccination.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCVaccination.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsDCCVaccination.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCVaccination.pathogen, value: L.holderDccVaccinationPathogenvalue()),
			EventDetails(field: EventDetailsDCCVaccination.vaccineBrand, value: vaccineBrand),
			EventDetails(field: EventDetailsDCCVaccination.vaccineType, value: vaccineType),
			EventDetails(field: EventDetailsDCCVaccination.vaccineManufacturer, value: vaccineManufacturer),
			EventDetails(field: EventDetailsDCCVaccination.dosage, value: dosage),
			EventDetails(field: EventDetailsDCCVaccination.date, value: formattedVaccinationDate),
			EventDetails(field: EventDetailsDCCVaccination.country, value: country),
			EventDetails(field: EventDetailsDCCVaccination.issuer, value: issuer),
			EventDetails(field: EventDetailsDCCVaccination.certificateIdentifier, value: vaccination.certificateIdentifier)
		]

		return ListEventsViewController.Row(
			title: L.generalVaccinationcertificate().capitalizingFirstLetter(),
			subTitle: L.holderDccElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	private func getRowFromDCCRecoveryEvent(
		dataRow: EventDataTuple,
		recovery: EuCredentialAttributes.RecoveryEntry) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")

		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(printDateFormatter.string) ?? recovery.firstPositiveTestDate
		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
			.map(printDateFormatter.string) ?? recovery.validFrom
		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
			.map(printDateFormatter.string) ?? recovery.expiresAt
		
		let issuer = getDisplayIssuer(recovery.issuer)
		let country = getDisplayCountry(recovery.country)
		
		let details: [EventDetails] = [
			EventDetails(field: EventDetailsDCCRecovery.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCRecovery.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsDCCRecovery.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCRecovery.date, value: formattedFirstPostiveDate),
			EventDetails(field: EventDetailsDCCRecovery.country, value: country),
			EventDetails(field: EventDetailsDCCRecovery.issuer, value: issuer),
			EventDetails(field: EventDetailsDCCRecovery.validFrom, value: formattedValidFromDate),
			EventDetails(field: EventDetailsDCCRecovery.validUntil, value: formattedValidUntilDate),
			EventDetails(field: EventDetailsDCCRecovery.certificateIdentifier, value: recovery.certificateIdentifier)
		]

		return ListEventsViewController.Row(
			title: L.generalRecoverystatement().capitalizingFirstLetter(),
			subTitle: L.holderDccElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	private func getRowFromDCCTestEvent(
		dataRow: EventDataTuple,
		test: EuCredentialAttributes.TestEntry) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(printTestDateFormatter.string) ?? test.sampleDate

		let testType = remoteConfigManager.getConfiguration().getTestTypeMapping(
			test.typeOfTest) ?? test.typeOfTest

		let manufacturer = remoteConfigManager.getConfiguration().getTestManufacturerMapping(
			test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		var testResult = test.testResult
		if test.testResult == "260415000" {
			testResult = L.holderShowqrEuAboutTestNegative()
		}
		if test.testResult == "260373001" {
			testResult = L.holderShowqrEuAboutTestPostive()
		}
		
		let issuer = getDisplayIssuer(test.issuer)
		let country = getDisplayCountry(test.country)
		let facility = getDisplayFacility(test.testCenter)
		
		let details: [EventDetails] = [
			EventDetails(field: EventDetailsDCCTest.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCTest.name, value: dataRow.identity.fullName),
			EventDetails(field: EventDetailsDCCTest.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCTest.pathogen, value: L.holderDccTestPathogenvalue()),
			EventDetails(field: EventDetailsDCCTest.testType, value: testType),
			EventDetails(field: EventDetailsDCCTest.testName, value: test.name),
			EventDetails(field: EventDetailsDCCTest.date, value: formattedTestDate),
			EventDetails(field: EventDetailsDCCTest.result, value: testResult),
			EventDetails(field: EventDetailsDCCTest.facility, value: facility),
			EventDetails(field: EventDetailsDCCTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsDCCTest.country, value: country),
			EventDetails(field: EventDetailsDCCTest.issuer, value: issuer),
			EventDetails(field: EventDetailsDCCTest.certificateIdentifier, value: test.certificateIdentifier)
		]

		return ListEventsViewController.Row(
			title: L.generalTestcertificate().capitalizingFirstLetter(),
			subTitle: L.holderDccElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}
}

// MARK: Test 2.0

private extension ListEventsViewModel {

	func pendingEventsState() -> ListEventsViewController.State {

		return .feedback(
			content: Content(
				title: L.holderTestresultsPendingTitle(),
				subTitle: L.holderTestresultsPendingText(),
				primaryActionTitle: L.holderTestNolistAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	func listTest20EventsState(_ remoteEvent: RemoteEvent) -> ListEventsViewController.State {

		var rows = [ListEventsViewController.Row]()
		if let row = getTest20Row(remoteEvent) {
			rows.append(row)
		}

		return .listEvents(
			content: Content(
				title: L.holderTestresultsResultsTitle(),
				subTitle: L.holderTestresultsResultsText(),
				primaryActionTitle: L.holderTestresultsResultsButton(),
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR(remoteEvents: [remoteEvent]) { [weak self] success in
						if !success {
							self?.showEventError(remoteEvents: [remoteEvent])
						}
					}
				},
				secondaryActionTitle: L.holderVaccinationListWrong(),
				secondaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: L.holderVaccinationWrongTitle(),
							body: L.holderTestresultsWrongBody(),
							hideBodyForScreenCapture: false
						)
					)
				}
			),
			rows: rows
		)
	}

	func getTest20Row(_ remoteEvent: RemoteEvent) -> ListEventsViewController.Row? {

		guard let result = remoteEvent.wrapper.result,
			  let sampleDate = Formatter.getDateFrom(dateString8601: result.sampleDate) else {
			return nil
		}

		let printSampleDate: String = printTestDateFormatter.string(from: sampleDate)
		let printSampleLongDate: String = printTestDateFormatter.string(from: sampleDate)
		let holderID = getDisplayIdentity(result.holder)
		
		return ListEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			subTitle: L.holderEventElementSubtitleTest2(printSampleDate, holderID),
			action: { [weak self] in
				
				let details: [EventDetails] = [
					EventDetails(field: EventDetailsTest.name, value: holderID),
					EventDetails(field: EventDetailsTest.testType, value: self?.remoteConfigManager.getConfiguration().getNlTestType(result.testType) ?? result.testType),
					EventDetails(field: EventDetailsTest.date, value: printSampleLongDate),
					EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestNegative()),
					EventDetails(field: EventDetailsTest.uniqueIdentifer, value: result.unique)
				]
				
				self?.coordinator?.listEventsScreenDidFinish(
					.showEventDetails(title: L.holderEventAboutTitle(),
									  details: details)
				)
			}
		)
	}

	/// Get a display version of the holder identity
	/// - Parameter holder: the holder identity
	/// - Returns: the display version
	func getDisplayIdentity(_ holder: TestHolderIdentity?) -> String {

		guard let holder = holder else {
			return ""
		}

		let parts = holder.mapIdentity(months: String.shortMonths)
		var output = ""
		for part in parts {
			output.append(part)
			output.append(" ")
		}
		return output.trimmingCharacters(in: .whitespaces)
	}
	
	func getDisplayIssuer(_ issuer: String) -> String {
		guard issuer == "Ministry of Health Welfare and Sport" else {
			return issuer
		}
		return L.holderDccListIssuer()
	}
	
	func getDisplayCountry(_ country: String) -> String {
		guard ["NL", "NLD"].contains(country) else {
			return country
		}
		return L.generalNetherlands()
	}
	
	func getDisplayFacility(_ facility: String) -> String {
		guard facility == "Facility approved by the State of The Netherlands" else {
			return facility
		}
		return L.holderDccListFacility()
	}
}

private extension EventFlow.VaccinationEvent {
	
	/// Get a display version of the vaccination completion status
	var completionStatus: String? {
		
		// Neither statements are completed: Vaccination incomplete
		guard completedByMedicalStatement == true || completedByPersonalStatement == true else {
			return nil
		}
		
		// Vaccination completed: Optional clarification for completion
		switch completionReason {
			case .recovery:
				return L.holderVaccinationStatusCompleteRecovery()
			case .priorEvent:
				return L.holderVaccinationStatusCompletePriorevent()
			default:
				return L.holderVaccinationStatusComplete()
		}
	}
}
