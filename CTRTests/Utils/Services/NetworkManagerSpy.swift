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

	var invokedFetchVaccinationAccessTokens = false
	var invokedFetchVaccinationAccessTokensCount = 0
	var invokedFetchVaccinationAccessTokensParameters: (tvsToken: String, Void)?
	var invokedFetchVaccinationAccessTokensParametersList = [(tvsToken: String, Void)]()
	var stubbedFetchVaccinationAccessTokensCompletionResult: (Result<[Vaccination.AccessToken], NetworkError>, Void)?

	func fetchVaccinationAccessTokens(tvsToken: String, completion: @escaping (Result<[Vaccination.AccessToken], NetworkError>) -> Void) {
		invokedFetchVaccinationAccessTokens = true
		invokedFetchVaccinationAccessTokensCount += 1
		invokedFetchVaccinationAccessTokensParameters = (tvsToken, ())
		invokedFetchVaccinationAccessTokensParametersList.append((tvsToken, ()))
		if let result = stubbedFetchVaccinationAccessTokensCompletionResult {
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
	var stubbedGetPublicKeysCompletionResult: (Result<[IssuerPublicKey], NetworkError>, Void)?

	func getPublicKeys(completion: @escaping (Result<[IssuerPublicKey], NetworkError>) -> Void) {
		invokedGetPublicKeys = true
		invokedGetPublicKeysCount += 1
		if let result = stubbedGetPublicKeysCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetRemoteConfiguration = false
	var invokedGetRemoteConfigurationCount = 0
	var stubbedGetRemoteConfigurationCompletionResult: (Result<RemoteConfiguration, NetworkError>, Void)?

	func getRemoteConfiguration(completion: @escaping (Result<RemoteConfiguration, NetworkError>) -> Void) {
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

	func getTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void) {
		invokedGetTestProviders = true
		invokedGetTestProvidersCount += 1
		if let result = stubbedGetTestProvidersCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchVaccinationEventProviders = false
	var invokedFetchVaccinationEventProvidersCount = 0
	var stubbedFetchVaccinationEventProvidersCompletionResult: (Result<[Vaccination.EventProvider], NetworkError>, Void)?

	func fetchVaccinationEventProviders(completion: @escaping (Result<[Vaccination.EventProvider], NetworkError>) -> Void) {
		invokedFetchVaccinationEventProviders = true
		invokedFetchVaccinationEventProvidersCount += 1
		if let result = stubbedFetchVaccinationEventProvidersCompletionResult {
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

	func getTestResult(
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

	var invokedFetchVaccinationEventInformation = false
	var invokedFetchVaccinationEventInformationCount = 0
	var invokedFetchVaccinationEventInformationParameters: (provider: Vaccination.EventProvider, Void)?
	var invokedFetchVaccinationEventInformationParametersList = [(provider: Vaccination.EventProvider, Void)]()
	var stubbedFetchVaccinationEventInformationCompletionResult: (Result<Vaccination.EventInformationAvailable, NetworkError>, Void)?

	func fetchVaccinationEventInformation(
		provider: Vaccination.EventProvider,
		completion: @escaping (Result<Vaccination.EventInformationAvailable, NetworkError>) -> Void) {
		invokedFetchVaccinationEventInformation = true
		invokedFetchVaccinationEventInformationCount += 1
		invokedFetchVaccinationEventInformationParameters = (provider, ())
		invokedFetchVaccinationEventInformationParametersList.append((provider, ()))
		if let result = stubbedFetchVaccinationEventInformationCompletionResult {
			completion(result.0)
		}
	}

	var invokedFetchVaccinationEvents = false
	var invokedFetchVaccinationEventsCount = 0
	var invokedFetchVaccinationEventsParameters: (provider: Vaccination.EventProvider, Void)?
	var invokedFetchVaccinationEventsParametersList = [(provider: Vaccination.EventProvider, Void)]()
	var stubbedFetchVaccinationEventsCompletionResult: (Result<(Vaccination.EventResultWrapper, SignedResponse), NetworkError>, Void)?

	func fetchVaccinationEvents(
		provider: Vaccination.EventProvider,
		completion: @escaping (Result<(Vaccination.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {
		invokedFetchVaccinationEvents = true
		invokedFetchVaccinationEventsCount += 1
		invokedFetchVaccinationEventsParameters = (provider, ())
		invokedFetchVaccinationEventsParametersList.append((provider, ()))
		if let result = stubbedFetchVaccinationEventsCompletionResult {
			completion(result.0)
		}
	}
}
