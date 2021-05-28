/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

enum ListEventSourceMode {
	case vaccination
	case negativeTest
}

class ListEventsViewModel: Logging {

	weak var coordinator: EventCoordinatorDelegate?

	private var walletManager: WalletManaging
	private var networkManager: NetworkManaging
	private var cryptoManager: CryptoManaging
	private var remoteConfigManager: RemoteConfigManaging

	var maxValidity: Int {
		remoteConfigManager.getConfiguration().maxValidityHours ?? 40
	}

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

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd MMMM yyyy"
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printTestDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EE d MMMM HH:mm"
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
		coordinator: EventCoordinatorDelegate,
		sourceMode: ListEventSourceMode = .vaccination,
		remoteVaccinationEvents: [RemoteVaccinationEvent],
		remoteTestEvents: [RemoteTestEvent],
		networkManager: NetworkManaging = Services.networkManager,
		walletManager: WalletManaging = WalletManager(),
		cryptoManager: CryptoManaging = Services.cryptoManager,
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	) {

		self.coordinator = coordinator
		self.networkManager = networkManager
		self.walletManager = walletManager
		self.cryptoManager = cryptoManager
		self.remoteConfigManager = remoteConfigManager

		viewState = .loading(
			content: ListEventsViewController.Content(
				title: sourceMode == .vaccination ? .holderVaccinationLoadingTitle : .holderTestResultsResultsTitle,
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
		if sourceMode == .vaccination {
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
			subTitle: .holderVaccinationAlertMessage,
			cancelAction: nil,
			cancelTitle: .holderVaccinationAlertCancel,
			okAction: { [weak self] _ in
				self?.goBack()
			},
			okTitle: .holderVaccinationAlertOk
		)
	}

	func goBack() {

		coordinator?.listEventsScreenDidFinish(.back)
	}

	// MARK: State Helpers

	private func getViewState(
		from remoteEvents: [RemoteVaccinationEvent]) -> ListEventsViewController.State {

		var listDataSource = [(Vaccination.Identity, Vaccination.Event)]()

		for eventResponse in remoteEvents {
			let identity = eventResponse.wrapper.identity
			for event in eventResponse.wrapper.events {
				listDataSource.append((identity, event))
			}
		}

		if listDataSource.isEmpty {
			return emptyVaccinationEventsState()
		} else {
			return listVaccinationEventsState(listDataSource, remoteEvents: remoteEvents)
		}
	}

	private func emptyVaccinationEventsState() -> ListEventsViewController.State {

		return .emptyEvents(
			content: ListEventsViewController.Content(
				title: .holderVaccinationNoListTitle,
				subTitle: .holderVaccinationNoListMessage,
				primaryActionTitle: .holderVaccinationNoListActionTitle,
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	private func listVaccinationEventsState(
		_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)],
		remoteEvents: [RemoteVaccinationEvent]) -> ListEventsViewController.State {

		return .listEvents(
			content: ListEventsViewController.Content(
				title: .holderVaccinationListTitle,
				subTitle: .holderVaccinationListMessage,
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
							body: .holderVaccinationWrongBody
						)
					)
				}
			),
			rows: getSortedRowsFromEvents(dataSource)
		)
	}

	private func getSortedRowsFromEvents(_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)]) -> [ListEventsViewController.Row] {

		var rows = [ListEventsViewController.Row]()

		// Sort the vaccination events in ascending order
		let sortedDataSource = dataSource.sorted { lhs, rhs in
			if let lhsDate = lhs.event.vaccination?.getDate(with: dateFormatter),
			   let rhsDate = rhs.event.vaccination?.getDate(with: dateFormatter) {
				return lhsDate < rhsDate
			}
			return false
		}

		for (index, dataRow) in sortedDataSource.enumerated() {

			let formattedBirthDate: String = Formatter().getDateFrom(dateString8601: dataRow.identity.birthDateString)
				.map(printDateFormatter.string) ?? dataRow.identity.birthDateString
			let formattedShotDate: String = dataRow.event.vaccination?.dateString
				.flatMap(Formatter().getDateFrom)
				.map(printDateFormatter.string) ?? (dataRow.event.vaccination?.dateString ?? "")

			let domesticIdentity = dataRow.identity
				.mapIdentity(months: String.shortMonths)
				.map({ $0.isEmpty ? "_" : $0 })
				.joined(separator: " ")

			rows.append(
				ListEventsViewController.Row(
					title: String(format: .holderVaccinationElementTitle, "\(index + 1)"),
					subTitle: String(
						format: .holderVaccinationElementSubTitle,
						dataRow.identity.fullName,
						formattedBirthDate
					),
					action: { [weak self] in

						self?.coordinator?.listEventsScreenDidFinish(
							.moreInformation(
								title: .holderVaccinationAboutTitle,
								body: String(
									format: .holderVaccinationAboutBody,
									domesticIdentity,
									dataRow.identity.fullName,
									formattedBirthDate,
									dataRow.event.vaccination?.brand ?? "-",
									"\(index + 1)",
									formattedShotDate
								)
							)
						)
					}
				)
			)
		}

		return rows
	}

	private func getViewState(
		from remoteEvent: [RemoteTestEvent]) -> ListEventsViewController.State {

		if let event = remoteEvent.first {

			switch event.wrapper.status {
				case .complete:
					if let result = event.wrapper.result, result.negativeResult {
						return listTestEventsState(event)
					} else {
						return emptyTestEventsState()
					}
				case .pending:
					return pendingTestEventsState()
				default:
					return emptyTestEventsState()
			}
		}

		return emptyTestEventsState()
	}

	private func pendingTestEventsState() -> ListEventsViewController.State {

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

	private func emptyTestEventsState() -> ListEventsViewController.State {

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

	private func listTestEventsState(_ remoteTestEvent: RemoteTestEvent) -> ListEventsViewController.State {

		var rows = [ListEventsViewController.Row]()
		if let row = getTestRow(remoteTestEvent) {
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

	private func getTestRow(_ remoteTestEvent: RemoteTestEvent) -> ListEventsViewController.Row? {

		guard let result = remoteTestEvent.wrapper.result,
			  let sampleDate = Formatter().getDateFrom(dateString8601: result.sampleDate) else {
			return nil
		}

		let printSampleDate: String = printTestDateFormatter.string(from: sampleDate)
		let expireDate = Calendar.current.date(byAdding: .hour, value: maxValidity, to: sampleDate) ?? sampleDate
		let printExpireDate: String = printTestDateFormatter.string(from: expireDate)

		return ListEventsViewController.Row(
			title: .holderTestResultsNegative,
			subTitle: String(
				format: .holderTestElementSubTitle,
				printSampleDate,
				printExpireDate,
				getDisplayIdentity(result.holder)
			),
			action: { [weak self] in

				self?.coordinator?.listEventsScreenDidFinish(
					.moreInformation(
						title: .holderTestAboutTitle,
						body: .holderTestAboutBody
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
								self?.coordinator?.listEventsScreenDidFinish(.continue)
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

		guard let issueCommitmentMessage = cryptoManager.generateCommitmentMessage(),
			let utf8 = issueCommitmentMessage.data(using: .utf8),
			let stoken = cryptoManager.getStoken()
		else {
			//					onError(ProofError.missingParams)
			return
		}

		let dictionary: [String: AnyObject] = [
			//			"test": generateString(object: wrapper) as AnyObject,
			"stoken": stoken as AnyObject,
			"events": [] as AnyObject,
			"issueCommitmentMessage": utf8.base64EncodedString() as AnyObject
		]

		self.networkManager.fetchGreencards(dictionary: dictionary) { result in
			//				Result<RemoteGreenCards.Response, NetworkError>

			switch result {
				case let .success(greencardResponse):
					self.logDebug("ok: \(greencardResponse)")
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
			walletManager.removeExistingEventGroups(type: .vaccination, providerIdentifier: response.wrapper.providerIdentifier)

			// Store the new vaccination events

			if let maxIssuedAt = response.wrapper.getMaxIssuedAt(dateFormatter) {
				success = success && walletManager.storeEventGroup(
					.vaccination,
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

	// MARK: Store vaccination events

	private func storeTestEvent(
		remoteEvents: [RemoteTestEvent],
		onCompletion: @escaping (Bool) -> Void) {

		var success = true
		for response in remoteEvents where response.wrapper.status == .complete {

			// Remove any existing test events for the provider
			walletManager.removeExistingEventGroups(type: .test, providerIdentifier: response.wrapper.providerIdentifier)

			// Store the new test events
			if let result = response.wrapper.result,
			   let sampleDate = Formatter().getDateFrom(dateString8601: result.sampleDate) {

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
				print(remoteEuGreenCard)
//				success = success && walletManager.storeEuGreenCard(remoteEuGreenCard)
			}
		}

		onCompletion(success)
	}
}
