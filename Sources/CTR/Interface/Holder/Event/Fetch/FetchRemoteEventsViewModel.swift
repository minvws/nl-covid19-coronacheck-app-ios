/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

final class FetchRemoteEventsViewModel: Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var tvsToken: TVSAuthorizationToken
	private var eventMode: EventMode
	private let networkManager: NetworkManaging = Current.networkManager
	private let mappingManager: MappingManaging = Current.mappingManager

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: FetchRemoteEventsViewController.State

	@Bindable private(set) var alert: AlertContent?

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		tvsToken: TVSAuthorizationToken,
		eventMode: EventMode) {
		self.coordinator = coordinator
		self.tvsToken = tvsToken
		self.eventMode = eventMode

		viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		fetchEventProvidersWithAccessTokens(completion: handleFetchEventProvidersWithAccessTokensResponse)
	}

	func handleFetchEventProvidersWithAccessTokensResponse(
		eventProviders: [EventFlow.EventProvider],
		errorCodes: [ErrorCode],
		serverErrors: [ServerError]) {

		// No error tolerance here, if any failures then bail out.
		if !errorCodes.isEmpty || !serverErrors.isEmpty {
			handleErrorCodesForAccesTokenAndProviders(errorCodes, serverErrors: serverErrors)
			return
		}

		self.mappingManager.setEventProviders(eventProviders)

		// Do the Unomi call
		self.fetchHasEventInformation(
			forEventProviders: eventProviders,
			completion: handleFetchHasEventInformationResponse
		)
	}

	func handleFetchHasEventInformationResponse(
		eventProvidersWithEventInformation: [EventFlow.EventProvider],
		serverErrors: [ServerError]) {

		determineActionFromResponse(
			hasNoResult: eventProvidersWithEventInformation.isEmpty,
			serverErrors: serverErrors,
			step: .unomi,
			nextAction: { informationMightBeMissing in
				self.fetchRemoteEvents(
					eventProviders: eventProvidersWithEventInformation,
					someInformationMightBeMissing: informationMightBeMissing,
					unomiServerErrors: serverErrors,
					completion: self.handleFetchEventsResponse
				)
			}
		)
	}

	func determineActionFromResponse(
		hasNoResult: Bool,
		serverErrors: [ServerError],
		step: ErrorCode.Step,
		nextAction: @escaping ((_ someEventsMightBeMissing: Bool) -> Void)) {

		let someServerUnreachableErrror: Bool = !serverErrors.filter { serverError in
			switch serverError {
				case let ServerError.error(_, _, error), let ServerError.provider(_, _, _, error):
					return error == .serverBusy ||
						error == .serverUnreachableInvalidHost ||
						error == .serverUnreachableConnectionLost ||
						error == .serverUnreachableTimedOut
			}
		}.isEmpty

		let someNetworkDidError: Bool = !someServerUnreachableErrror && !serverErrors.isEmpty
		let networkOffline: Bool = !serverErrors.filter { serverError in
			switch serverError {
				case let ServerError.error(_, _, error), let ServerError.provider(_, _, _, error):
					return error == .noInternetConnection
			}
		}.isEmpty

		guard !networkOffline else {
			displayNoInternet()
			return
		}

		logVerbose("determineActionFromResponse: hasNoResult: \(hasNoResult), someServerUnreachableErrror: \(someServerUnreachableErrror), someNetworkDidError: \(someNetworkDidError), step: \(step)")

		switch (hasNoResult, someServerUnreachableErrror, someNetworkDidError) {

			case (true, true, _): // No results and >=1 network was busy or timed out
				displayServerUnreachable()

			case (true, _, true): // No results and >=1 network had an error
				let errorCodes = mapServerErrors(serverErrors, for: eventMode.flow, step: step)
				displayErrorCodeForUnomiAndEvent(errorCodes)

			case (false, true, _), // Some results and >=1 network was busy (5.5.3)
				 (false, _, true): // Some results and >=1 network had an error (5.5.3)

				nextAction(true)

			case (_, false, false): // 🥳 Some or no results and no network was busy or had an error
				nextAction(false)
		}
	}

	func handleFetchEventsResponse(
		remoteEvents: [RemoteEvent],
		serverErrors: [ServerError],
		unomiServerErrors: [ServerError],
		someInformationMightBeMissing: Bool) {

		// Check if the remote events actually contain events. 
		let hasNoResults = remoteEvents.compactMap { $0.wrapper.events }.flatMap { $0 }.isEmpty

		determineActionFromResponse(
			hasNoResult: hasNoResults,
			serverErrors: serverErrors,
			step: .event,
			nextAction: { someEventsMightBeMissing in
				if hasNoResults && !unomiServerErrors.isEmpty {
					self.logDebug("There are unomi errors, some unomi results and no event results. Show the unomi errors.")
					let errorCodes = self.mapServerErrors(unomiServerErrors, for: self.eventMode.flow, step: .unomi)
					self.displayErrorCodeForUnomiAndEvent(errorCodes)
				} else {
					self.coordinator?.fetchEventsScreenDidFinish(
						.showEvents(
							events: remoteEvents,
							eventMode: self.eventMode,
							eventsMightBeMissing: someEventsMightBeMissing || someInformationMightBeMissing
						)
					)
				}
			}
		)
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
			subTitle: eventMode.alertBody,
			cancelAction: { _ in
				self.goBack()
			},
			cancelTitle: L.holderVaccinationAlertStop(),
			okAction: nil,
			okTitle: L.holderVaccinationAlertContinue(),
			okActionIsPreferred: true
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

			self.processEventProvidersWithAccessTokens(
				accessTokenResult: accessTokenResult,
				remoteEventProvidersResult: remoteEventProvidersResult,
				completion: completion
			)
		}
	}

	private func processEventProvidersWithAccessTokens(
		accessTokenResult: Result<[EventFlow.AccessToken], ServerError>?,
		remoteEventProvidersResult: Result<[EventFlow.EventProvider], ServerError>?,
		completion: @escaping ([EventFlow.EventProvider], [ErrorCode], [ServerError]) -> Void) {

		var errorCodes = [ErrorCode]()
		var serverErrors = [ServerError]()
		var providers = [EventFlow.EventProvider]()

		if let providerError = remoteEventProvidersResult?.failureError {
			self.logError("Error getting event providers: \(providerError)")
			errorCodes.append(self.convert(providerError, for: eventMode.flow, step: .providers))
			serverErrors.append(providerError)
		}

		if let accessError = accessTokenResult?.failureError {
			self.logError("Error getting access tokens: \(accessError)")
			errorCodes.append(self.convert(accessError, for: eventMode.flow, step: .accessTokens))
			serverErrors.append(accessError)
		}

		if let accessTokens = accessTokenResult?.successValue, let eventProviders = remoteEventProvidersResult?.successValue {
			providers = self.filterEventProvidersForEventMode(eventProviders)
			for index in 0 ..< providers.count {
				for accessToken in accessTokens where providers[index].identifier == accessToken.providerIdentifier {
					providers[index].accessToken = accessToken
				}
			}
			if providers.isEmpty, let errorCode = mapNoProviderAvailable() {
				errorCodes.append(errorCode)
			}
		}

		completion(providers, errorCodes, serverErrors)
	}

	private func filterEventProvidersForEventMode(_ eventProviders: [EventFlow.EventProvider]) -> [EventFlow.EventProvider] {

		switch eventMode {
			case .recovery:
				var providers = eventProviders.filter {
					$0.usages.contains(EventFlow.ProviderUsage.recovery) ||
					$0.usages.contains(EventFlow.ProviderUsage.positiveTest)
				}
				for index in 0 ..< providers.count {
					providers[index].queryFilter = EventMode.recovery.queryFilter
				}
				return providers

			case .vaccinationassessment, .paperflow:
				return [] // flow is not part of FetchEvents.

			case .vaccinationAndPositiveTest:
				var vaccinationProviders = eventProviders.filter { $0.usages.contains(EventFlow.ProviderUsage.vaccination) }
				for index in 0 ..< vaccinationProviders.count {
					vaccinationProviders[index].queryFilter = EventMode.vaccination.queryFilter
				}
				var postiveTestProviders = eventProviders.filter { $0.usages.contains(EventFlow.ProviderUsage.positiveTest) }
				for index in 0 ..< postiveTestProviders.count {
					postiveTestProviders[index].queryFilter = EventMode.vaccinationAndPositiveTest.queryFilter
				}
				guard vaccinationProviders.isNotEmpty && postiveTestProviders.isNotEmpty else {
					// Do not proceed if one of the group of providers is empty.
					return []
				}
				return vaccinationProviders + postiveTestProviders

			case .test:
				var providers = eventProviders.filter { $0.usages.contains(EventFlow.ProviderUsage.negativeTest) }
				for index in 0 ..< providers.count {
					providers[index].queryFilter = EventMode.test.queryFilter
				}
				return providers

			case .vaccination:
				var providers = eventProviders.filter { $0.usages.contains(EventFlow.ProviderUsage.vaccination) }
				for index in 0 ..< providers.count {
					providers[index].queryFilter = EventMode.vaccination.queryFilter
				}
				return providers
		}
	}

	private func mapNoProviderAvailable() -> ErrorCode? {

		switch eventMode {
			case .recovery:
				return ErrorCode(flow: eventMode.flow, step: .providers, clientCode: ErrorCode.ClientCode.noRecoveryProviderAvailable)
			case .vaccinationassessment, .paperflow:
				return nil
			case .test, .vaccinationAndPositiveTest:
				return ErrorCode(flow: eventMode.flow, step: .providers, clientCode: ErrorCode.ClientCode.noTestProviderAvailable)
			case .vaccination:
				return ErrorCode(flow: eventMode.flow, step: .providers, clientCode: ErrorCode.ClientCode.noVaccinationProviderAvailable)
		}
	}

	private func fetchEventAccessTokens(completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void) {

		progressIndicationCounter.increment()
		networkManager.fetchEventAccessTokens(tvsToken: tvsToken.idTokenString) { [weak self] result in
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
		completion: @escaping ([EventFlow.EventProvider], [ServerError]) -> Void) {

		var eventInformationAvailableResults = [Result<EventFlow.EventInformationAvailable, ServerError>]()

		for provider in eventProviders {
			guard let url = provider.unomiUrl?.absoluteString, provider.accessToken != nil, url.starts(with: "https") else { continue }

			hasEventInformationFetchingGroup.enter()
			fetchHasEventInformationResponse(
				from: provider,
				completion: { (result: Result<EventFlow.EventInformationAvailable, ServerError>) in

					let mappedToProvider = result.mapError { serverError -> ServerError in
						// Transform regular .error to .provider to display the provider identifier
						switch serverError {
							case let ServerError.error(statusCode, serverResponse, networkError):
								return ServerError.provider(
									provider: provider.identifier,
									statusCode: statusCode,
									response: serverResponse,
									error: networkError
								)
							default:
								return serverError
						}
					}.map { info in
						// Map the right provider identifier (fixes duplication on ACC for ZZZ and GGD)
						return EventFlow.EventInformationAvailable(
							providerIdentifier: provider.identifier,
							protocolVersion: info.protocolVersion,
							informationAvailable: info.informationAvailable
						)
					}
					eventInformationAvailableResults += [mappedToProvider]
					self.hasEventInformationFetchingGroup.leave()
				}
			)
		}

		hasEventInformationFetchingGroup.notify(queue: DispatchQueue.main) {

			// Process successes:
			let successfulEventInformationAvailable = eventInformationAvailableResults.compactMap { $0.successValue }
			let outputEventProviders = eventProviders.map { eventProvider -> EventFlow.EventProvider in
				var eventProvider = eventProvider
				for response in successfulEventInformationAvailable where
					eventProvider.identifier == response.providerIdentifier {
					eventProvider.eventInformationAvailable = response
				}
				return eventProvider
			}.filter { $0.eventInformationAvailable != nil }

			// Process failures:
			let failuresExperienced = eventInformationAvailableResults.compactMap { $0.failureError }

			completion(outputEventProviders, failuresExperienced)
		}
	}

	private func fetchHasEventInformationResponse(
		from provider: EventFlow.EventProvider,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, ServerError>) -> Void) {

		logDebug("eventprovider: \(provider.identifier) - \(provider.name) - \(provider.queryFilter) - \(String(describing: provider.unomiUrl?.absoluteString))")

		progressIndicationCounter.increment()
		networkManager.fetchEventInformation(provider: provider) { [weak self] result in
			// Result<EventFlow.EventInformationAvailable, ServerError>

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
		someInformationMightBeMissing: Bool,
		unomiServerErrors: [ServerError],
		completion: @escaping ([RemoteEvent], [ServerError], [ServerError], Bool) -> Void) {

		var eventResponseResults = [Result<RemoteEvent, ServerError>]()

		for provider in eventProviders {

			if let url = provider.eventUrl?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
			   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

				eventFetchingGroup.enter()
				fetchRemoteEvent(from: provider) { result in

					let mapped = result.mapError { serverError -> ServerError in
						switch serverError {
							case let ServerError.error(statusCode, serverResponse, networkError):
								return ServerError.provider(
									provider: provider.identifier,
									statusCode: statusCode,
									response: serverResponse,
									error: networkError
								)
							default:
								return serverError
						}
					}
					if Configuration().getEnvironment() == "production" {
						eventResponseResults += [mapped.map({ ($0, $1) })]
					} else {
						eventResponseResults += [mapped.map({ wrapper, signed in
							var mappedWrapper = wrapper
							// ZZZ is used for both Test and Fake GGD. Overwrite the response with the right identifier
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

			// We propagate the potential unomi server errors and not append them to failuresExperienced,
			// because we need to distinguish between them in the error states.
			completion(successfulEventResponses, failuresExperienced, unomiServerErrors, someInformationMightBeMissing)
		}
	}

	private func fetchRemoteEvent(
		from provider: EventFlow.EventProvider,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void) {

		progressIndicationCounter.increment()

		networkManager.fetchEvents(provider: provider) { [weak self] result in
			// (Result<(TestResultWrapper, SignedResponse), ServerError>
			completion(result)

			self?.progressIndicationCounter.decrement()
		}
	}
}

extension FetchRemoteEventsViewModel {

	static let detailedCodeNonceExpired: Int = 99708
	static let detailedCodeTvsSessionExpired: Int = 99710
	static let detailedCodeNoBSN: Int = 99782
}

// MARK: - Error states

private extension FetchRemoteEventsViewModel {

	func mapServerErrors(_ serverErrors: [ServerError], for flowCode: ErrorCode.Flow, step: ErrorCode.Step) -> [ErrorCode] {

		let errorCodes: [ErrorCode] = serverErrors.map { serverError in

			return convert(serverError, for: flowCode, step: step)
		}
		return errorCodes
	}

	private func convert(_ serverError: ServerError, for flowCode: ErrorCode.Flow, step: ErrorCode.Step) -> ErrorCode {

		switch serverError {
			case let ServerError.error(statusCode, serverResponse, networkError):
				return ErrorCode(
					flow: flowCode,
					step: step,
					clientCode: networkError.getClientErrorCode() ?? ErrorCode.ClientCode(value: "\(statusCode ?? 000)"),
					detailedCode: serverResponse?.code
				)
			case let ServerError.provider(provider: provider, statusCode, serverResponse, networkError):
				return ErrorCode(
					flow: flowCode,
					step: step,
					provider: provider,
					clientCode: networkError.getClientErrorCode() ?? ErrorCode.ClientCode(value: "\(statusCode ?? 000)"),
					detailedCode: serverResponse?.code
				)
		}
	}

	func handleErrorCodesForAccesTokenAndProviders(_ errorCodes: [ErrorCode], serverErrors: [ServerError]) {

		// No BSN
		guard !errorCodes.contains(where: { $0.detailedCode == FetchRemoteEventsViewModel.detailedCodeNoBSN }) else {
			displayNoBSN()
			return
		}

		// Expired Nonce
		guard !errorCodes.contains(where: { $0.detailedCode == FetchRemoteEventsViewModel.detailedCodeNonceExpired }) else {
			displayNonceOrTVSExpired()
			return
		}

		// Expired TVS token
		guard !errorCodes.contains(where: { $0.detailedCode == FetchRemoteEventsViewModel.detailedCodeTvsSessionExpired }) else {
			displayNonceOrTVSExpired()
			return
		}

		// Unreachable
		guard serverErrors.filter({ serverError in
			if case let ServerError.error(_, _, error) = serverError {
				return error == .serverUnreachableTimedOut || error == .serverUnreachableInvalidHost || error == .serverUnreachableConnectionLost
			}
			return false
		}).isEmpty else {
			displayServerUnreachable(errorCodes)
			return
		}

		// Server Busy
		guard serverErrors.filter({ serverError in
			if case let ServerError.error(_, _, error) = serverError {
				return error == .serverBusy
			}
			return false
		}).isEmpty else {
			displayServerBusy(errorCodes)
			return
		}

		// No Internet
		guard serverErrors.filter({ serverError in
			if case let ServerError.error(_, _, error) = serverError {
				return error == .noInternetConnection
			}
			return false
		}).isEmpty else {
			displayNoInternet()
			return
		}

		displayErrorCodeForAccessTokenAndProviders(errorCodes)
	}

	func displayNoBSN() {

		let content = Content(
			title: L.holderErrorstateNobsnTitle(),
			body: L.holderErrorstateNobsnMessage(),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: { [weak self] in
				self?.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		coordinator?.fetchEventsScreenDidFinish(.error(content: content, backAction: goBack))
	}

	func displayNonceOrTVSExpired() {

		let content = Content(
			title: L.holderErrorstateNosessionTitle(),
			body: L.holderErrorstateNosessionMessage(),
			primaryActionTitle: L.holderErrorstateNosessionAction(),
			primaryAction: { [weak self] in
				self?.goBack()
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		coordinator?.fetchEventsScreenDidFinish(.error(content: content, backAction: goBack))
	}

	func displayServerUnreachable() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.holderErrorstateTitle(),
			subTitle: L.generalErrorServerUnreachable(),
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { _ in
				self.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			okTitle: L.generalClose(),
			okActionIsPreferred: true
		)
	}

	func displayServerUnreachable(_ errorCodes: [ErrorCode]) {

		let content = Content(
			title: L.holderErrorstateTitle(),
			body: L.generalErrorServerUnreachableErrorCode(flattenErrorCodes(errorCodes)),
			primaryActionTitle: L.general_toMyOverview(),
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
		coordinator?.fetchEventsScreenDidFinish(.error(content: content, backAction: goBack))
	}

	func displayServerBusy(_ errorCodes: [ErrorCode]) {

		let content = Content(
			title: L.generalNetworkwasbusyTitle(),
			body: L.generalNetworkwasbusyErrorcode(flattenErrorCodes(errorCodes)),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: { [weak self] in
				self?.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		coordinator?.fetchEventsScreenDidFinish(.error(content: content, backAction: goBack))
	}

	private func flattenErrorCodes(_ errorCodes: [ErrorCode]) -> String {

		let lineBreak = "<br />"
		let errorString = errorCodes.map { "\($0)\(lineBreak)" }.reduce("", +).dropLast(lineBreak.count)
		return String(errorString)
	}

	func displayErrorCodeForAccessTokenAndProviders(_ errorCodes: [ErrorCode]) {

		// Other error:
		var subTitle: String
		if errorCodes.count == 1 {
			if errorCodes[0].errorCode.starts(with: "0") {
				subTitle = L.holderErrorstateClientMessage("\(errorCodes[0])")
			} else {
				subTitle = L.holderErrorstateServerMessage("\(errorCodes[0])")
			}
		} else {
			subTitle = L.holderErrorstateServerMessages(flattenErrorCodes(errorCodes))
		}

		displayErrorCode(subTitle: subTitle)
	}

	func displayErrorCodeForUnomiAndEvent(_ errorCodes: [ErrorCode]) {

		// Other error:
		var subTitle: String
		if errorCodes.count == 1 {
			subTitle = L.holderErrorstateFetchMessage("\(errorCodes[0])")
		} else {
			let lineBreak = "<br />"
			let errorString = errorCodes.map { "\($0)\(lineBreak)" }.reduce("", +).dropLast(lineBreak.count)
			subTitle = L.holderErrorstateFetchMessages("\(errorString)")
		}

		displayErrorCode(subTitle: subTitle)
	}

	func displayErrorCode(subTitle: String) {

		let content = Content(
			title: L.holderErrorstateTitle(),
			body: subTitle,
			primaryActionTitle: L.general_toMyOverview(),
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
		coordinator?.fetchEventsScreenDidFinish(.error(content: content, backAction: goBack))
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
			okTitle: L.generalRetry(),
			okActionIsPreferred: true
		)
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let noTestProviderAvailable = ErrorCode.ClientCode(value: "080")
	static let noRecoveryProviderAvailable = ErrorCode.ClientCode(value: "081")
	static let noVaccinationProviderAvailable = ErrorCode.ClientCode(value: "082")
}
