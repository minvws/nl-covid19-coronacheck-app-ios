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

		return .emptyEvents(
			content: ListEventsViewController.Content(
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

		return .emptyEvents(
			content: ListEventsViewController.Content(
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

		return .emptyEvents(
			content: ListEventsViewController.Content(
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

		return .emptyEvents(
			content: ListEventsViewController.Content(
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

		return .emptyEvents(
			content: ListEventsViewController.Content(
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

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: L.holderEventOriginmismatchTitle(),
				subTitle: {
					switch eventMode {
						case .recovery:
							return L.holderEventOriginmismatchRecoveryBody()
						case .paperflow:
							return L.holderEventOriginmismatchDccBody()
						case .test:
							return L.holderEventOriginmismatchTestBody()
						case .vaccination:
							return L.holderEventOriginmismatchVaccinationBody()
					}
				}(),
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

		let title: String
		let subTitle: String
		let secondaryActionBody: String
		switch eventMode {
			case .vaccination:
				title = L.holderVaccinationListTitle()
				subTitle = L.holderVaccinationListMessage()
				secondaryActionBody = L.holderVaccinationWrongBody()
			case .recovery:
				title = L.holderRecoveryListTitle()
				subTitle = L.holderRecoveryListMessage()
				secondaryActionBody = L.holderRecoveryWrongBody()
			case .test:
				title = L.holderTestresultsResultsTitle()
				subTitle = L.holderTestresultsResultsText()
				secondaryActionBody = L.holderTestresultsWrongBody()
			case .paperflow:
				title = L.holderDccListTitle()
				subTitle = L.holderDccListMessage()
				if let cryptoManager = cryptoManager,
				   let euCredentialAttributes = dataSource.first?.event.dccEvent?.getAttributes(cryptoManager: cryptoManager) {
					if euCredentialAttributes.digitalCovidCertificate.vaccinations?.first != nil {
						secondaryActionBody = L.holderVaccinationWrongBody()
					} else if euCredentialAttributes.digitalCovidCertificate.recoveries?.first != nil {
						secondaryActionBody = L.holderRecoveryWrongBody()
					} else if euCredentialAttributes.digitalCovidCertificate.tests?.first != nil {
						secondaryActionBody = L.holderTestresultsWrongBody()
					} else {
						secondaryActionBody = ""
					}
				} else {
					secondaryActionBody = ""
				}
		}

		return .listEvents(
			content: ListEventsViewController.Content(
				title: title,
				subTitle: subTitle,
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
					self?.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: L.holderVaccinationWrongTitle(),
							body: secondaryActionBody,
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

	private func getSortedRowsFromEvents(_ dataSource: [EventDataTuple]) -> [ListEventsViewController.Row] {

		let sortedDataSource = dataSource.sorted { lhs, rhs in
			if let lhsDate = lhs.event.getSortDate(with: dateFormatter),
			   let rhsDate = rhs.event.getSortDate(with: dateFormatter) {
				return lhsDate < rhsDate
			}
			return false
		}

		var rows = [ListEventsViewController.Row]()
		for dataRow in sortedDataSource {

			if dataRow.event.recovery != nil {
				rows.append(getRowFromRecoveryEvent(dataRow: dataRow))
			} else if dataRow.event.positiveTest != nil {
				rows.append(getRowFromPositiveTestEvent(dataRow: dataRow))
			} else if dataRow.event.vaccination != nil {
				rows.append(getRowFromVaccinationEvent(dataRow: dataRow))
			} else if dataRow.event.negativeTest != nil {
				rows.append(getRowFromNegativeTestEvent(dataRow: dataRow))
			} else if dataRow.event.dccEvent != nil {
				if let cryptoManager = cryptoManager,
				   let euCredentialAttributes = dataRow.event.dccEvent?.getAttributes(cryptoManager: cryptoManager) {
					if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
						rows.append(getRowFromDCCVaccinationEvent(dataRow: dataRow, vaccination: vaccination))
					} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
						rows.append(getRowFromDCCRecoveryEvent(dataRow: dataRow, recovery: recovery))
					} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
						rows.append(getRowFromDCCTestEvent(dataRow: dataRow, test: test))
					}
				}
			}
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
			.map(printTestLongDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")

		let testType = remoteConfigManager.getConfiguration().getTestTypeMapping(
			dataRow.event.negativeTest?.type) ?? (dataRow.event.negativeTest?.type ?? "")
		let manufacturer = remoteConfigManager.getConfiguration().getTestManufacturerMapping(
			dataRow.event.negativeTest?.manufacturer) ?? (dataRow.event.negativeTest?.manufacturer ?? "")

		let body = L.holderEventAboutBodyTest3(
			dataRow.identity.fullName,
			formattedBirthDate,
			testType,
			dataRow.event.negativeTest?.name ?? "",
			formattedTestLongDate,
			L.holderShowqrEuAboutTestNegative(),
			dataRow.event.negativeTest?.facility ?? "",
			manufacturer,
			dataRow.event.unique ?? ""
		)

		return ListEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
				)
			}
		)
	}

	private func getRowFromVaccinationEvent(dataRow: EventDataTuple) -> ListEventsViewController.Row {

		let formattedBirthDate: String = dataRow.identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
		let formattedShotDate: String = dataRow.event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(printDateFormatter.string) ?? (dataRow.event.vaccination?.dateString ?? "")
		let formattedShotMonth: String = dataRow.event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(printMonthFormatter.string) ?? ""
		let provider: String = remoteConfigManager.getConfiguration().getProviderIdentifierMapping(dataRow.providerIdentifier) ?? ""

		var vaccinName = ""
		if let hpkCode = dataRow.event.vaccination?.hpkCode {
			vaccinName = remoteConfigManager.getConfiguration().getHpkMapping(hpkCode) ?? ""
		} else if let brand = dataRow.event.vaccination?.brand {
			vaccinName = remoteConfigManager.getConfiguration().getBrandMapping(brand) ?? ""
		}

		let vaccineType = remoteConfigManager.getConfiguration().getTypeMapping(
			dataRow.event.vaccination?.type) ?? dataRow.event.vaccination?.type ?? ""
		let vaccineManufacturer = remoteConfigManager.getConfiguration().getVaccinationManufacturerMapping(
			dataRow.event.vaccination?.manufacturer) ?? dataRow.event.vaccination?.manufacturer ?? ""

		var dosage = ""
		if let doseNumber = dataRow.event.vaccination?.doseNumber,
		   let totalDose = dataRow.event.vaccination?.totalDoses {
			dosage = L.holderVaccinationAboutOff("\(doseNumber)", "\(totalDose)")
		}

		let body = L.holderEventAboutBodyVaccination(
			dataRow.identity.fullName,
			formattedBirthDate,
			vaccinName,
			vaccineType,
			vaccineManufacturer,
			dosage,
			dataRow.event.vaccination?.completionStatus ?? "",
			formattedShotDate,
			dataRow.event.vaccination?.country ?? "",
			dataRow.event.unique ?? ""
		)

		return ListEventsViewController.Row(
			title: L.holderVaccinationElementTitle("\(formattedShotMonth) (\(provider))"),
			subTitle: L.holderVaccinationElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
				)
			}
		)
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

		let body = L.holderEventAboutBodyRecovery(
			dataRow.identity.fullName,
			formattedBirthDate,
			formattedShortTestDate,
			formattedShortValidFromDate,
			formattedShortValidUntilDate,
			dataRow.event.unique ?? ""
		)

		return ListEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					EventScreenResult.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
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
			.map(printTestLongDateFormatter.string) ?? (dataRow.event.positiveTest?.sampleDateString ?? "")

		let testType = remoteConfigManager.getConfiguration().getTestTypeMapping(
			dataRow.event.positiveTest?.type) ?? (dataRow.event.positiveTest?.type ?? "")
		let manufacturer = remoteConfigManager.getConfiguration().getTestManufacturerMapping(
			dataRow.event.positiveTest?.manufacturer) ?? (dataRow.event.positiveTest?.manufacturer ?? "")

		let body = L.holderEventAboutBodyTest3(
			dataRow.identity.fullName,
			formattedBirthDate,
			testType, dataRow.event.positiveTest?.name ?? "",
			formattedTestLongDate,
			L.holderShowqrEuAboutTestPostive(),
			dataRow.event.positiveTest?.facility ?? "",
			manufacturer, dataRow.event.unique ?? ""
		)

		return ListEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
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

		let body: String = L.holderDccVaccinationMessage(
			dataRow.identity.fullName,
			formattedBirthDate,
			vaccineBrand,
			vaccineType,
			vaccineManufacturer,
			dosage ?? " ",
			formattedVaccinationDate,
			vaccination.country,
			vaccination.issuer,
			vaccination.certificateIdentifier
				.breakingAtColumn(column: 20) // hotfix for webview
		)

		return ListEventsViewController.Row(
			title: L.generalVaccinationcertificate().capitalizingFirstLetter(),
			subTitle: L.holderDccElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
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

		let body: String = L.holderDccRecoveryMessage(
			dataRow.identity.fullName,
			formattedBirthDate,
			formattedFirstPostiveDate,
			recovery.country,
			recovery.issuer,
			formattedValidFromDate,
			formattedValidUntilDate,
			recovery.certificateIdentifier
				.breakingAtColumn(column: 20) // hotfix for webview
		)

		return ListEventsViewController.Row(
			title: L.generalRecoverystatement().capitalizingFirstLetter(),
			subTitle: L.holderDccElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
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
			.map(printTestLongDateFormatter.string) ?? test.sampleDate

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

		let body: String = L.holderDccTestMessage(
			dataRow.identity.fullName,
			formattedBirthDate,
			testType,
			test.name ?? "",
			formattedTestDate,
			testResult,
			test.testCenter,
			manufacturer,
			test.country,
			test.issuer,
			test.certificateIdentifier
				.breakingAtColumn(column: 20) // hotfix for webview
		)

		return ListEventsViewController.Row(
			title: L.generalTestcertificate().capitalizingFirstLetter(),
			subTitle: L.holderDccElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
			action: { [weak self] in
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
				)
			}
		)
	}
}

// MARK: Test 2.0

extension ListEventsViewModel {

	private func pendingEventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
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

	private func listTest20EventsState(_ remoteEvent: RemoteEvent) -> ListEventsViewController.State {

		var rows = [ListEventsViewController.Row]()
		if let row = getTest20Row(remoteEvent) {
			rows.append(row)
		}

		return .listEvents(
			content: ListEventsViewController.Content(
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

	private func getTest20Row(_ remoteEvent: RemoteEvent) -> ListEventsViewController.Row? {

		guard let result = remoteEvent.wrapper.result,
			  let sampleDate = Formatter.getDateFrom(dateString8601: result.sampleDate) else {
			return nil
		}

		let printSampleDate: String = printTestDateFormatter.string(from: sampleDate)
		let printSampleLongDate: String = printTestLongDateFormatter.string(from: sampleDate)
		let holderID = getDisplayIdentity(result.holder)
		
		return ListEventsViewController.Row(
			title: L.holderTestresultsNegative(),
			subTitle: L.holderEventElementSubtitleTest2(printSampleDate, holderID),
			action: { [weak self] in

				let body = L.holderEventAboutBodyTest2(
					holderID,
					self?.remoteConfigManager.getConfiguration().getNlTestType(result.testType) ?? result.testType,
					printSampleLongDate,
					L.holderShowqrEuAboutTestNegative(),
					result.unique
				)
				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: body,
						hideBodyForScreenCapture: true
					)
				)
			}
		)
	}

	/// Get a display version of the holder identity
	/// - Parameter holder: the holder identity
	/// - Returns: the display version
	private func getDisplayIdentity(_ holder: TestHolderIdentity?) -> String {

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
}

private extension EventFlow.VaccinationEvent {
	
	/// Get a display version of the vaccination completion status
	var completionStatus: String {
		
		let status = completedByMedicalStatement ?? completedByPersonalStatement
		
		// No data: Unknown status
		guard status != nil else {
			return L.holderVaccinationStatusUnknown()
		}
		
		// Neither statements are completed: Vaccination incomplete
		guard status == true else {
			return L.holderVaccinationStatusIncomplete()
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
