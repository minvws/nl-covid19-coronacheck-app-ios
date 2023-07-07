/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public class NetworkSpy: NetworkManaging {

	public init() {}
	
	public var invokedNetworkConfigurationGetter = false
	public var invokedNetworkConfigurationGetterCount = 0
	public var stubbedNetworkConfiguration: NetworkConfiguration!

	public var networkConfiguration: NetworkConfiguration {
		invokedNetworkConfigurationGetter = true
		invokedNetworkConfigurationGetterCount += 1
		return stubbedNetworkConfiguration
	}

	public var invokedFetchEventAccessTokens = false
	public var invokedFetchEventAccessTokensCount = 0
	public var invokedFetchEventAccessTokensParameters: (maxToken: String, Void)?
	public var invokedFetchEventAccessTokensParametersList = [(maxToken: String, Void)]()
	public var stubbedFetchEventAccessTokensCompletionResult: (Result<[EventFlow.AccessToken], ServerError>, Void)?

	public func fetchEventAccessTokens(maxToken: String, completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void) {
		invokedFetchEventAccessTokens = true
		invokedFetchEventAccessTokensCount += 1
		invokedFetchEventAccessTokensParameters = (maxToken, ())
		invokedFetchEventAccessTokensParametersList.append((maxToken, ()))
		if let result = stubbedFetchEventAccessTokensCompletionResult {
			completion(result.0)
		}
	}

	public var invokedPrepareIssue = false
	public var invokedPrepareIssueCount = 0
	public var stubbedPrepareIssueCompletionResult: (Result<PrepareIssueEnvelope, ServerError>, Void)?

	public func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, ServerError>) -> Void) {
		invokedPrepareIssue = true
		invokedPrepareIssueCount += 1
		if let result = stubbedPrepareIssueCompletionResult {
			completion(result.0)
		}
	}

	public var invokedGetPublicKeys = false
	public var invokedGetPublicKeysCount = 0
	public var stubbedGetPublicKeysCompletionResult: (Result<Data, ServerError>, Void)?

	public func getPublicKeys(completion: @escaping (Result<Data, ServerError>) -> Void) {
		invokedGetPublicKeys = true
		invokedGetPublicKeysCount += 1
		if let result = stubbedGetPublicKeysCompletionResult {
			completion(result.0)
		}
	}

	public var invokedGetRemoteConfiguration = false
	public var invokedGetRemoteConfigurationCount = 0
	public var stubbedGetRemoteConfigurationCompletionResult: (Result<(RemoteConfiguration, Data, URLResponse), ServerError>, Void)?

	public func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), ServerError>) -> Void) {
		invokedGetRemoteConfiguration = true
		invokedGetRemoteConfigurationCount += 1
		if let result = stubbedGetRemoteConfigurationCompletionResult {
			completion(result.0)
		}
	}

	public var invokedFetchTestProviders = false
	public var invokedFetchTestProvidersCount = 0
	public var stubbedFetchTestProvidersCompletionResult: (Result<[TestProvider], ServerError>, Void)?

	public func fetchTestProviders(completion: @escaping (Result<[TestProvider], ServerError>) -> Void) {
		invokedFetchTestProviders = true
		invokedFetchTestProvidersCount += 1
		if let result = stubbedFetchTestProvidersCompletionResult {
			completion(result.0)
		}
	}

	public var invokedFetchEventProviders = false
	public var invokedFetchEventProvidersCount = 0
	public var stubbedFetchEventProvidersCompletionResult: (Result<[EventFlow.EventProvider], ServerError>, Void)?

	public func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], ServerError>) -> Void) {
		invokedFetchEventProviders = true
		invokedFetchEventProvidersCount += 1
		if let result = stubbedFetchEventProvidersCompletionResult {
			completion(result.0)
		}
	}

	public var invokedFetchGreencards = false
	public var invokedFetchGreencardsCount = 0
	public var invokedFetchGreencardsParameters: (dictionary: [String: AnyObject], Void)?
	public var invokedFetchGreencardsParametersList = [(dictionary: [String: AnyObject], Void)]()
	public var stubbedFetchGreencardsCompletionResult: (Result<RemoteGreenCards.Response, ServerError>, Void)?

	public func fetchGreencards(
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

	public var invokedFetchTestResult = false
	public var invokedFetchTestResultCount = 0
	public var invokedFetchTestResultParameters: (provider: TestProvider, token: RequestToken, code: String?)?
	public var invokedFetchTestResultParametersList = [(provider: TestProvider, token: RequestToken, code: String?)]()
	public var stubbedFetchTestResultCompletionResult: (Result<(EventFlow.EventResultWrapper, SignedResponse, URLResponse), ServerError>, Void)?

	public func fetchTestResult(
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

	public var invokedFetchEventInformation = false
	public var invokedFetchEventInformationCount = 0
	public var invokedFetchEventInformationParameters: (provider: EventFlow.EventProvider, Void)?
	public var invokedFetchEventInformationParametersList = [(provider: EventFlow.EventProvider, Void)]()
	public var stubbedFetchEventInformationCompletionResult: (Result<EventFlow.EventInformationAvailable, ServerError>, Void)?

	public func fetchEventInformation(
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

	public var invokedFetchEvents = false
	public var invokedFetchEventsCount = 0
	public var invokedFetchEventsParameters: (provider: EventFlow.EventProvider, Void)?
	public var invokedFetchEventsParametersList = [(provider: EventFlow.EventProvider, Void)]()
	public var stubbedFetchEventsCompletionResult: (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>, Void)?

	public func fetchEvents(
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

	public var invokedCheckCouplingStatus = false
	public var invokedCheckCouplingStatusCount = 0
	public var invokedCheckCouplingStatusParameters: (dictionary: [String: AnyObject], Void)?
	public var invokedCheckCouplingStatusParametersList = [(dictionary: [String: AnyObject], Void)]()
	public var stubbedCheckCouplingStatusCompletionResult: (Result<DccCoupling.CouplingResponse, ServerError>, Void)?

	public func checkCouplingStatus(
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
