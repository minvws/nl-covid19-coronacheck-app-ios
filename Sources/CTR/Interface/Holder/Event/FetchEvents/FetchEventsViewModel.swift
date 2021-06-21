/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class FetchEventsViewModel: Logging {

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
				title: eventMode == .vaccination ? L.holderVaccinationListTitle() : L.holderTestListTitle(),
				subTitle: nil,
				actionTitle: nil,
				action: nil
			)
		)

		fetchEventProvidersWithAccessTokens(completion: handleFetchEventProvidersWithAccessTokensResponse)
	}

	func handleFetchEventProvidersWithAccessTokensResponse(response eventProvidersResult: Result<[EventFlow.EventProvider], NetworkError>) {
		switch eventProvidersResult {
			case .failure(let networkError):
				// No error tolerance here, if any failures then bail out.
				self.coordinator?.fetchEventsScreenDidFinish(
					.errorRequiringRestart(
						error: networkError,
						eventMode: self.eventMode
					)
				)

			case .success(let eventProviders):
				// Do the Unomi call
				self.fetchHasEventInformation(
					forEventProviders: eventProviders,
					filter: eventMode.queryFilterValue,
					completion: handleFetchHasEventInformationResponse
				)
		}
	}

	func handleFetchHasEventInformationResponse(
		eventProvidersWithEventInformation: [EventFlow.EventProvider],
		networkErrors: [NetworkError]) {

		let someNetworkWasTooBusy: Bool = networkErrors.contains { $0 == .serverBusy }
		let someNetworkDidError: Bool = !someNetworkWasTooBusy && !networkErrors.isEmpty

		// Needed because we can't present an Alert at the same time as change the navigation stack
		// so sometimes the next step must be triggered as we dismiss the Alert.
		func nextStep() {
			fetchVaccinationEvents(eventProviders: eventProvidersWithEventInformation, filter: eventMode.queryFilterValue, completion: handleFetchVaccinationEventsResponse)
		}

		switch (eventProvidersWithEventInformation.isEmpty, someNetworkWasTooBusy, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy (5.3.0)

				self.navigationAlert = FetchEventsViewController.AlertContent(
					title: .holderFetchEventsErrorNoResultsNetworkWasBusyTitle,
					subTitle: .holderFetchEventsErrorNoResultsNetworkWasBusyMessage,
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: .holderFetchEventsErrorNoResultsNetworkWasBusyButton
				)

			case (true, _, true): // No results and >=1 network had an error (5.5.1)

				self.navigationAlert = FetchEventsViewController.AlertContent(
					title: .holderFetchEventsErrorNoResultsNetworkErrorTitle,
					subTitle: .holderFetchEventsErrorNoResultsNetworkErrorMessage(localizedEventType: eventMode.localized),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: .holderFetchEventsErrorNoResultsNetworkErrorButton
				)

			case (false, true, _): // Some results and >=1 network was busy (5.5.3)

				self.navigationAlert = FetchEventsViewController.AlertContent(
					title: .holderFetchEventsWarningSomeResultsNetworkWasBusyTitle,
					subTitle: .holderFetchEventsWarningSomeResultsNetworkWasBusyMessage,
					okAction: { _ in
						nextStep()
					},
					okTitle: .ok
				)

			case (false, _, true): // Some results and >=1 network had an error (5.5.3)

			   self.navigationAlert = FetchEventsViewController.AlertContent(
				title: .holderFetchEventsWarningSomeResultsNetworkErrorTitle,
				subTitle: .holderFetchEventsWarningSomeResultsNetworkErrorMessage,
				   okAction: { _ in
					   nextStep()
				   },
				okTitle: .ok
			   )

			// No results and yet no errors:
			case (true, false, false):

				self.viewState = self.emptyEventsState()

			// 🥳 Some results and no network was busy or had an error:
			case (false, false, false):
				nextStep()
		}
	}

	func handleFetchVaccinationEventsResponse(remoteEvents: [RemoteEvent], networkErrors: [NetworkError]) {

		let someNetworkWasTooBusy: Bool = networkErrors.contains { $0 == .serverBusy }
		let someNetworkDidError: Bool = !someNetworkWasTooBusy && !networkErrors.isEmpty

		// Needed because we can't present an Alert at the same time as change the navigation stack
		// so sometimes the next step must be triggered as we dismiss the Alert.
		func nextStep() {
			self.coordinator?.fetchEventsScreenDidFinish(.showEvents(events: remoteEvents, eventMode: self.eventMode))
		}

		switch (remoteEvents.isEmpty, someNetworkWasTooBusy, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy (5.3.0)

				self.navigationAlert = FetchEventsViewController.AlertContent(
					title: .holderFetchEventsErrorNoResultsNetworkWasBusyTitle,
					subTitle: .holderFetchEventsErrorNoResultsNetworkWasBusyMessage,
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: .holderFetchEventsErrorNoResultsNetworkWasBusyButton
				)

			case (true, _, true): // No results and >=1 network had an error (5.5.1)

				self.navigationAlert = FetchEventsViewController.AlertContent(
					title: .holderFetchEventsErrorNoResultsNetworkErrorTitle,
					subTitle: .holderFetchEventsErrorNoResultsNetworkErrorMessage(localizedEventType: eventMode.localized),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: .holderFetchEventsErrorNoResultsNetworkErrorButton
				)

			case (false, true, _): // Some results and >=1 network was busy (5.5.3)

				self.navigationAlert = FetchEventsViewController.AlertContent(
					title: .holderFetchEventsWarningSomeResultsNetworkWasBusyTitle,
					subTitle: .holderFetchEventsWarningSomeResultsNetworkWasBusyMessage,
					okAction: { _ in
						nextStep()
					},
					okTitle: .ok
				)

			case (false, _, true): // Some results and >=1 network had an error (5.5.3)

			   self.navigationAlert = FetchEventsViewController.AlertContent(
				title: .holderFetchEventsWarningSomeResultsNetworkErrorTitle,
				subTitle: .holderFetchEventsWarningSomeResultsNetworkErrorMessage,
				   okAction: { _ in
					   nextStep()
				   },
					okTitle: .ok
			   )

			// No results and yet no errors:
			case (true, false, false):

				self.viewState = self.emptyEventsState()

			// 🥳 Some results and no network was busy or had an error:
			case (false, false, false):

				nextStep()
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

	private func fetchEventProvidersWithAccessTokens(
		completion: @escaping (Result<[EventFlow.EventProvider], NetworkError>) -> Void) {

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
					if self.eventMode == .test {
						// only retrieve negative test 3.0 from the GGD
						eventProviders = eventProviders.filter { $0.identifier.lowercased() == "ggd" }
					}
					completion(.success(eventProviders))

				case (.failure(let error), _):
					self.logError("Error getting access tokens: \(error)")
					completion(.failure(error))

				case (_, .failure(let error)):
					self.logError("Error getting event providers: \(error)")
					completion(.failure(error))

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
		completion: @escaping ([EventFlow.EventProvider], [NetworkError]) -> Void) {

		var eventInformationAvailableResults = [Result<EventFlow.EventInformationAvailable, NetworkError>]()

		for provider in eventProviders {
			guard let url = provider.unomiURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https") else { continue }

			hasEventInformationFetchingGroup.enter()
			fetchHasEventInformationResponse(from: provider, filter: filter) { result in
				eventInformationAvailableResults += [result]
				self.hasEventInformationFetchingGroup.leave()
			}
		}

		hasEventInformationFetchingGroup.notify(queue: DispatchQueue.main) {

			// Process successes:
			let successfulEventInformationAvailable = eventInformationAvailableResults.compactMap { $0.successValue }
			let outputEventProviders = eventProviders.map { eventProvider -> EventFlow.EventProvider in
				var eventProvider = eventProvider
				for response in successfulEventInformationAvailable where eventProvider.identifier == response.providerIdentifier {
					eventProvider.eventInformationAvailable = response
				}
				return eventProvider
			}

			// Process failures:
			let failuresExperienced = eventInformationAvailableResults.compactMap { $0.failureError }

			completion(outputEventProviders, failuresExperienced)
		}
	}

	private func fetchHasEventInformationResponse(
		from provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, NetworkError>) -> Void) {

		self.logInfo("eventprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

		progressIndicationCounter.increment()
		networkManager.fetchEventInformation(provider: provider, filter: filter) { [weak self] result in

			// Result<(EventFlow.EventInformationAvailable, SignedResponse), NetworkError>
			switch result {
				case let .success(result):
					self?.logDebug("EventInformationAvailable: \(result.0)")
					completion(.success(result.0))
				case let .failure(error):
					completion(.failure(error))
			}

			self?.progressIndicationCounter.decrement()
		}
	}

	// MARK: Fetch vaccination events

	private func fetchVaccinationEvents(
		eventProviders: [EventFlow.EventProvider],
		filter: String?,
		completion: @escaping ([RemoteEvent], [NetworkError]) -> Void) {

		var eventResponseResults = [Result<RemoteEvent, NetworkError>]()

		for provider in eventProviders {

			if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
			   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

				eventFetchingGroup.enter()
				fetchVaccinationEvent(from: provider, filter: filter) { result in
					eventResponseResults += [result.map({ ($0, $1) })]
					self.eventFetchingGroup.leave()
				}
			}
		}

		eventFetchingGroup.notify(queue: DispatchQueue.main) {
			// Process successes:
			let successfulEventResponses = eventResponseResults.compactMap { $0.successValue }

			// Process failures:
			let failuresExperienced = eventResponseResults.compactMap { $0.failureError }

			completion(successfulEventResponses, failuresExperienced)
		}
	}

	private func fetchVaccinationEvent(
		from provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {

		progressIndicationCounter.increment()

		networkManager.fetchEvents(provider: provider, filter: filter) { [weak self] result in
			// (Result<(TestResultWrapper, SignedResponse), NetworkError>
			completion(result)

			self?.progressIndicationCounter.decrement()
		}
	}
}

private extension EventMode {

	/// Translate EventMode into a string that can be passed to the network as a query string
	var queryFilterValue: String {
		switch self {
			case .recovery: return "recovery"
			case .test: return "negativetest"
			case .vaccination: return "vaccination"
		}
	}
}
