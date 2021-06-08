/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class FetchEventsViewModel: Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var tvsToken: String
	private var eventMode: EventMode
	private var networkManager: NetworkManaging

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: FetchEventsViewController.State

	@Bindable private(set) var navigationAlert: FetchEventsViewController.AlertContent?

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		tvsToken: String,
		eventMode: EventMode,
		networkManager: NetworkManaging = Services.networkManager) {
		self.coordinator = coordinator
		self.tvsToken = tvsToken
		self.eventMode = eventMode
		self.networkManager = networkManager

		viewState = .loading(
			content: FetchEventsViewController.Content(
				title: eventMode == .vaccination ? .holderVaccinationListTitle : .holderTestListTitle,
				subTitle: nil,
				actionTitle: nil,
				action: nil
			)
		)
		let filter = eventMode == .vaccination ? "vaccination" : "negativetest"
		startFetchingEventProvidersWithAccessTokens { eventProviders in

			// (Unomi call). If there's a 429 here, abort.
			self.fetchHasEventInformation(forEventProviders: eventProviders, filter: filter) { eventProvidersWithEventInformation in

				// Event call. If there's a 429 for one of these, continue.
				self.fetchVaccinationEvents(eventProviders: eventProvidersWithEventInformation, filter: filter) { [self] remoteEvents in

					if remoteEvents.isEmpty {
						self.viewState = self.emptyEventsState()
					} else {
						self.coordinator?.fetchEventsScreenDidFinish(.showEvents(events: remoteEvents, eventMode: self.eventMode))
					}
				}
			}
		}
	}

	func backButtonTapped() {

		switch viewState {
			case .loading:
				warnBeforeGoBack()
			case .emptyEvents:
				goBack()
		}
	}

	func warnBeforeGoBack() {

		navigationAlert = FetchEventsViewController.AlertContent(
			title: .holderVaccinationAlertTitle,
			subTitle: eventMode == .vaccination ? .holderVaccinationAlertMessage : .holderTestResultsAlertMessage,
			cancelAction: nil,
			cancelTitle: .holderVaccinationAlertCancel,
			okAction: { _ in
				self.goBack()
			},
			okTitle: .holderVaccinationAlertOk
		)
	}

	func goBack() {

		coordinator?.fetchEventsScreenDidFinish(.back(eventMode: eventMode))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	// MARK: State Helpers

	private func emptyEventsState() -> FetchEventsViewController.State {

		return .emptyEvents(
			content: FetchEventsViewController.Content(
				title: eventMode == .vaccination ? .holderVaccinationNoListTitle : .holderTestNoListTitle,
				subTitle: eventMode == .vaccination ? .holderVaccinationNoListMessage : .holderTestNoListMessage,
				actionTitle: eventMode == .vaccination ? .holderVaccinationNoListActionTitle : .holderTestNoListActionTitle,
				action: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				}
			)
		)
	}

	// MARK: Fetch access tokens and event providers

	private func startFetchingEventProvidersWithAccessTokens(
		_ onCompletion: @escaping ([EventFlow.EventProvider]) -> Void) {

		var accessTokenResult: Result<[EventFlow.AccessToken], NetworkError>?
		prefetchingGroup.enter()
		fetchEventAccessTokens { result in
			accessTokenResult = result
			self.prefetchingGroup.leave()
		}

		var vaccinationEventProvidersResult: Result<[EventFlow.EventProvider], NetworkError>?
		prefetchingGroup.enter()
		fetchEventProviders { result in
			vaccinationEventProvidersResult = result
			self.prefetchingGroup.leave()
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

	private func fetchEventAccessTokens(completion: @escaping (Result<[EventFlow.AccessToken], NetworkError>) -> Void) {

		progressIndicationCounter.increment()
		networkManager.fetchEventAccessTokens(tvsToken: tvsToken) { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
		}
	}

	private func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], NetworkError>) -> Void) {

		progressIndicationCounter.increment()
		networkManager.fetchEventProviders { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
		}
	}

	// MARK: Fetch event information

	private func fetchHasEventInformation(
		forEventProviders eventProviders: [EventFlow.EventProvider],
		filter: String?,
		onCompletion: @escaping ([EventFlow.EventProvider]) -> Void) {

		var eventInformationAvailableResults = [EventFlow.EventInformationAvailable]()

		for provider in eventProviders {

			hasEventInformationFetchingGroup.enter()
			fetchHasEventInformationResponse(from: provider, filter: filter) { result in
				switch result {
					case let .failure(error):
						self.logError("Error getting unomi: \(error) for \(provider.identifier)")
					case let .success(response):
						eventInformationAvailableResults += [response]
				}
				self.hasEventInformationFetchingGroup.leave()
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
		from provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, NetworkError>) -> Void) {

		if let url = provider.unomiURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https") {

			self.logInfo("eventprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

			progressIndicationCounter.increment()
			networkManager.fetchEventInformation(provider: provider, filter: filter) { [weak self] result in
				// Result<EventFlow.EventInformationAvailable, NetworkError>
				completion(result)
				self?.progressIndicationCounter.decrement()
			}
		}
	}

	// MARK: Fetch vaccination events

	private func fetchVaccinationEvents(
		eventProviders: [EventFlow.EventProvider],
		filter: String?,
		onCompletion: @escaping ( [RemoteVaccinationEvent]) -> Void) {

		var eventResponses = [RemoteVaccinationEvent]()

		for provider in eventProviders {
			eventFetchingGroup.enter()
			fetchVaccinationEvent(from: provider, filter: filter) { result in
				switch result {
					case let .failure(error):
						self.logError("Error getting event: \(error)")
					case let .success(response):
						eventResponses += [response]
				}
				self.eventFetchingGroup.leave()
			}
		}

		eventFetchingGroup.notify(queue: DispatchQueue.main) {
			onCompletion(eventResponses)
		}
	}

	private func fetchVaccinationEvent(
		from provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {

		if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
		   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

			progressIndicationCounter.increment()

			networkManager.fetchEvents(provider: provider, filter: filter) { [weak self] result in
				// (Result<(TestResultWrapper, SignedResponse), NetworkError>
				completion(result)
				self?.progressIndicationCounter.decrement()
			}
		}
	}
}
