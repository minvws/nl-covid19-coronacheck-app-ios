/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

class NetworkSpy: NetworkManaging {

	var invokedNetworkConfigurationGetter = false
	var invokedNetworkConfigurationGetterCount = 0
	var stubbedNetworkConfiguration: NetworkConfiguration!

	var networkConfiguration: NetworkConfiguration {
		invokedNetworkConfigurationGetter = true
		invokedNetworkConfigurationGetterCount += 1
		return stubbedNetworkConfiguration
	}

	var invokedFetchEventAccessTokens = false
	var invokedFetchEventAccessTokensCount = 0
	var invokedFetchEventAccessTokensParameters: (maxToken: String, Void)?
	var invokedFetchEventAccessTokensParametersList = [(maxToken: String, Void)]()
	var stubbedFetchEventAccessTokensCompletionResult: (Result<[EventFlow.AccessToken], ServerError>, Void)?

	func fetchEventAccessTokens(maxToken: String, completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void) {
		invokedFetchEventAccessTokens = true
		invokedFetchEventAccessTokensCount += 1
		invokedFetchEventAccessTokensParameters = (maxToken, ())
		invokedFetchEventAccessTokensParametersList.append((maxToken, ()))
		if let result = stubbedFetchEventAccessTokensCompletionResult {
			completion(result.0)
		}
	}

	var invokedPrepareIssue = false
	var invokedPrepareIssueCount = 0
	var stubbedPrepareIssueCompletionResult: (Result<PrepareIssueEnvelope, ServerError>, Void)?

	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, ServerError>) -> Void) {
		invokedPrepareIssue = true
		invokedPrepareIssueCount += 1
		if let result = stubbedPrepareIssueCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetPublicKeys = false
	var invokedGetPublicKeysCount = 0
	var stubbedGetPublicKeysCompletionResult: (Result<Data, ServerError>, Void)?

	func getPublicKeys(completion: @escaping (Result<Data, ServerError>) -> Void) {
		invokedGetPublicKeys = true
		invokedGetPublicKeysCount += 1
		if let result = stubbedGetPublicKeysCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetRemoteConfiguration = false
	var invokedGetRemoteConfigurationCount = 0
	var stubbedGetRemoteConfigurationCompletionResult: (Result<(RemoteConfiguration, Data, URLResponse), ServerError>, Void)?

	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), ServerError>) -> Void) {
		invokedGetRemoteConfiguration = true
		invokedGetRemoteConfigurationCount += 1
		if let result = stubbedGetRemoteConfigurationCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchTestProviders = false
	var invokedFetchTestProvidersCount = 0
	var stubbedFetchTestProvidersCompletionResult: (Result<[TestProvider], ServerError>, Void)?

	func fetchTestProviders(completion: @escaping (Result<[TestProvider], ServerError>) -> Void) {
		invokedFetchTestProviders = true
		invokedFetchTestProvidersCount += 1
		if let result = stubbedFetchTestProvidersCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchEventProviders = false
	var invokedFetchEventProvidersCount = 0
	var stubbedFetchEventProvidersCompletionResult: (Result<[EventFlow.EventProvider], ServerError>, Void)?

	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], ServerError>) -> Void) {
		invokedFetchEventProviders = true
		invokedFetchEventProvidersCount += 1
		if let result = stubbedFetchEventProvidersCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchGreencards = false
	var invokedFetchGreencardsCount = 0
	var invokedFetchGreencardsParameters: (dictionary: [String: AnyObject], Void)?
	var invokedFetchGreencardsParametersList = [(dictionary: [String: AnyObject], Void)]()
	var stubbedFetchGreencardsCompletionResult: (Result<RemoteGreenCards.Response, ServerError>, Void)?

	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, ServerError>) -> Void) {
		invokedFetchGreencards = true
		invokedFetchGreencardsCount += 1
		invokedFetchGreencardsParameters = (dictionary, ())
		invokedFetchGreencardsParametersList.append((dictionary, ()))
		if let result = stubbedFetchGreencardsCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchTestResult = false
	var invokedFetchTestResultCount = 0
	var invokedFetchTestResultParameters: (provider: TestProvider, token: RequestToken, code: String?)?
	var invokedFetchTestResultParametersList = [(provider: TestProvider, token: RequestToken, code: String?)]()
	var stubbedFetchTestResultCompletionResult: (Result<(EventFlow.EventResultWrapper, SignedResponse, URLResponse), ServerError>, Void)?

	func fetchTestResult(
		provider: TestProvider,
		token: RequestToken,
		code: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse, URLResponse), ServerError>) -> Void) {
		invokedFetchTestResult = true
		invokedFetchTestResultCount += 1
		invokedFetchTestResultParameters = (provider, token, code)
		invokedFetchTestResultParametersList.append((provider, token, code))
		if let result = stubbedFetchTestResultCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchEventInformation = false
	var invokedFetchEventInformationCount = 0
	var invokedFetchEventInformationParameters: (provider: EventFlow.EventProvider, Void)?
	var invokedFetchEventInformationParametersList = [(provider: EventFlow.EventProvider, Void)]()
	var stubbedFetchEventInformationCompletionResult: (Result<EventFlow.EventInformationAvailable, ServerError>, Void)?

	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, ServerError>) -> Void) {
		invokedFetchEventInformation = true
		invokedFetchEventInformationCount += 1
		invokedFetchEventInformationParameters = (provider, ())
		invokedFetchEventInformationParametersList.append((provider, ()))
		if let result = stubbedFetchEventInformationCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchEvents = false
	var invokedFetchEventsCount = 0
	var invokedFetchEventsParameters: (provider: EventFlow.EventProvider, Void)?
	var invokedFetchEventsParametersList = [(provider: EventFlow.EventProvider, Void)]()
	var stubbedFetchEventsCompletionResult: (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>, Void)?

	func fetchEvents(
		provider: EventFlow.EventProvider,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void) {
		invokedFetchEvents = true
		invokedFetchEventsCount += 1
		invokedFetchEventsParameters = (provider, ())
		invokedFetchEventsParametersList.append((provider, ()))
		if let result = stubbedFetchEventsCompletionResult {
			completion(result.0)
		}
	}

	var invokedCheckCouplingStatus = false
	var invokedCheckCouplingStatusCount = 0
	var invokedCheckCouplingStatusParameters: (dictionary: [String: AnyObject], Void)?
	var invokedCheckCouplingStatusParametersList = [(dictionary: [String: AnyObject], Void)]()
	var stubbedCheckCouplingStatusCompletionResult: (Result<DccCoupling.CouplingResponse, ServerError>, Void)?

	func checkCouplingStatus(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void) {
		invokedCheckCouplingStatus = true
		invokedCheckCouplingStatusCount += 1
		invokedCheckCouplingStatusParameters = (dictionary, ())
		invokedCheckCouplingStatusParametersList.append((dictionary, ()))
		if let result = stubbedCheckCouplingStatusCompletionResult {
			completion(result.0)
		}
	}
}
