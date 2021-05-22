/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ListEventsViewModel: Logging {

	weak var coordinator: EventCoordinatorDelegate?

	private var walletManager: WalletManaging
	private var networkManager: NetworkManaging

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

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListEventsViewController.State

	@Bindable private(set) var navigationAlert: ListEventsViewController.AlertContent?

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate,
		remoteVaccinationEvents: [RemoteVaccinationEvent],
		networkManager: NetworkManaging = Services.networkManager,
		walletManager: WalletManaging = WalletManager()) {

		self.coordinator = coordinator
		self.networkManager = networkManager
		self.walletManager = walletManager

		viewState = .loading(
			content: ListEventsViewController.Content(
				title: .holderVaccinationLoadingTitle,
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
		viewState = getViewState(from: remoteVaccinationEvents)
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

		navigationAlert = ListEventsViewController.AlertContent(
			title: .holderVaccinationAlertTitle,
			subTitle: .holderVaccinationAlertMessage,
			cancelAction: nil,
			cancelTitle: .holderVaccinationAlertCancel,
			okAction: { _ in
				self.goBack()
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
			return emptyEventsState()
		} else {
			return listEventsState(listDataSource, remoteEvents: remoteEvents)
		}
	}

	private func emptyEventsState() -> ListEventsViewController.State {

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

	private func listEventsState(_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)], remoteEvents: [RemoteVaccinationEvent]) -> ListEventsViewController.State {

		return .listEvents(
			content: ListEventsViewController.Content(
				title: .holderVaccinationListTitle,
				subTitle: .holderVaccinationListMessage,
				primaryActionTitle: .holderVaccinationListActionTitle,
				primaryAction: { [weak self] in
					self?.userWantsToMakeQR(remoteEvents: remoteEvents)
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
			if let lhsDate = lhs.event.vaccination.getDate(with: dateFormatter),
			   let rhsDate = rhs.event.vaccination.getDate(with: dateFormatter) {
				return lhsDate < rhsDate
			}
			return false
		}

		for (index, dataRow) in sortedDataSource.enumerated() {

			let formattedBirthDate: String = Formatter().getDateFrom(dateString8601: dataRow.identity.birthDateString)
				.map {
					printDateFormatter.string(from: $0)
				} ?? dataRow.identity.birthDateString
			let formattedShotDate: String = Formatter().getDateFrom(dateString8601: dataRow.event.vaccination.dateString ?? "")
				.map {
					printDateFormatter.string(from: $0)
				} ?? (dataRow.event.vaccination.dateString ?? "")

			let domesticIdentity = dataRow.identity
				.mapIdentity(months: String.shortMonths)
				.map({ $0.isEmpty ? "_" : $0 })
				.joined(separator: " ")

			rows.append(
				ListEventsViewController.Row(
					title: String(format: .holderVaccinationElementTitle, "\(index + 1)"),
					subTitle: String(format: .holderVaccinationElementSubTitle, dataRow.identity.fullName, formattedBirthDate),
					action: { [weak self] in

						self?.coordinator?.listEventsScreenDidFinish(
							.moreInformation(
								title: .holderVaccinationAboutTitle,
								body: String(format: .holderVaccinationAboutBody, domesticIdentity, dataRow.identity.fullName, formattedBirthDate, dataRow.event.vaccination.brand ?? "-", "\(index + 1)", formattedShotDate)
							)
						)
					}
				)
			)
		}

		return rows
	}

	// MARK: Sign the events

	private func userWantsToMakeQR(remoteEvents: [RemoteVaccinationEvent]) {

		storeVaccinationEvent(remoteEvents: remoteEvents) { saved in
			self.logInfo("Finished vaccination flow: \(saved)")

			self.fetchGreenCards { [weak self] response in
				if let greenCardResponse = response {

					self?.storeGreenCards(response: greenCardResponse, onCompletion: { greenCardsSaved in

						if greenCardsSaved {
							self?.coordinator?.fetchEventsScreenDidFinish(.stop)
						} else {
							self?.logError("Failed to save greenCards")
						}
					})
				} else {
					self?.logError("No greencards")
				}
			}
		}
	}

	private func fetchGreenCards(_ onCompletion: @escaping (RemoteGreenCards.Response?) -> Void) {

			self.networkManager.fetchGreencards(dictionary: [:]) { result in
//				Result<RemoteGreenCards.Response, NetworkError>

				switch result {
					case let .success(greencardResponse):
						self.logInfo("ok: \(greencardResponse)")
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

	// MARK: Store green cards

	private func storeGreenCards(
		response: RemoteGreenCards.Response,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		walletManager.removeExistingGreenCards()

		if let domestic = response.domesticGreenCard {
			success = success && walletManager.storeDomesticGreenCard(domestic)
		}
		if let remoteEuGreenCards = response.euGreenCards {
			for remoteEuGreenCard in remoteEuGreenCards {
				success = success && walletManager.storeEuGreenCard(remoteEuGreenCard)
			}
		}

		onCompletion(success)
	}
}
