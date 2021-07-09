/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length file_length

import Foundation

typealias EventDataTuple = (identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)

class ListEventsViewModel: PreventableScreenCapture, Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var walletManager: WalletManaging
	private var remoteConfigManager: RemoteConfigManaging
	private let greenCardLoader: GreenCardLoading

	private var eventMode: EventMode

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	private lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()
	
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd MMMM yyyy"
		return dateFormatter
	}()
	private lazy var printTestDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EE d MMMM HH:mm"
		return dateFormatter
	}()
	private lazy var printTestLongDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
	private lazy var printMonthFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListEventsViewController.State

	@Bindable private(set) var alert: ListEventsViewController.AlertContent?

	@Bindable internal var shouldPrimaryButtonBeEnabled: Bool = true

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode,
		remoteEvents: [RemoteEvent],
		greenCardLoader: GreenCardLoading,
		walletManager: WalletManaging = Services.walletManager,
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.walletManager = walletManager
		self.remoteConfigManager = remoteConfigManager
		self.greenCardLoader = greenCardLoader

		viewState = .loading(
			content: ListEventsViewController.Content(
				title: {
					switch eventMode {
						case .recovery:
							return L.holderRecoveryListTitle()
						case .test:
							return L.holderTestresultsResultsTitle()
						case .vaccination:
							return L.holderVaccinationListTitle()
					}
				}(),
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)

		super.init()

		viewState = getViewState(from: remoteEvents)
	}

	func backButtonTapped() {

		switch viewState {
			case .loading, .listEvents:
				warnBeforeGoBack()
			case .emptyEvents:
				goBack()
		}
	}

	func warnBeforeGoBack() {

		alert = ListEventsViewController.AlertContent(
			title: L.holderVaccinationAlertTitle(),
			subTitle: {
				switch eventMode {
					case .recovery:
						return L.holderRecoveryAlertMessage()
					case .test:
						return L.holderTestAlertMessage()
					case .vaccination:
						return L.holderVaccinationAlertMessage()
				}
			}(),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationAlertCancel(),
			okAction: { [weak self] _ in
				self?.goBack()
			},
			okTitle: L.holderVaccinationAlertOk()
		)
	}

	func goBack() {

		coordinator?.listEventsScreenDidFinish(.back(eventMode: eventMode))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	// MARK: State Helpers

	private func getViewState(from remoteEvents: [RemoteEvent]) -> ListEventsViewController.State {

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
		switch eventMode {
			case .vaccination:
				title = L.holderVaccinationListTitle()
				subTitle = L.holderVaccinationListMessage()
			case .recovery:
				title = L.holderRecoveryListTitle()
				subTitle = L.holderRecoveryListMessage()
			case .test:
				title = L.holderTestresultsResultsTitle()
				subTitle = L.holderTestresultsResultsText()
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
							body: self?.eventMode == .vaccination ? L.holderVaccinationWrongBody() : L.holderTestresultsWrongBody(),
							hideBodyForScreenCapture: false
						)
					)
				}
			),
			rows: rows
		)
	}

	private func getSortedRowsFromEvents(_ dataSource: [EventDataTuple]) -> [ListEventsViewController.Row] {

		let sortedDataSource = dataSource.sorted { lhs, rhs in
			if let lhsDate = lhs.event.getSortDate(with: dateFormatter),
			   let rhsDate = rhs.event.getSortDate(with: dateFormatter) {
				return lhsDate < rhsDate
			}
			return false
		}

		switch eventMode {
			case .recovery:
				return getSortedRowsFromRecoveryEvents(sortedDataSource)
			case .test:
				return getSortedRowsFromTestEvents(sortedDataSource)
			case .vaccination:
				return getSortedRowsFromVaccinationEvents(sortedDataSource)
		}
	}

	private func getSortedRowsFromTestEvents(_ sortedDataSource: [EventDataTuple]) -> [ListEventsViewController.Row] {

		var rows = [ListEventsViewController.Row]()

		for dataRow in sortedDataSource {

			let formattedBirthDate: String = dataRow.identity.birthDateString
				.flatMap(Formatter.getDateFrom)
				.map(printDateFormatter.string) ?? (dataRow.identity.birthDateString ?? "")
			let formattedTestDate: String = dataRow.event.negativeTest?.sampleDateString
				.flatMap(Formatter.getDateFrom)
				.map(printTestDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")
			let formattedTestLongDate: String = dataRow.event.negativeTest?.sampleDateString
				.flatMap(Formatter.getDateFrom)
				.map(printTestLongDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")

			rows.append(
				ListEventsViewController.Row(
					title: L.holderTestresultsNegative(),
					subTitle: L.holderEventElementSubtitleTest3(
						formattedTestDate,
						dataRow.identity.fullName,
						formattedBirthDate
					),
					action: { [weak self] in

						let testType = self?.remoteConfigManager.getConfiguration().getTestTypeMapping(
							dataRow.event.negativeTest?.type) ?? (dataRow.event.negativeTest?.type ?? "")

						let manufacturer = self?.remoteConfigManager.getConfiguration().getTestManufacturerMapping(
							dataRow.event.negativeTest?.manufacturer) ?? (dataRow.event.negativeTest?.manufacturer ?? "")

						self?.coordinator?.listEventsScreenDidFinish(
							.moreInformation(
								title: L.holderEventAboutTitle(),
								body: L.holderEventAboutBodyTest3(
									dataRow.identity.fullName,
									formattedBirthDate,
									testType,
									dataRow.event.negativeTest?.name ?? "",
									formattedTestLongDate,
									L.holderShowqrEuAboutTestNegative(),
									dataRow.event.negativeTest?.facility ?? "",
									manufacturer,
									dataRow.event.unique ?? ""
								),
								hideBodyForScreenCapture: true
							)
						)
					}
				)
			)
		}
		return rows
	}

	private func getSortedRowsFromVaccinationEvents(_ sortedDataSource: [EventDataTuple]) -> [ListEventsViewController.Row] {

		var rows = [ListEventsViewController.Row]()

		for dataRow in sortedDataSource {

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

			rows.append(
				ListEventsViewController.Row(
					title: L.holderVaccinationElementTitle("\(formattedShotMonth) (\(provider))"),
					subTitle: L.holderVaccinationElementSubtitle(dataRow.identity.fullName, formattedBirthDate),
					action: { [weak self] in

						var vaccinName = ""
						if let hpkCode = dataRow.event.vaccination?.hpkCode {
							vaccinName = self?.remoteConfigManager.getConfiguration().getHpkMapping(hpkCode) ?? ""
						} else if let brand = dataRow.event.vaccination?.brand {
							vaccinName = self?.remoteConfigManager.getConfiguration().getBrandMapping(brand) ?? ""
						}

						let vaccineType = self?.remoteConfigManager.getConfiguration().getTypeMapping(
							dataRow.event.vaccination?.type) ?? dataRow.event.vaccination?.type ?? ""
						let vaccineManufacturer = self?.remoteConfigManager.getConfiguration().getVaccinationManufacturerMapping(
							dataRow.event.vaccination?.manufacturer) ?? dataRow.event.vaccination?.manufacturer ?? ""

						var dosage = ""
						if let doseNumber = dataRow.event.vaccination?.doseNumber,
						   let totalDose = dataRow.event.vaccination?.totalDoses {
							dosage = L.holderVaccinationAboutOff("\(doseNumber)", "\(totalDose)")
						}

						self?.coordinator?.listEventsScreenDidFinish(
							.moreInformation(
								title: L.holderEventAboutTitle(),
								body: L.holderEventAboutBodyVaccination(
									dataRow.identity.fullName,
									formattedBirthDate,
									vaccinName,
									vaccineType,
									vaccineManufacturer,
									dosage,
									formattedShotDate,
									dataRow.event.vaccination?.country ?? "",
									dataRow.event.unique ?? ""
								),
								hideBodyForScreenCapture: true
							)
						)
					}
				)
			)
		}

		return rows
	}

	private func getSortedRowsFromRecoveryEvents(_ sortedDataSource: [EventDataTuple]) -> [ListEventsViewController.Row] {

		var rows = [ListEventsViewController.Row]()
		for dataRow in sortedDataSource {

			if dataRow.event.recovery != nil {
				rows.append(getRowFromRecoveryEvent(dataRow: dataRow))
			} else if dataRow.event.positiveTest != nil {
				rows.append(getRowFromPositiveTestEvent(dataRow: dataRow))
			}
		}
		return rows
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
						body: L.holderEventAboutBodyRecovery(
							dataRow.identity.fullName,
							formattedBirthDate,
							formattedShortTestDate,
							formattedShortValidFromDate,
							formattedShortValidUntilDate,
							dataRow.event.unique ?? ""
						),
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

		return ListEventsViewController.Row(
			title: L.holderTestresultsPositive(),
			subTitle: L.holderEventElementSubtitleTest3(
				formattedTestDate,
				dataRow.identity.fullName,
				formattedBirthDate
			),
			action: { [weak self] in

				let testType = self?.remoteConfigManager.getConfiguration().getTestTypeMapping(
					dataRow.event.positiveTest?.type) ?? (dataRow.event.positiveTest?.type ?? "")

				let manufacturer = self?.remoteConfigManager.getConfiguration().getTestManufacturerMapping(
					dataRow.event.positiveTest?.manufacturer) ?? (dataRow.event.positiveTest?.manufacturer ?? "")

				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: L.holderEventAboutTitle(),
						body: L.holderEventAboutBodyTest3(
							dataRow.identity.fullName,
							formattedBirthDate,
							testType, dataRow.event.positiveTest?.name ?? "",
							formattedTestLongDate,
							L.holderShowqrEuAboutTestPostive(),
							dataRow.event.positiveTest?.facility ?? "",
							manufacturer, dataRow.event.unique ?? ""
						),
						hideBodyForScreenCapture: true
					)
				)
			}
		)
	}

	// MARK: Sign the events

	private func userWantsToMakeQR(remoteEvents: [RemoteEvent], completion: @escaping (Bool) -> Void) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		storeEvent(remoteEvents: remoteEvents) { saved in

			guard saved else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				completion(false)
				return
			}

			self.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: { [weak self] remoteResponse in
				// Check if we have any origin for the event mode
				// == 0 -> No greenCards from the signer (name mismatch, expired, etc)
				// > 0 -> Success

				let domesticOrigins: Int = remoteResponse.domesticGreenCard?.origins
					.filter { $0.type == self?.eventMode.rawValue }
					.count ?? 0
				let internationalOrigins: Int = remoteResponse.euGreenCards?
					.flatMap { $0.origins }
					.filter { $0.type == self?.eventMode.rawValue }
					.count ?? 0

				self?.logVerbose("We got \(domesticOrigins) domestic Origins of type \(String(describing: self?.eventMode.rawValue))")
				self?.logVerbose("We got \(internationalOrigins) international Origins of type \(String(describing: self?.eventMode.rawValue))")
				return internationalOrigins + domesticOrigins > 0

			}, completion: { result in
				self.progressIndicationCounter.decrement()

				switch result {
					case .success:
						self.coordinator?.listEventsScreenDidFinish(
							.continue(
								value: nil,
								eventMode: self.eventMode
							)
						)

					case .failure(.didNotEvaluate):
						self.viewState = self.cannotCreateEventsState()
						self.shouldPrimaryButtonBeEnabled = true

					case .failure(.failedToSave), .failure(.noEvents):
						self.shouldPrimaryButtonBeEnabled = true
						completion(false)

					case .failure(.requestTimedOut), .failure(.noInternetConnection):
						self.showNoInternet(remoteEvents: remoteEvents)
						self.shouldPrimaryButtonBeEnabled = true

					case .failure(.failedToPrepareIssue):
						self.showTechnicalError("116 decodePrepareIssueMessage")

					case .failure(.serverBusy):
						self.showServerTooBusyError()

					case .failure(.preparingIssue117):
						self.showTechnicalError("117 prepareIssue")

					case .failure(.stoken118):
						self.showTechnicalError("118 stoken")

					case .failure(.credentials119):
						self.showTechnicalError("118 credentials")
				}
			})
		}
	}

	private func showEventError(remoteEvents: [RemoteEvent]) {

		alert = ListEventsViewController.AlertContent(
			title: L.generalErrorTitle(),
			subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationErrorClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
					if !success {
						self?.showEventError(remoteEvents: remoteEvents)
					}
				}
			},
			okTitle: L.holderVaccinationErrorAgain()
		)
	}

	// MARK: API Calls

	private func showServerTooBusyError() {

		alert = ListEventsViewController.AlertContent(
			title: L.generalNetworkwasbusyTitle(),
			subTitle: L.generalNetworkwasbusyText(),
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { [weak self] _ in
				self?.coordinator?.listEventsScreenDidFinish(.stop)
			},
			okTitle: L.generalNetworkwasbusyButton()
		)
	}

	private func showNoInternet(remoteEvents: [RemoteEvent]) {

		// this is a retry-able situation
		alert = ListEventsViewController.AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
					if !success {
						self?.showEventError(remoteEvents: remoteEvents)
					}
				}
			},
			okTitle: L.holderVaccinationErrorAgain()
		)
	}

	private func showTechnicalError(_ customCode: String?) {

		var subTitle = L.generalErrorTechnicalText()
		if let code = customCode {
			subTitle = L.generalErrorTechnicalCustom(code)
		}
		alert = ListEventsViewController.AlertContent(
			title: L.generalErrorTitle(),
			subTitle: subTitle,
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { _ in
				self.coordinator?.listEventsScreenDidFinish(.back(eventMode: self.eventMode))
			},
			okTitle: L.generalClose()
		)
	}

	// MARK: Store events

	private func storeEvent(
		remoteEvents: [RemoteEvent],
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		if eventMode == .vaccination {
			// Remove any existing vaccination events
			walletManager.removeExistingEventGroups(type: eventMode)
		}

		for response in remoteEvents where response.wrapper.status == .complete {

			if eventMode != .vaccination {
				// Remove any existing events for the provider
				walletManager.removeExistingEventGroups(
					type: eventMode,
					providerIdentifier: response.wrapper.providerIdentifier
				)
			}

			// Store the new events
			if let maxIssuedAt = response.wrapper.getMaxIssuedAt() {
				success = success && walletManager.storeEventGroup(
					eventMode,
					providerIdentifier: response.wrapper.providerIdentifier,
					signedResponse: response.signedResponse,
					issuedAt: maxIssuedAt
				)
				if !success {
					break
				}
			}
		}
		onCompletion(success)
	}

	private func cannotCreateEventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: L.holderEventOriginmismatchTitle(),
				subTitle: {
					switch eventMode {
						case .recovery:
							return L.holderEventOriginmismatchRecoveryBody()
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
