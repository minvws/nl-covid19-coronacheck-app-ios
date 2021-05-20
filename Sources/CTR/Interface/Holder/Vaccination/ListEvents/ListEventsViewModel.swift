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
		dateFormatter.dateFormat = "EEEE d MMMM"
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
				actionTitle: nil,
				action: nil
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
				actionTitle: .holderVaccinationNoListActionTitle,
				action: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				}
			)
		)
	}

	private func listEventsState(_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)], remoteEvents: [RemoteVaccinationEvent]) -> ListEventsViewController.State {

		return .listEvents(
			content: ListEventsViewController.Content(
				title: .holderVaccinationListTitle,
				subTitle: .holderVaccinationListMessage,
				actionTitle: .holderVaccinationListActionTitle,
				action: { [weak self] in
					self?.saveAndSignTheEvents(remoteEvents: remoteEvents)

				}
			),
			rows: getSortedRowsFromEvents(dataSource)
		)
	}

	func getSortedRowsFromEvents(_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)]) -> [ListEventsViewController.Row] {

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

			let formattedDate: String = Formatter().getDateFrom(dateString8601: dataRow.event.vaccination.dateString ?? "")
				.map {
					printDateFormatter.string(from: $0)
				} ?? ""

			rows.append(
				ListEventsViewController.Row(
					title: String(format: .holderVaccinationElementTitle, "\(index + 1)"),
					subTitle: String(format: .holderVaccinationElementSubTitle, formattedDate),
					action: { [weak self] in

						self?.coordinator?.listEventsScreenDidFinish(
							.details(
								title: .holderVaccinationAboutTitle,
								body: .holderVaccinationAboutBody
							)
						)
					}
				)
			)
		}

		return rows
	}

	// MARK: Sign the events

	private func saveAndSignTheEvents( remoteEvents: [RemoteVaccinationEvent]) {

		self.storeVaccinationEvent(remoteEvents: remoteEvents) { saved in
			self.logInfo("Finished vaccination flow: \(saved)")

			self.networkManager.fetchGreencards(dictionary: [:]) { result in
//				Result<GreenCardResponse, NetworkError>

				switch result {
					case let .success(greencardResponse):
						self.logInfo("ok: \(greencardResponse)")
					case let .failure(error):
						self.logError("error: \(error)")
				}

			}

//			self.coordinator?.fetchEventsScreenDidFinish(.stop)
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
}
