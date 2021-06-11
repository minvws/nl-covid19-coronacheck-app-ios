/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class NetworkSpy: NetworkManaging {

	required init(configuration: NetworkConfiguration, validator: CryptoUtilityProtocol) {}

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
	var invokedFetchEventAccessTokensParameters: (tvsToken: String, Void)?
	var invokedFetchEventAccessTokensParametersList = [(tvsToken: String, Void)]()
	var stubbedFetchEventAccessTokensCompletionResult: (Result<[EventFlow.AccessToken], NetworkError>, Void)?

	func fetchEventAccessTokens(tvsToken: String, completion: @escaping (Result<[EventFlow.AccessToken], NetworkError>) -> Void) {
		invokedFetchEventAccessTokens = true
		invokedFetchEventAccessTokensCount += 1
		invokedFetchEventAccessTokensParameters = (tvsToken, ())
		invokedFetchEventAccessTokensParametersList.append((tvsToken, ()))
		if let result = stubbedFetchEventAccessTokensCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetNonce = false
	var invokedGetNonceCount = 0
	var stubbedGetNonceCompletionResult: (Result<NonceEnvelope, NetworkError>, Void)?

	func getNonce(completion: @escaping (Result<NonceEnvelope, NetworkError>) -> Void) {
		invokedGetNonce = true
		invokedGetNonceCount += 1
		if let result = stubbedGetNonceCompletionResult {
			completion(result.0)
		}
	}

	var invokedPrepareIssue = false
	var invokedPrepareIssueCount = 0
	var stubbedPrepareIssueCompletionResult: (Result<PrepareIssueEnvelope, NetworkError>, Void)?

	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, NetworkError>) -> Void) {
		invokedPrepareIssue = true
		invokedPrepareIssueCount += 1
		if let result = stubbedPrepareIssueCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetPublicKeys = false
	var invokedGetPublicKeysCount = 0
	var stubbedGetPublicKeysCompletionResult: (Result<(IssuerPublicKeys, Data), NetworkError>, Void)?

	func getPublicKeys(completion: @escaping (Result<(IssuerPublicKeys, Data), NetworkError>) -> Void) {
		invokedGetPublicKeys = true
		invokedGetPublicKeysCount += 1
		if let result = stubbedGetPublicKeysCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetRemoteConfiguration = false
	var invokedGetRemoteConfigurationCount = 0
	var stubbedGetRemoteConfigurationCompletionResult: (Result<(RemoteConfiguration, Data), NetworkError>, Void)?

	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data), NetworkError>) -> Void) {
		invokedGetRemoteConfiguration = true
		invokedGetRemoteConfigurationCount += 1
		if let result = stubbedGetRemoteConfigurationCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchTestResultsWithISM = false
	var invokedFetchTestResultsWithISMCount = 0
	var invokedFetchTestResultsWithISMParameters: (dictionary: [String: AnyObject], Void)?
	var invokedFetchTestResultsWithISMParametersList = [(dictionary: [String: AnyObject], Void)]()
	var stubbedFetchTestResultsWithISMCompletionResult: (Result<Data, NetworkError>, Void)?

	func fetchTestResultsWithISM(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<Data, NetworkError>) -> Void) {
		invokedFetchTestResultsWithISM = true
		invokedFetchTestResultsWithISMCount += 1
		invokedFetchTestResultsWithISMParameters = (dictionary, ())
		invokedFetchTestResultsWithISMParametersList.append((dictionary, ()))
		if let result = stubbedFetchTestResultsWithISMCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetTestProviders = false
	var invokedGetTestProvidersCount = 0
	var stubbedGetTestProvidersCompletionResult: (Result<[TestProvider], NetworkError>, Void)?

	func fetchTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void) {
		invokedGetTestProviders = true
		invokedGetTestProvidersCount += 1
		if let result = stubbedGetTestProvidersCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchEventProviders = false
	var invokedFetchEventProvidersCount = 0
	var stubbedFetchEventProvidersCompletionResult: (Result<[EventFlow.EventProvider], NetworkError>, Void)?

	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], NetworkError>) -> Void) {
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
	var stubbedFetchGreencardsCompletionResult: (Result<RemoteGreenCards.Response, NetworkError>, Void)?

	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, NetworkError>) -> Void) {
		invokedFetchGreencards = true
		invokedFetchGreencardsCount += 1
		invokedFetchGreencardsParameters = (dictionary, ())
		invokedFetchGreencardsParametersList.append((dictionary, ()))
		if let result = stubbedFetchGreencardsCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetTestResult = false
	var invokedGetTestResultCount = 0
	var invokedGetTestResultParameters: (provider: TestProvider, token: RequestToken, code: String?)?
	var invokedGetTestResultParametersList = [(provider: TestProvider, token: RequestToken, code: String?)]()
	var stubbedGetTestResultCompletionResult: (Result<(TestResultWrapper, SignedResponse), NetworkError>, Void)?

	func fetchTestResult(
		provider: TestProvider,
		token: RequestToken,
		code: String?,
		completion: @escaping (Result<(TestResultWrapper, SignedResponse), NetworkError>) -> Void) {
		invokedGetTestResult = true
		invokedGetTestResultCount += 1
		invokedGetTestResultParameters = (provider, token, code)
		invokedGetTestResultParametersList.append((provider, token, code))
		if let result = stubbedGetTestResultCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchEventInformation = false
	var invokedFetchEventInformationCount = 0
	var invokedFetchEventInformationParameters: (provider: EventFlow.EventProvider, filter: String?)?
	var invokedFetchEventInformationParametersList = [(provider: EventFlow.EventProvider, filter: String?)]()
	var stubbedFetchEventInformationCompletionResult: (Result<EventFlow.EventInformationAvailable, NetworkError>, Void)?

	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, NetworkError>) -> Void) {
		invokedFetchEventInformation = true
		invokedFetchEventInformationCount += 1
		invokedFetchEventInformationParameters = (provider, filter)
		invokedFetchEventInformationParametersList.append((provider, filter))
		if let result = stubbedFetchEventInformationCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchEvents = false
	var invokedFetchEventsCount = 0
	var invokedFetchEventsParameters: (provider: EventFlow.EventProvider, filter: String?)?
	var invokedFetchEventsParametersList = [(provider: EventFlow.EventProvider, filter: String?)]()
	var stubbedFetchEventsCompletionResult: (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>, Void)?

	func fetchEvents(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {
		invokedFetchEvents = true
		invokedFetchEventsCount += 1
		invokedFetchEventsParameters = (provider, filter)
		invokedFetchEventsParametersList.append((provider, filter))
		if let result = stubbedFetchEventsCompletionResult {
			completion(result.0)
		}
	}
}
