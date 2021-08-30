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

	@Bindable private(set) var alert: AlertContent?

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
			content: Content(
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
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)

		fetchEventProvidersWithAccessTokens(completion: handleFetchEventProvidersWithAccessTokensResponse)
	}

	func handleFetchEventProvidersWithAccessTokensResponse(eventProviders: [EventFlow.EventProvider], errorCodes: [ErrorCode], serverErrors: [ServerError]) {

		// No error tolerance here, if any failures then bail out.
		if !errorCodes.isEmpty || !serverErrors.isEmpty {
			handleErrorCodes(errorCodes, serverErrors: serverErrors)
			return
		}

		self.mappingManager.setEventProviders(eventProviders)

		// Do the Unomi call
		self.fetchHasEventInformation(
			forEventProviders: eventProviders,
			filter: eventMode.queryFilterValue,
			completion: handleFetchHasEventInformationResponse
		)
	}

	func handleFetchHasEventInformationResponse(
		eventProvidersWithEventInformation: [EventFlow.EventProvider],
		networkErrors: [NetworkError]) {

		let someNetworkWasTooBusy: Bool = networkErrors.contains { $0 == .serverBusy }
		let someNetworkDidError: Bool = !someNetworkWasTooBusy && !networkErrors.isEmpty
		let networkOffline: Bool = networkErrors.contains { $0 == .noInternetConnection || $0 == .requestTimedOut }

		guard !networkOffline else {
			displayNoInternet()
			return
		}

		// Needed because we can't present an Alert at the same time as change the navigation stack
		// so sometimes the next step must be triggered as we dismiss the Alert.
		func nextStep() {
			fetchRemoteEvents(eventProviders: eventProvidersWithEventInformation, filter: eventMode.queryFilterValue, completion: handleFetchEventsResponse)
		}

		switch (eventProvidersWithEventInformation.isEmpty, someNetworkWasTooBusy, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy (5.3.0)

				self.alert = AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyMessage(),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyButton()
				)

			case (true, _, true): // No results and >=1 network had an error (5.5.1)

				self.alert = AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkerrorTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkerrorButton()
				)

			case (false, true, _): // Some results and >=1 network was busy (5.5.3)

				self.alert = AlertContent(
					title: L.holderFetcheventsWarningSomeresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsWarningSomeresultsNetworkwasbusyMessage(),
					okAction: { _ in
						nextStep()
					},
					okTitle: L.generalOk()
				)

			case (false, _, true): // Some results and >=1 network had an error (5.5.3)

				self.alert = AlertContent(
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

	func handleFetchEventsResponse(remoteEvents: [RemoteEvent], networkErrors: [NetworkError]) {

		let someNetworkWasTooBusy: Bool = networkErrors.contains { $0 == .serverBusy }
		let someNetworkDidError: Bool = !someNetworkWasTooBusy && !networkErrors.isEmpty
		let networkOffline: Bool = networkErrors.contains { $0 == .noInternetConnection || $0 == .requestTimedOut }
		
		guard !networkOffline else {
			displayNoInternet()
			return
		}

		// Needed because we can't present an Alert at the same time as change the navigation stack
		// so sometimes the next step must be triggered as we dismiss the Alert.
		func nextStep() {
			self.coordinator?.fetchEventsScreenDidFinish(.showEvents(events: remoteEvents, eventMode: self.eventMode))
		}

		switch (remoteEvents.isEmpty, someNetworkWasTooBusy, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy (5.3.0)

				self.alert = AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyMessage(),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkwasbusyButton()
				)

			case (true, _, true): // No results and >=1 network had an error (5.5.1)

				self.alert = AlertContent(
					title: L.holderFetcheventsErrorNoresultsNetworkerrorTitle(),
					subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
					okAction: { _ in
						self.coordinator?.fetchEventsScreenDidFinish(.stop)
					},
					okTitle: L.holderFetcheventsErrorNoresultsNetworkerrorButton()
				)

			case (false, true, _): // Some results and >=1 network was busy (5.5.3)

				self.alert = AlertContent(
					title: L.holderFetcheventsWarningSomeresultsNetworkwasbusyTitle(),
					subTitle: L.holderFetcheventsWarningSomeresultsNetworkwasbusyMessage(),
					okAction: { _ in
						nextStep()
					},
					okTitle: L.generalOk()
				)

			case (false, _, true): // Some results and >=1 network had an error (5.5.3)

			   self.alert = AlertContent(
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

		switch viewState {
			case .loading:
				warnBeforeGoBack()
			case .feedback:
				goBack()
		}

	}

	func warnBeforeGoBack() {

		alert = AlertContent(
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
		completion: @escaping ([EventFlow.EventProvider], [ErrorCode], [ServerError]) -> Void) {

		var accessTokenResult: Result<[EventFlow.AccessToken], ServerError>?
		prefetchingGroup.enter()
		fetchEventAccessTokens { result in
			accessTokenResult = result
			self.prefetchingGroup.leave()
		}

		var remoteEventProvidersResult: Result<[EventFlow.EventProvider], ServerError>?
		prefetchingGroup.enter()
		fetchEventProviders { result in
			remoteEventProvidersResult = result
			self.prefetchingGroup.leave()
		}

		prefetchingGroup.notify(queue: DispatchQueue.main) {

			var errorCodes = [ErrorCode]()
			var serverErrors = [ServerError]()
			var providers = [EventFlow.EventProvider]()

			switch (accessTokenResult, remoteEventProvidersResult) {
				case (.success(let accessTokens), .success(let eventProviders)):
					providers = eventProviders // mutable
					for index in 0 ..< providers.count {
						for accessToken in accessTokens where providers[index].identifier == accessToken.providerIdentifier {
							providers[index].accessToken = accessToken
						}
					}
					if self.eventMode == .test || self.eventMode == .recovery {
						// only retrieve negative / positive test 3.0 from the GGD
						providers = providers.filter { $0.identifier.lowercased() == "ggd" }
					}
				case (.failure(let accessError), .failure(let providerError)):
					self.logError("Error getting access tokens: \(accessError)")
					if let code = self.convert(accessError, step: .accessTokens) {
						errorCodes.append(code)
					}
					serverErrors.append(accessError)

					self.logError("Error getting access tokens: \(providerError)")
					if let code = self.convert(providerError, step: .providers) {
						errorCodes.append(code)
					}
					serverErrors.append(providerError)

				case (.failure(let accessError), _):
					self.logError("Error getting access tokens: \(accessError)")
					if let code = self.convert(accessError, step: .accessTokens) {
						errorCodes.append(code)
					}
					serverErrors.append(accessError)

				case (_, .failure(let providerError)):
					self.logError("Error getting event providers: \(providerError)")
					if let code = self.convert(providerError, step: .providers) {
						errorCodes.append(code)
					}
					serverErrors.append(providerError)

				default:
					// this should not happen due to the prefetching group
					self.logError("Unexpected: did not receive response from accessToken or eventProviders call")
			}
			completion(providers, errorCodes, serverErrors)
		}
	}

	private func convert(_ serverError: ServerError, step: ErrorCode.Step) -> ErrorCode? {

		if case let ServerError.error(statusCode, serverResponse, error) = serverError {
			return ErrorCode(
				flow: flow,
				step: step,
				errorCode: error.getClientErrorCode() ?? "\(statusCode ?? 000)",
				detailedCode: serverResponse?.code
			)
		}
		return nil
	}

	private var flow: ErrorCode.Flow {

		switch eventMode {
			case .vaccination:
				return .vaccination
			case .paperflow:
				return .hkvi
			case .recovery:
				return .recovery
			case .test:
				return .ggdTest
		}

	}

	private func fetchEventAccessTokens(completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void) {

		progressIndicationCounter.increment()
		networkManager.fetchEventAccessTokens(tvsToken: tvsToken) { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
		}
	}

	private func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], ServerError>) -> Void) {

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

		self.logDebug("eventprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

		progressIndicationCounter.increment()
		networkManager.fetchEventInformation(provider: provider, filter: filter) { [weak self] result in
			// Result<EventFlow.EventInformationAvailable, NetworkError>

			if case let .success(info) = result {
				self?.logDebug("EventInformationAvailable: \(info)")
			}
			completion(result)
			self?.progressIndicationCounter.decrement()
		}
	}

	// MARK: Fetch remote events

	private func fetchRemoteEvents(
		eventProviders: [EventFlow.EventProvider],
		filter: String?,
		completion: @escaping ([RemoteEvent], [NetworkError]) -> Void) {

		var eventResponseResults = [Result<RemoteEvent, NetworkError>]()

		for provider in eventProviders {

			if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
			   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

				eventFetchingGroup.enter()
				fetchRemoteEvent(from: provider, filter: filter) { result in
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

	private func fetchRemoteEvent(
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

extension FetchEventsViewModel {

	static let detailedCodeNoBSN: Int = 99782
	static let detailedCodeSessionExpired: Int = 99708
}

// MARK: - Error states

private extension FetchEventsViewModel {

	func handleErrorCodes(_ errorCodes: [ErrorCode], serverErrors: [ServerError]) {

		let hasNoBSN = !errorCodes.filter { $0.detailedCode == FetchEventsViewModel.detailedCodeNoBSN }.isEmpty
		let sessionExpired = !errorCodes.filter { $0.detailedCode == FetchEventsViewModel.detailedCodeSessionExpired }.isEmpty
		let requestTimedOut = !serverErrors.filter { serverError in
			if case let ServerError.error(_, _, error) = serverError {
				return error == .requestTimedOut
			}
			return false
		}.isEmpty
		let serverBusy = !serverErrors.filter { serverError in
			if case let ServerError.error(_, _, error) = serverError {
				return error == .serverBusy
			}
			return false
		}.isEmpty
		let noInternet = !serverErrors.filter { serverError in
			if case let ServerError.error(_, _, error) = serverError {
				return error == .noInternetConnection
			}
			return false
		}.isEmpty

		if hasNoBSN {
			displayNoBSN()
		} else if sessionExpired {
			displaySessionExpired()
		} else if requestTimedOut {
			displayRequestTimedOut()
		} else if serverBusy {
			displayServerBusy()
		} else if noInternet {
			displayNoInternet()
		} else {
			displayErrorCode(errorCodes)
		}
	}

	func displayNoBSN() {

		viewState = .feedback(
			content: Content(
				title: L.holderErrorstateNobsnTitle(),
				subTitle: L.holderErrorstateNobsnMessage(),
				primaryActionTitle: L.holderErrorstateNobsnAction(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	func displaySessionExpired() {

		viewState = .feedback(
			content: Content(
				title: L.holderErrorstateNosessionTitle(),
				subTitle: L.holderErrorstateNosessionMessage(),
				primaryActionTitle: L.holderErrorstateNosessionAction(),
				primaryAction: { [weak self] in
					self?.goBack()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	func displayRequestTimedOut() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.holderErrorstateTitle(),
			subTitle: L.generalErrorServerUnreachable(),
			cancelAction: { _ in
				self.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				guard let self = self else { return }
				self.fetchEventProvidersWithAccessTokens(completion: self.handleFetchEventProvidersWithAccessTokensResponse)
			},
			okTitle: L.generalRetry()
		)
	}

	func displayServerBusy() {

		viewState = .feedback(
			content: Content(
				title: L.generalNetworkwasbusyTitle(),
				subTitle: L.generalNetworkwasbusyText(),
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)
	}

	func displayErrorCode(_ errorCodes: [ErrorCode]) {

		// Other error:
		var subTitle: String
		if errorCodes.count == 1 {
			if errorCodes[0].errorCode.starts(with: "0") {
				subTitle = L.holderErrorstateClientMessage("\(errorCodes[0])")
			} else {
				subTitle = L.holderErrorstateServerMessage("\(errorCodes[0])")
			}
		} else {
			let lineBreak = "<br />"
			let errorString = errorCodes.map { "\($0)\(lineBreak)" }.reduce("", +).dropLast(lineBreak.count)
			subTitle = L.holderErrorstateServerMessages("\(errorString)")
		}

		viewState = .feedback(
			content: Content(
				title: L.holderErrorstateTitle(),
				subTitle: subTitle,
				primaryActionTitle: L.generalNetworkwasbusyButton(),
				primaryAction: { [weak self] in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
				secondaryAction: { [weak self] in
					guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else {
						return
					}

					self?.coordinator?.openUrl(url, inApp: true)
				}
			)
		)
	}

	func displayNoInternet() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: { _ in
				self.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				guard let self = self else { return }
				self.fetchEventProvidersWithAccessTokens(completion: self.handleFetchEventProvidersWithAccessTokensResponse)
			},
			okTitle: L.generalRetry()
		)
	}
}
