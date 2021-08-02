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
	private let mappingManager: MappingManaging

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: FetchEventsViewController.State

	@Bindable private(set) var alert: FetchEventsViewController.AlertContent?

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		tvsToken: String,
		eventMode: EventMode,
		networkManager: NetworkManaging = Services.networkManager,
		mappingManager: MappingManaging = Services.mappingManager) {
		self.coordinator = coordinator
		self.tvsToken = tvsToken
		self.eventMode = eventMode
		self.networkManager = networkManager
		self.mappingManager = mappingManager

		viewState = .loading(
			content: FetchEventsViewController.Content(
				title: {
					switch eventMode {
						case .recovery:
							return L.holderRecoveryListTitle()
						case .test:
							return L.holderTestListTitle()
						case .vaccination:
							return L.holderVaccinationListTitle()
						case .paperflow:
							return "" // Scanned Dcc not a part of this flow.
					}
				}(),
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

				self.mappingManager.setEventProviders(eventProviders)

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
		let networkOffline: Bool = networkErrors.contains { $0 == .noInternetConnection || $0 == .requestTimedOut }

		guard !networkOffline else {
			self.alert = noInternetAlertContent()
			return
		}

		// Needed because we can't present an Alert at the same time as change the navigation stack
		// so sometimes the next step must be triggered as we dismiss the Alert.
		func nextStep() {
			fetchVaccinationEvents(eventProviders: eventProvidersWithEventInformation, filter: eventMode.queryFilterValue, completion: handleFetchEventsResponse)
		}

		switch (eventProvidersWithEventInformation.isEmpty, someNetworkWasTooBusy, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy (5.3.0)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyMessage(),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyButton()
				)

			case (true, _, true): // No results and >=1 network had an error (5.5.1)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkerrorTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkerrorButton()
				)

			case (false, true, _): // Some results and >=1 network was busy (5.5.3)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsWarningSomeresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsWarningSomeresultsNetworkwasbusyMessage(),
					okAction: { _ in
						nextStep()
					},
					okTitle: L.generalOk()
				)

			case (false, _, true): // Some results and >=1 network had an error (5.5.3)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsWarningSomeresultsNetworkerrorTitle(),
					subTitle: L.holderFetcheventsWarningSomeresultsNetworkerrorMessage(),
					okAction: { _ in
						nextStep()
					},
					okTitle: L.generalOk()
				)

			// 🥳 Some or no results and no network was busy or had an error:
			case (_, false, false):
				nextStep()
		}
	}

	private func noInternetAlertContent() -> FetchEventsViewController.AlertContent {

		return FetchEventsViewController.AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			okAction: { _ in
				self.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			okTitle: L.generalOk()
		)
	}

	func handleFetchEventsResponse(remoteEvents: [RemoteEvent], networkErrors: [NetworkError]) {

		let someNetworkWasTooBusy: Bool = networkErrors.contains { $0 == .serverBusy }
		let someNetworkDidError: Bool = !someNetworkWasTooBusy && !networkErrors.isEmpty
		let networkOffline: Bool = networkErrors.contains { $0 == .noInternetConnection || $0 == .requestTimedOut }
		
		guard !networkOffline else {
			self.alert = noInternetAlertContent()
			return
		}

		// Needed because we can't present an Alert at the same time as change the navigation stack
		// so sometimes the next step must be triggered as we dismiss the Alert.
		func nextStep() {
			self.coordinator?.fetchEventsScreenDidFinish(.showEvents(events: remoteEvents, eventMode: self.eventMode))
		}

		switch (remoteEvents.isEmpty, someNetworkWasTooBusy, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy (5.3.0)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyMessage(),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyButton()
				)

			case (true, _, true): // No results and >=1 network had an error (5.5.1)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkerrorTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkerrorButton()
				)

			case (false, true, _): // Some results and >=1 network was busy (5.5.3)

				self.alert = FetchEventsViewController.AlertContent(
					title: L.holderFetcheventsWarningSomeresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsWarningSomeresultsNetworkwasbusyMessage(),
					okAction: { _ in
						nextStep()
					},
					okTitle: L.generalOk()
				)

			case (false, _, true): // Some results and >=1 network had an error (5.5.3)

			   self.alert = FetchEventsViewController.AlertContent(
				title: L.holderFetcheventsWarningSomeresultsNetworkerrorTitle(),
				subTitle: L.holderFetcheventsWarningSomeresultsNetworkerrorMessage(),
				   okAction: { _ in
					   nextStep()
				   },
					okTitle: L.generalOk()
			   )
			// 🥳 Some or no results and no network was busy or had an error:
			case (_, false, false):

				nextStep()
		}
	}

	func backButtonTapped() {

		warnBeforeGoBack()
	}

	func warnBeforeGoBack() {

		alert = FetchEventsViewController.AlertContent(
			title: L.holderVaccinationAlertTitle(),
			subTitle: eventMode == .vaccination
				? L.holderVaccinationAlertMessage()
				: L.holderTestresultsAlertMessage(),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationAlertCancel(),
			okAction: { _ in
				self.goBack()
			},
			okTitle: L.holderVaccinationAlertOk()
		)
	}

	func goBack() {

		coordinator?.fetchEventsScreenDidFinish(.back(eventMode: eventMode))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
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
					if self.eventMode == .test || self.eventMode == .recovery {
						// only retrieve negative / positive test 3.0 from the GGD
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
				for response in successfulEventInformationAvailable {
					if Configuration().getEnvironment() == "production" {
						if eventProvider.identifier == response.providerIdentifier {
							eventProvider.eventInformationAvailable = response
						}
					} else {
						if eventProvider.identifier == response.providerIdentifier ||
							(eventProvider.name == "FakeGGD" && response.providerIdentifier == "ZZZ") {
							eventProvider.eventInformationAvailable = response
						}
					}
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
					if Configuration().getEnvironment() == "production" {
						eventResponseResults += [result.map({ ($0, $1) })]
					} else {
						eventResponseResults += [result.map({ wrapper, signed in
							var mappedWrapper = wrapper
							/// ZZZ is used for both Test and Fake GGD. Overwrite the response with the right identifier
							mappedWrapper.providerIdentifier = provider.identifier
							return (mappedWrapper, signed)
						})]

					}
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
			case .recovery: return "positivetest,recovery"
			case .paperflow: return ""
			case .test: return "negativetest"
			case .vaccination: return "vaccination"
		}
	}
}
