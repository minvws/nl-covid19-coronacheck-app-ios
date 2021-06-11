/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

enum ListEventSourceMode {
	case ggd
	case commercial
}

class ListEventsViewModel: Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var walletManager: WalletManaging
	private var networkManager: NetworkManaging
	private var cryptoManager: CryptoManaging
	private var remoteConfigManager: RemoteConfigManaging

	var maxValidity: Int {
		remoteConfigManager.getConfiguration().maxValidityHours ?? 40
	}

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
		sourceMode: ListEventSourceMode = .ggd,
		eventMode: EventMode,
		remoteVaccinationEvents: [RemoteVaccinationEvent],
		remoteTestEvents: [RemoteTestEvent],
		networkManager: NetworkManaging = Services.networkManager,
		walletManager: WalletManaging = WalletManager(),
		cryptoManager: CryptoManaging = Services.cryptoManager,
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.networkManager = networkManager
		self.walletManager = walletManager
		self.cryptoManager = cryptoManager
		self.remoteConfigManager = remoteConfigManager

		viewState = .loading(
			content: ListEventsViewController.Content(
				title: sourceMode == .ggd ? (eventMode == .test ? .holderTestResultsResultsTitle : .holderVaccinationLoadingTitle) : .holderTestResultsResultsTitle,
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)

		if sourceMode == .ggd {
			viewState = getViewState(from: remoteVaccinationEvents)
		} else {
			viewState = getViewState(from: remoteTestEvents)
		}
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
			title: .holderVaccinationAlertTitle,
			subTitle: eventMode == .vaccination ? .holderVaccinationAlertMessage : .holderTestAlertMessage,
			cancelAction: nil,
			cancelTitle: .holderVaccinationAlertCancel,
			okAction: { [weak self] _ in
				self?.goBack()
			},
			okTitle: .holderVaccinationAlertOk
		)
	}

	func goBack() {

		coordinator?.listEventsScreenDidFinish(.back(eventMode: eventMode))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	// MARK: State Helpers

	private func getViewState(
		from remoteEvents: [RemoteVaccinationEvent]) -> ListEventsViewController.State {

		var listDataSource = [(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)]()

		for eventResponse in remoteEvents {
			let identity = eventResponse.wrapper.identity
			for event in eventResponse.wrapper.events {
				listDataSource.append(
					(
						identity: identity,
						event: event,
						providerIdentifier: eventResponse.wrapper.providerIdentifier
					)
				)
			}
		}

		if listDataSource.isEmpty {
			return emptyEventsState()
		} else {
			return listEventsState(listDataSource, remoteEvents: remoteEvents)
		}
	}

	private func emptyEventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: eventMode == .vaccination ? .holderVaccinationNoListTitle : .holderTestNoListTitle,
				subTitle: eventMode == .vaccination ? .holderVaccinationNoListMessage : .holderTestNoListMessage,
				primaryActionTitle: eventMode == .vaccination ? .holderVaccinationNoListActionTitle : .holderTestNoListActionTitle,
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func listEventsState(
		_ dataSource: [(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)],
		remoteEvents: [RemoteVaccinationEvent]) -> ListEventsViewController.State {

		return .listEvents(
			content: ListEventsViewController.Content(
				title: eventMode == .vaccination ? .holderVaccinationListTitle : .holderTestResultsResultsTitle,
				subTitle: eventMode == .vaccination ? .holderVaccinationListMessage : .holderTestResultsResultsText,
				primaryActionTitle: .holderVaccinationListActionTitle,
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] in
						self?.showVaccinationError(remoteEvents: remoteEvents)
					}
				},
				secondaryActionTitle: .holderVaccinationListWrong,
				secondaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: .holderVaccinationWrongTitle,
							body: self?.eventMode == .vaccination ? .holderVaccinationWrongBody : .holderTestWrongBody
						)
					)
				}
			),
			rows: getSortedRowsFromEvents(dataSource)
		)
	}

	private func getSortedRowsFromEvents(_ dataSource: [(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)]) -> [ListEventsViewController.Row] {

		if eventMode == .vaccination {
			let sortedDataSource = dataSource.sorted { lhs, rhs in
				if let lhsDate = lhs.event.vaccination?.getDate(with: dateFormatter),
				   let rhsDate = rhs.event.vaccination?.getDate(with: dateFormatter) {
					return lhsDate < rhsDate
				}
				return false
			}
			return getSortedRowsFromVaccinationEvents(sortedDataSource)
		} else {
			let sortedDataSource = dataSource.sorted { lhs, rhs in
				if let lhsDate = lhs.event.negativeTest?.getDate(with: dateFormatter),
				   let rhsDate = rhs.event.negativeTest?.getDate(with: dateFormatter) {
					return lhsDate > rhsDate
				}
				return false
			}
			return getSortedRowsFromTestEvents(sortedDataSource)
		}
	}

	private func getSortedRowsFromTestEvents(_ sortedDataSource: [(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)]) -> [ListEventsViewController.Row] {

		var rows = [ListEventsViewController.Row]()

		for dataRow in sortedDataSource {

			let formattedBirthDate: String = Formatter.getDateFrom(dateString8601: dataRow.identity.birthDateString)
				.map(printDateFormatter.string) ?? dataRow.identity.birthDateString
			let formattedTestDate: String = dataRow.event.negativeTest?.sampleDateString
				.flatMap(Formatter.getDateFrom)
				.map(printTestDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")
			let formattedTestLongDate: String = dataRow.event.negativeTest?.sampleDateString
				.flatMap(Formatter.getDateFrom)
				.map(printTestLongDateFormatter.string) ?? (dataRow.event.negativeTest?.sampleDateString ?? "")

			var expireDate = ""
			if let sampleDate = dataRow.event.negativeTest?.sampleDateString
				.flatMap(Formatter.getDateFrom) {
				expireDate = Calendar.current.date(byAdding: .hour, value: maxValidity, to: sampleDate)
					.flatMap(printTestDateFormatter.string) ?? ""
			}

			rows.append(
				ListEventsViewController.Row(
					title: .holderTestResultsNegative,
					subTitle: String(
						format: .holderTestElementSubTitle30,
						formattedTestDate,
						expireDate,
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
								title: .holderEventAboutTitle,
								body: String(
									format: .holderEventAboutBodyTest30,
									dataRow.identity.fullName,
									formattedBirthDate,
									testType,
									dataRow.event.negativeTest?.name ?? "",
									formattedTestLongDate,
									String.holderShowQREuAboutTestNegative,
									dataRow.event.negativeTest?.facility ?? "",
									manufacturer,
									dataRow.event.unique
								)
							)
						)
					}
				)
			)
		}
		return rows
	}

	private func getSortedRowsFromVaccinationEvents(_ sortedDataSource: [(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String)]) -> [ListEventsViewController.Row] {

		var rows = [ListEventsViewController.Row]()

		for dataRow in sortedDataSource {

			let formattedBirthDate: String = Formatter.getDateFrom(dateString8601: dataRow.identity.birthDateString)
				.map(printDateFormatter.string) ?? dataRow.identity.birthDateString
			let formattedShotDate: String = dataRow.event.vaccination?.dateString
				.flatMap(Formatter.getDateFrom)
				.map(printDateFormatter.string) ?? (dataRow.event.vaccination?.dateString ?? "")
			let formattedShotMonth: String = dataRow.event.vaccination?.dateString
				.flatMap(Formatter.getDateFrom)
				.map(printMonthFormatter.string) ?? ""
			let provider: String = remoteConfigManager.getConfiguration().getProviderIdentifierMapping(dataRow.providerIdentifier) ?? ""

			rows.append(
				ListEventsViewController.Row(
					title: String(format: .holderVaccinationElementTitle, "\(formattedShotMonth) (\(provider))"),
					subTitle: String(
						format: .holderVaccinationElementSubTitle,
						dataRow.identity.fullName,
						formattedBirthDate
					),
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
							dosage = String(format: .holderVaccinationAboutOf, "\(doseNumber)", "\(totalDose)")
						}

						self?.coordinator?.listEventsScreenDidFinish(
							.moreInformation(
								title: .holderEventAboutTitle,
								body: String(
									format: .holderEventAboutBodyVaccination,
									dataRow.identity.fullName,
									formattedBirthDate,
									vaccinName,
									vaccineType,
									vaccineManufacturer,
									dosage,
									formattedShotDate,
									dataRow.event.vaccination?.country ?? "",
									dataRow.event.unique
								)
							)
						)
					}
				)
			)
		}

		return rows
	}

	// MARK: Sign the events

	private func userWantsToMakeQR(remoteEvents: [RemoteVaccinationEvent], onError: @escaping () -> Void) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		storeVaccinationEvent(remoteEvents: remoteEvents) { saved in

			guard saved else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				onError()
				return
			}

			self.signTheEventsIntoGreenCardsAndCredentials(onError: onError)
		}
	}

	private func signTheEventsIntoGreenCardsAndCredentials(onError: @escaping () -> Void) {

		self.prepareIssue { [weak self] prepareIssueEnvelope in
			if let envelope = prepareIssueEnvelope,
			   let nonce = envelope.prepareIssueMessage.base64Decoded() {
				self?.cryptoManager.setNonce(nonce)
				self?.cryptoManager.setStoken(envelope.stoken)

				self?.fetchGreenCards { [weak self] response in
					if let greenCardResponse = response {

						self?.storeGreenCards(response: greenCardResponse) { greenCardsSaved in

							self?.progressIndicationCounter.decrement()
							if greenCardsSaved {

								let numberOfOrigins = self?.walletManager.listOrigins(type: self?.eventMode == .vaccination ? .vaccination : .test).count
								self?.logVerbose("Origins for \(String(describing: self?.eventMode)): \(String(describing: numberOfOrigins))")
								if numberOfOrigins == 0 {
									// No origins for this type means something went wrong.
									if let state = self?.cannotCreateEventsState() {
										self?.viewState = state
										self?.shouldPrimaryButtonBeEnabled = true
									}
								} else {
									self?.coordinator?.listEventsScreenDidFinish(.continue(value: nil, eventMode: .vaccination))
								}

							} else {
								self?.logError("Failed to save greenCards")
								self?.shouldPrimaryButtonBeEnabled = true
								onError()
							}
						}
					} else {
						self?.logError("No greencards")
						self?.progressIndicationCounter.decrement()
						self?.shouldPrimaryButtonBeEnabled = true
						onError()
					}
				}

			} else {
				self?.logError("Can't save the nonce / prepareIssueMessage")
				self?.progressIndicationCounter.decrement()
				self?.shouldPrimaryButtonBeEnabled = true
			}
		}
	}

	private func showVaccinationError(remoteEvents: [RemoteVaccinationEvent]) {

		alert = ListEventsViewController.AlertContent(
			title: .errorTitle,
			subTitle: .holderVaccinationErrorMessage,
			cancelAction: nil,
			cancelTitle: .holderVaccinationErrorClose,
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] in
					self?.showVaccinationError(remoteEvents: remoteEvents)
				}
			},
			okTitle: .holderVaccinationErrorAgain
		)
	}

	// MARK: API Calls

	/// Prepare the cryptoManager
	/// - Parameter onCompletion: completion handler
	private func prepareIssue(_ onCompletion: @escaping (PrepareIssueEnvelope?) -> Void) {

		networkManager.prepareIssue { result in
			// Result<PrepareIssueEnvelope, NetworkError>
			switch result {
				case let .success(prepareIssueEnvelope):
					self.logDebug("ok: \(prepareIssueEnvelope)")
					onCompletion(prepareIssueEnvelope)
				case let .failure(error):
					self.logError("error: \(error)")
					onCompletion(nil)
			}
		}
	}

	private func fetchGreenCards(_ onCompletion: @escaping (RemoteGreenCards.Response?) -> Void) {

		let signedEvents = walletManager.fetchSignedEvents()

		guard let issueCommitmentMessage = cryptoManager.generateCommitmentMessage(),
			let utf8 = issueCommitmentMessage.data(using: .utf8),
			let stoken = cryptoManager.getStoken()
		else {
			//					onError(ProofError.missingParams)
			return
		}

		let dictionary: [String: AnyObject] = [
			"stoken": stoken as AnyObject,
			"events": signedEvents as AnyObject,
			"issueCommitmentMessage": utf8.base64EncodedString() as AnyObject
		]

		self.networkManager.fetchGreencards(dictionary: dictionary) { result in
			//	Result<RemoteGreenCards.Response, NetworkError>

			switch result {
				case let .success(greencardResponse):
					self.logVerbose("ok: \(greencardResponse)")
					onCompletion(greencardResponse)
				case let .failure(error):
					self.logError("error: \(error)")
					onCompletion(nil)
			}
		}
	}

	// MARK: Store vaccination events

	private func storeVaccinationEvent(
		remoteEvents: [RemoteVaccinationEvent],
		onCompletion: @escaping (Bool) -> Void) {

		var success = true
		for response in remoteEvents where response.wrapper.status == .complete {

			// Remove any existing vaccination events for the provider
			walletManager.removeExistingEventGroups(
				type: eventMode == .vaccination ? .vaccination : .test,
				providerIdentifier: response.wrapper.providerIdentifier
			)

			// Store the new vaccination events
			if let maxIssuedAt = eventMode == .vaccination ? response.wrapper.getMaxIssuedAt(dateFormatter) : response.wrapper.getMaxSampleDate(dateFormatter) {
				success = success && walletManager.storeEventGroup(
					eventMode == .vaccination ? .vaccination : .test,
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

	// MARK: Store test events

	private func storeTestEvent(
		remoteEvents: [RemoteTestEvent],
		onCompletion: @escaping (Bool) -> Void) {

		var success = true
		for response in remoteEvents where response.wrapper.status == .complete {

			// Remove any existing test events for the provider
			walletManager.removeExistingEventGroups(type: .test, providerIdentifier: response.wrapper.providerIdentifier)

			// Store the new test events
			if let result = response.wrapper.result,
			   let sampleDate = Formatter.getDateFrom(dateString8601: result.sampleDate) {

				success = success && walletManager.storeEventGroup(
					.test,
					providerIdentifier: response.wrapper.providerIdentifier,
					signedResponse: response.signedResponse,
					issuedAt: sampleDate
				)
				if !success {
					break
				}
			}
		}
		onCompletion(success)
	}

	// MARK: Store green cards

	private func storeGreenCards(
		response: RemoteGreenCards.Response,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		walletManager.removeExistingGreenCards()

		if let domestic = response.domesticGreenCard {
			success = success && walletManager.storeDomesticGreenCard(domestic, cryptoManager: cryptoManager)
		}
		if let remoteEuGreenCards = response.euGreenCards {
			for remoteEuGreenCard in remoteEuGreenCards {
				success = success && walletManager.storeEuGreenCard(remoteEuGreenCard, cryptoManager: cryptoManager)
			}
		}
		onCompletion(success)
	}

	private func cannotCreateEventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: .holderVaccinationOriginMismatchTitle,
				subTitle: eventMode == .vaccination ? .holderVaccinationOriginMismatchMessage : .holderTestOriginMismatchMessage,
				primaryActionTitle: .holderTestResultsBackToMenuButton,
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

	private func getViewState(
		from remoteEvent: [RemoteTestEvent]) -> ListEventsViewController.State {

		if let event = remoteEvent.first {

			switch event.wrapper.status {
				case .complete:
					if let result = event.wrapper.result, result.negativeResult {
						return listTest20EventsState(event)
					} else {
						return emptyTest20EventsState()
					}
				case .pending:
					return pendingTest20EventsState()
				default:
					return emptyTest20EventsState()
			}
		}

		return emptyTest20EventsState()
	}

	private func pendingTest20EventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: .holderTestResultsPendingTitle,
				subTitle: .holderTestResultsPendingText,
				primaryActionTitle: .holderTestResultsBackToMenuButton,
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func emptyTest20EventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: .holderTestResultsNoResultsTitle,
				subTitle: .holderTestResultsNoResultsText,
				primaryActionTitle: .holderTestResultsBackToMenuButton,
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func listTest20EventsState(_ remoteTestEvent: RemoteTestEvent) -> ListEventsViewController.State {

		var rows = [ListEventsViewController.Row]()
		if let row = getTest20Row(remoteTestEvent) {
			rows.append(row)
		}

		return .listEvents(
			content: ListEventsViewController.Content(
				title: .holderTestResultsResultsTitle,
				subTitle: .holderTestResultsResultsText,
				primaryActionTitle: .holderTestResultsResultsButton,
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR(remoteEvents: [remoteTestEvent], onError: {

					})
				},
				secondaryActionTitle: .holderVaccinationListWrong,
				secondaryAction: { [weak self] in
					self?.coordinator?.listEventsScreenDidFinish(
						.moreInformation(
							title: .holderVaccinationWrongTitle,
							body: .holderTestWrongBody
						)
					)
				}
			),
			rows: rows
		)
	}

	private func getTest20Row(_ remoteTestEvent: RemoteTestEvent) -> ListEventsViewController.Row? {

		guard let result = remoteTestEvent.wrapper.result,
			  let sampleDate = Formatter.getDateFrom(dateString8601: result.sampleDate) else {
			return nil
		}

		let printSampleDate: String = printTestDateFormatter.string(from: sampleDate)
		let printSampleLongDate: String = printTestLongDateFormatter.string(from: sampleDate)
		let expireDate = Calendar.current.date(byAdding: .hour, value: maxValidity, to: sampleDate) ?? sampleDate
		let printExpireDate: String = printTestDateFormatter.string(from: expireDate)

		let holderID = getDisplayIdentity(result.holder)

		return ListEventsViewController.Row(
			title: .holderTestResultsNegative,
			subTitle: String(
				format: .holderTestElementSubTitle20,
				printSampleDate,
				printExpireDate,
				holderID
			),
			action: { [weak self] in

				let body = String(
					format: .holderEventAboutBodyTest20,
					holderID,
					self?.remoteConfigManager.getConfiguration().getNlTestType(result.testType) ?? result.testType,
					printSampleLongDate,
					result.negativeResult ? String.holderShowQREuAboutTestNegative : String.holderShowQREuAboutTestPositive,
					result.unique
				)

				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: .holderEventAboutTitle,
						body: body
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

	private func userWantsToMakeQR(remoteEvents: [RemoteTestEvent], onError: @escaping () -> Void) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		storeTestEvent(remoteEvents: remoteEvents) { saved in

			guard saved else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				onError()
				return
			}
			self.signTheEventsIntoGreenCardsAndCredentials(onError: onError)
		}
	}

	private func showTestError(remoteEvents: [RemoteTestEvent]) {

		alert = ListEventsViewController.AlertContent(
			title: .errorTitle,
			subTitle: .holderVaccinationErrorMessage,
			cancelAction: nil,
			cancelTitle: .holderVaccinationErrorClose,
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] in
					self?.showTestError(remoteEvents: remoteEvents)
				}
			},
			okTitle: .holderVaccinationErrorAgain
		)
	}
}
