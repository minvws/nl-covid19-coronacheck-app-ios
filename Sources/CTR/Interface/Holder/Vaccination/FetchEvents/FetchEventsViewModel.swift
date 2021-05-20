/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class FetchEventsViewModel: Logging {

	weak var coordinator: VaccinationCoordinatorDelegate?

	// Resulting token from DigiD VWS
	private var tvsToken: String
	private var networkManager: NetworkManaging
	private var walletManager: WalletManaging

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

	@Bindable internal var viewState: FetchEventsViewController.State

	@Bindable private(set) var navigationAlert: FetchEventsViewController.AlertContent?

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: VaccinationCoordinatorDelegate,
		tvsToken: String,
		networkManager: NetworkManaging = Services.networkManager,
		walletManager: WalletManaging = WalletManager()) {
		self.coordinator = coordinator
		self.tvsToken = tvsToken
		self.networkManager = networkManager
		self.walletManager = walletManager

		viewState = .loading(
			content: FetchEventsViewController.Content(
				title: .holderVaccinationLoadingTitle,
				subTitle: nil,
				actionTitle: nil,
				action: nil
			)
		)
		startFetchingEventProvidersWithAccessTokens { eventProviders in
			self.fetchHasEventInformation(eventProviders: eventProviders) { eventProvidersWithEventInformation in
				self.fetchVaccinationEvents(eventProviders: eventProvidersWithEventInformation) { eventResponses in
					self.storeVaccinationEvent(eventResponses: eventResponses) { saved in
						self.logInfo("Finished vaccination flow: \(saved)")
						self.viewState = self.getViewState(from: eventResponses)
					}
				}
			}
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

		navigationAlert = FetchEventsViewController.AlertContent(
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

		coordinator?.fetchEventsScreenDidFinish(.back)
	}

	// MARK: State Helpers

	private func getViewState(
		from eventResponses: [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)]) -> FetchEventsViewController.State {

		var listDataSource = [(Vaccination.Identity, Vaccination.Event)]()

		for eventResponse in eventResponses {
			let identity = eventResponse.wrapper.identity
			for event in eventResponse.wrapper.events {
				listDataSource.append((identity, event))
			}
		}

		if listDataSource.isEmpty {
			return emptyEventsState()
		} else {
			return listEventsState(listDataSource)
		}
	}

	private func emptyEventsState() -> FetchEventsViewController.State {

		return .emptyEvents(
			content: FetchEventsViewController.Content(
				title: .holderVaccinationNoListTitle,
				subTitle: .holderVaccinationNoListMessage,
				actionTitle: .holderVaccinationNoListActionTitle,
				action: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				}
			)
		)
	}

	private func listEventsState(_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)]) -> FetchEventsViewController.State {

		return .listEvents(
			content: FetchEventsViewController.Content(
				title: .holderVaccinationListTitle,
				subTitle: .holderVaccinationListMessage,
				actionTitle: .holderVaccinationListActionTitle,
				action: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				}
			),
			rows: getSortedRowsFromEvents(dataSource)
		)
	}

	func getSortedRowsFromEvents(_ dataSource: [(identity: Vaccination.Identity, event: Vaccination.Event)]) -> [FetchEventsViewController.Row] {

		var rows = [FetchEventsViewController.Row]()

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
				FetchEventsViewController.Row(
					title: String(format: .holderVaccinationElementTitle, "\(index + 1)"),
					subTitle: String(format: .holderVaccinationElementSubTitle, formattedDate),
					action: { [weak self] in

						self?.coordinator?.fetchEventsScreenDidFinish(
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

	// MARK: Fetch access tokens and event providers

	private func startFetchingEventProvidersWithAccessTokens(
		_ onCompletion: @escaping ([Vaccination.EventProvider]) -> Void) {

		var accessTokenResult: Result<[Vaccination.AccessToken], NetworkError>?
		fetchVaccinationAccessTokens { result in
			accessTokenResult = result
		}

		var vaccinationEventProvidersResult: Result<[Vaccination.EventProvider], NetworkError>?
		fetchVaccinationEventProviders { result in
			vaccinationEventProvidersResult = result
		}

		prefetchingGroup.notify(queue: DispatchQueue.main) {

			switch (accessTokenResult, vaccinationEventProvidersResult) {
				case (.success(let accessTokens), .success(let eventProviders)):
					var eventProviders = eventProviders // mutable
					for index in 0 ..< eventProviders.count {
						for accessToken in accessTokens where eventProviders[index].identifier == accessToken.providerIdentifier {
							eventProviders[index].accessToken = accessToken
						}
					}
					onCompletion(eventProviders)

				case (.failure(let error), _):
					self.logError("Error getting access tokens: \(error)")

				case (_, .failure(let error)):
					self.logError("Error getting event providers: \(error)")

				default:
					// this should not happen due to the prefetching group
					self.logError("Unexpected: did not receive response from accessToken or eventProviders call")
			}
		}
	}

	private func fetchVaccinationAccessTokens(completion: @escaping (Result<[Vaccination.AccessToken], NetworkError>) -> Void) {

		prefetchingGroup.enter()
		progressIndicationCounter.increment()
		networkManager.fetchVaccinationAccessTokens(tvsToken: tvsToken) { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
			self?.prefetchingGroup.leave()
		}
	}

	private func fetchVaccinationEventProviders(completion: @escaping (Result<[Vaccination.EventProvider], NetworkError>) -> Void) {

		prefetchingGroup.enter()
		progressIndicationCounter.increment()
		networkManager.fetchVaccinationEventProviders { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
			self?.prefetchingGroup.leave()
		}
	}

	// MARK: Fetch event information

	private func fetchHasEventInformation(eventProviders: [Vaccination.EventProvider], onCompletion: @escaping ([Vaccination.EventProvider]) -> Void) {

		var eventInformationAvailableResults = [Vaccination.EventInformationAvailable]()

		for provider in eventProviders {
			fetchHasEventInformationResponse(from: provider) { result in
				switch result {
					case let .failure(error):
						self.logError("Error getting unomi: \(error)")
					case let .success(response):
						eventInformationAvailableResults.append(response)
				}
			}
		}

		hasEventInformationFetchingGroup.notify(queue: DispatchQueue.main) {
			var outputEventProviders = eventProviders

			for index in 0 ..< eventProviders.count {
				for response in eventInformationAvailableResults where eventProviders[index].identifier == response.providerIdentifier {
					outputEventProviders[index].eventInformationAvailable = response
				}
			}
			onCompletion(outputEventProviders)
		}
	}

	private func fetchHasEventInformationResponse(
		from provider: Vaccination.EventProvider,
		completion: @escaping (Result<Vaccination.EventInformationAvailable, NetworkError>) -> Void) {

		if let url = provider.unomiURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https") {

			self.logInfo("evenprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

			progressIndicationCounter.increment()
			hasEventInformationFetchingGroup.enter()
			networkManager.fetchVaccinationEventInformation(provider: provider) { [weak self] result in
				// Result<Vaccination.EventInformationAvailable, NetworkError>
				completion(result)
				self?.progressIndicationCounter.decrement()
				self?.hasEventInformationFetchingGroup.leave()
			}
		}
	}

	// MARK: Fetch vaccination events

	private func fetchVaccinationEvents(
		eventProviders: [Vaccination.EventProvider],
		onCompletion: @escaping ( [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)]) -> Void) {

		var eventResponses = [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)]()

		for provider in eventProviders {
			fetchVaccinationEvent(from: provider) { result in
				switch result {
					case let .failure(error):
						self.logError("Error getting event: \(error)")
					case let .success(response):
						eventResponses.append(response)
				}
			}
		}

		eventFetchingGroup.notify(queue: DispatchQueue.main) {
			onCompletion(eventResponses)
		}
	}

	private func fetchVaccinationEvent(
		from provider: Vaccination.EventProvider,
		completion: @escaping (Result<(Vaccination.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {

		if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
		   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

			progressIndicationCounter.increment()
			eventFetchingGroup.enter()
			networkManager.fetchVaccinationEvents(provider: provider) { [weak self] result in
				// (Result<(TestResultWrapper, SignedResponse), NetworkError>
				completion(result)
				self?.progressIndicationCounter.decrement()
				self?.eventFetchingGroup.leave()
			}
		}
	}

	// MARK: Store vaccination events

	private func storeVaccinationEvent(
		eventResponses: [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)],
		onCompletion: @escaping (Bool) -> Void) {

		var success = true
		for response in eventResponses where response.wrapper.status == .complete {

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
