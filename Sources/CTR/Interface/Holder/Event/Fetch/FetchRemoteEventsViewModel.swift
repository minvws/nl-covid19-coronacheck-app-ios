/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import BrightFutures
import Transport
import Shared
import ReusableViews
import Persistence
import Models
import Resources

// swiftlint:disable type_body_length
final class FetchRemoteEventsViewModel {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var token: String
	private var authenticationMode: AuthenticationMode
	private var eventMode: EventMode
	private let networkManager: NetworkManaging = Current.networkManager

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: FetchRemoteEventsViewController.State

	@Bindable private(set) var alert: AlertContent?

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		token: String,
		authenticationMode: AuthenticationMode,
		eventMode: EventMode) {
		self.coordinator = coordinator
		self.token = token
		self.authenticationMode = authenticationMode
		self.eventMode = eventMode

		viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		fetchEventProvidersWithAccessTokens(
			token: token,
			authenticationMode: authenticationMode,
			completion: handleFetchEventProvidersWithAccessTokensResponse
		)
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
				let errorCodes = ErrorCode.mapServerErrors(serverErrors, for: eventMode.flow, step: step)
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
					logDebug("There are unomi errors, some unomi results and no event results. Show the unomi errors.")
					let errorCodes = ErrorCode.mapServerErrors(unomiServerErrors, for: self.eventMode.flow, step: .unomi)
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
		
		warnBeforeGoBack()
	}

	func warnBeforeGoBack() {

		alert = AlertContent(
			title: L.holderVaccinationAlertTitle(),
			subTitle: eventMode.alertBody,
			okAction: AlertContent.Action(
				title: L.holderVaccinationAlertContinue(),
				isPreferred: true
			),
			cancelAction: AlertContent.Action(
				title: L.holderVaccinationAlertStop(),
				action: { _ in
					self.goBack()
				}
			)
		)
	}

	func goBack() {

		coordinator?.fetchEventsScreenDidFinish(.back(eventMode: eventMode))
	}

	// MARK: Fetch access tokens and event providers

	private func fetchEventProvidersWithAccessTokens(
		token: String,
		authenticationMode: AuthenticationMode,
		completion: @escaping ([EventFlow.EventProvider], [ErrorCode], [ServerError]) -> Void) {
			
		var errorCodes = [ErrorCode]()
		var serverErrors = [ServerError]()
			
		let accessTokenFuture: Future<[EventFlow.AccessToken], ServerError> = {
			guard authenticationMode != .patientAuthenticationProvider else { return Future(value: []) }
			return fetchEventAccessTokens(token: token)
				.onFailure { [self] serverError in
					logError("Error getting access tokens: \(serverError)")
					errorCodes.append(ErrorCode.convert(serverError, for: eventMode.flow, step: .accessTokens))
					serverErrors.append(serverError)
				}
		}()

		fetchEventProviders()
			.onFailure { [self] serverError in
				logError("Error getting event providers: \(serverError)")
				errorCodes.append(ErrorCode.convert(serverError, for: eventMode.flow, step: .providers))
				serverErrors.append(serverError)
			}
			.map { [self] providers in
				filterEventProvidersForEventMode(providers)
			}
			.flatMap { [self] providers -> Future<[EventFlow.EventProvider], ServerError> in
				processProviders(providers: providers, token: token, accessTokenFuture: accessTokenFuture)
			}
			.onComplete { [self] providersResult in
				switch providersResult {
					case .success(let providers):
						if providers.isEmpty, let errorCode = mapNoProviderAvailable() {
							errorCodes.append(errorCode)
						}
						completion(providers, errorCodes, serverErrors)
					case .failure:
						completion([], errorCodes, serverErrors)
				}
			}
	}

	private func processProviders(providers: [EventFlow.EventProvider], token: String, accessTokenFuture: Future<[EventFlow.AccessToken], ServerError>) -> Future<[EventFlow.EventProvider], ServerError> {
		
		// Skip fetching tokens if we have a papToken
		if authenticationMode == .patientAuthenticationProvider {
			
			return Future(value: providers)
				.map { providers in
					// Use the pap Token for both Unomi and Event
					return providers.filter { $0.providerAuthentication.contains(EventFlow.ProviderAuthenticationType.patientAuthenticationProvider) }
				}
				.map { providers in
					var providers = providers
					for index in 0 ..< providers.count {
						providers[index].accessToken = EventFlow.AccessToken(providerIdentifier: providers[index].identifier, unomiAccessToken: token, eventAccessToken: token)
					}
					return providers
				}
		} else {
			
			return Future(value: providers).zip(accessTokenFuture)
				.map { providers, accessTokens -> ([EventFlow.EventProvider], [EventFlow.AccessToken]) in
					let providers = providers.filter { $0.providerAuthentication.contains(EventFlow.ProviderAuthenticationType.manyAuthenticationExchange) }
					return (providers, accessTokens)
				}
				.map { providers, accessTokens -> [EventFlow.EventProvider] in
					var providers = providers
					for index in 0 ..< providers.count {
						for accessToken in accessTokens where providers[index].identifier == accessToken.providerIdentifier {
							providers[index].accessToken = accessToken
						}
					}
					return providers
				}
		}
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
					providers[index].queryFilter = EventMode.test(.ggd).queryFilter
				}
				return providers

			case .vaccination:
				var providers = eventProviders.filter { $0.usages.contains(EventFlow.ProviderUsage.vaccination) }
				for index in 0 ..< providers.count {
					providers[index].queryFilter = EventMode.vaccination.queryFilter
				}
				return providers
			default:
				return [] // Not part of this flow
		}
	}

	private func mapNoProviderAvailable() -> ErrorCode? {

		switch eventMode {
			case .recovery:
				return ErrorCode(flow: eventMode.flow, step: .providers, clientCode: ErrorCode.ClientCode.noRecoveryProviderAvailable)
			case .paperflow:
				return nil
			case .test, .vaccinationAndPositiveTest:
				return ErrorCode(flow: eventMode.flow, step: .providers, clientCode: ErrorCode.ClientCode.noTestProviderAvailable)
			case .vaccination:
				return ErrorCode(flow: eventMode.flow, step: .providers, clientCode: ErrorCode.ClientCode.noVaccinationProviderAvailable)
		}
	}

	private func fetchEventAccessTokens(token: String) -> Future<[EventFlow.AccessToken], ServerError> {

		progressIndicationCounter.increment()
		
		return Future { completion in
				networkManager.fetchEventAccessTokens(maxToken: token, completion: completion)
			}
			.onComplete { [self] _ in
				progressIndicationCounter.decrement()
			}
	}

	private func fetchEventProviders() -> Future<[EventFlow.EventProvider], ServerError> {

		progressIndicationCounter.increment()
		
		return Future { completion in
				networkManager.fetchEventProviders(completion: completion)
			}
			.onComplete { [self] _ in
				progressIndicationCounter.decrement()
			}
	}

	// MARK: Fetch event information

	private func fetchHasEventInformation(
		forEventProviders eventProviders: [EventFlow.EventProvider],
		completion: @escaping ([EventFlow.EventProvider], [ServerError]) -> Void) {
		
		// Collect failures:
		var failuresExperienced = [ServerError]()
		
		eventProviders.compactMap({ provider -> EventFlow.EventProvider? in
			guard let url = provider.unomiUrl?.absoluteString, provider.accessToken != nil, url.starts(with: "https") else { return nil }
			return provider
		}).map { provider -> Future<EventFlow.EventInformationAvailable?, Never> in
			
			return fetchHasEventInformationResponse(from: provider)
				.mapError { serverError in
					serverError.toProviderError(provider: provider)
				}
				.onFailure { serverError in
					// Errors are logged externally, but should not fail the larger set of requests.
					failuresExperienced += [serverError]
				}
				.map { eventInfoAvailable in
					// Map the right provider identifier (fixes duplication on ACC for ZZZ and GGD)
					EventFlow.EventInformationAvailable(
						providerIdentifier: provider.identifier,
						protocolVersion: eventInfoAvailable.protocolVersion,
						informationAvailable: eventInfoAvailable.informationAvailable
					)
				}
				.catchErrorReplacingWithNil()
		}
		.sequence() // Group the successful `Future` results together when they all complete
		.onComplete(DispatchQueue.main.context) { result in
			guard case .success(let eventInformationAvailable) = result else { return } // impossible case as Futures have error type: `Never`.
			let successfulEventInformationAvailable = eventInformationAvailable.compactMap { $0 }

			let outputEventProviders = eventProviders.map { eventProvider -> EventFlow.EventProvider in
				var eventProvider = eventProvider
				for response in successfulEventInformationAvailable where
					eventProvider.identifier == response.providerIdentifier {
					eventProvider.eventInformationAvailable = response
				}
				return eventProvider
			}.filter { $0.eventInformationAvailable != nil }
			
			// We propagate the potential unomi server errors and not append them to failuresExperienced,
			// because we need to distinguish between them in the error states.
			completion(outputEventProviders, failuresExperienced)
		}
	}

	private func fetchHasEventInformationResponse(from provider: EventFlow.EventProvider) -> Future<EventFlow.EventInformationAvailable, ServerError> {
		logVerbose("eventprovider: \(provider.identifier) - \(provider.name) - \(provider.queryFilter) - \(String(describing: provider.unomiUrl?.absoluteString))")

		progressIndicationCounter.increment()
			
		return Future { [self] completion in
			networkManager.fetchEventInformation(provider: provider) { result in
				// Result<EventFlow.EventInformationAvailable, ServerError>
				completion(result)
			}
		}.onComplete { [self] _ in
			progressIndicationCounter.decrement()
		}
	}

	// MARK: Fetch remote events

	private func fetchRemoteEvents(
		eventProviders: [EventFlow.EventProvider],
		someInformationMightBeMissing: Bool,
		unomiServerErrors: [ServerError],
		completion: @escaping ([RemoteEvent], [ServerError], [ServerError], Bool) -> Void) {

		// Collect failures:
		var failuresExperienced = [ServerError]()
			
		eventProviders.map { provider -> Future<RemoteEvent?, Never> in
			
			guard let url = provider.eventUrl?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
				  let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable
			else { return Future(value: nil) }
			
			return Future(value: provider)
				.flatMap { [self] provider -> Future<(EventFlow.EventResultWrapper, SignedResponse)?, Never> in
					
					// Fetch remote events for given provider, catching errors
					// inside this `.flatMap` to prevent the whole `.sequence()` failing, if a single Future fails.
					return fetchRemoteEvent(from: provider)
						.mapError { serverError in
							serverError.toProviderError(provider: provider)
						}
						.onFailure { serverError in
							// Errors are logged externally, but should not fail the larger set of requests.
							failuresExperienced += [serverError]
						}
						.catchErrorReplacingWithNil()
				}
				.map { params -> RemoteEvent? in
					guard let (eventResultWrapper, signedResponse) = params else { return nil }
					return RemoteEvent(wrapper: eventResultWrapper, signedResponse: signedResponse)
				}
		}
		.sequence() // Group the successful `Future` results together when they all complete
		.onComplete(DispatchQueue.main.context) { result in
			guard case .success(let remoteEvents) = result else { return } // impossible case as Futures have error type: `Never`.
			let successfulEventResponses = remoteEvents.compactMap { $0 }

			// We propagate the potential unomi server errors and not append them to failuresExperienced,
			// because we need to distinguish between them in the error states.
			completion(successfulEventResponses, failuresExperienced, unomiServerErrors, someInformationMightBeMissing)
		}
	}

	private func fetchRemoteEvent(from provider: EventFlow.EventProvider) -> Future<(EventFlow.EventResultWrapper, SignedResponse), ServerError> {
		progressIndicationCounter.increment()
		
		return Future { completion in
			networkManager.fetchEvents(provider: provider) { result in
				// (Result<(TestResultWrapper, SignedResponse), ServerError>
				completion(result)
			}
		}
		.onComplete { [self] _ in
			progressIndicationCounter.decrement()
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
			okAction: AlertContent.Action(
				title: L.generalClose(),
				action: { [weak self] _ in
					self?.coordinator?.fetchEventsScreenDidFinish(.stop)
				},
				isPreferred: true
			)
		)
	}

	func displayServerUnreachable(_ errorCodes: [ErrorCode]) {

		let content = Content(
			title: L.holderErrorstateTitle(),
			body: L.generalErrorServerUnreachableErrorCode(ErrorCode.flatten(errorCodes)),
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
			body: L.generalNetworkwasbusyErrorcode(ErrorCode.flatten(errorCodes)),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: { [weak self] in
				self?.coordinator?.fetchEventsScreenDidFinish(.stop)
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
		coordinator?.fetchEventsScreenDidFinish(.error(content: content, backAction: goBack))
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
			subTitle = L.holderErrorstateServerMessages(ErrorCode.flatten(errorCodes))
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
			okAction: AlertContent.Action(
				title: L.generalRetry(),
				action: { [weak self] _ in
					guard let self else { return }
					self.fetchEventProvidersWithAccessTokens(
						token: self.token,
						authenticationMode: self.authenticationMode,
						completion: self.handleFetchEventProvidersWithAccessTokensResponse
					)
				},
				isPreferred: true
			),
			cancelAction: AlertContent.Action(
				title: L.generalClose(),
				action: { _ in
					self.coordinator?.fetchEventsScreenDidFinish(.stop)
				}
			)
		)
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let noTestProviderAvailable = ErrorCode.ClientCode(value: "080")
	static let noRecoveryProviderAvailable = ErrorCode.ClientCode(value: "081")
	static let noVaccinationProviderAvailable = ErrorCode.ClientCode(value: "082")
}

extension ServerError {
	
	// Transform regular .error to .provider to display the provider identifier
	fileprivate func toProviderError(provider: EventFlow.EventProvider) -> ServerError {
		
		switch self {
			case let ServerError.error(statusCode, serverResponse, networkError):
				return ServerError.provider(
					provider: provider.identifier,
					statusCode: statusCode,
					response: serverResponse,
					error: networkError
				)
			default:
				return self
		}
	}
}
