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

	var invokedGetVaccinationAccessTokens = false
	var invokedGetVaccinationAccessTokensCount = 0
	var invokedGetVaccinationAccessTokensParameters: (tvsToken: String, Void)?
	var invokedGetVaccinationAccessTokensParametersList = [(tvsToken: String, Void)]()
	var stubbedGetVaccinationAccessTokensCompletionResult: (Result<[Vaccination.AccessToken], NetworkError>, Void)?

	func getVaccinationAccessTokens(tvsToken: String, completion: @escaping (Result<[Vaccination.AccessToken], NetworkError>) -> Void) {
		invokedGetVaccinationAccessTokens = true
		invokedGetVaccinationAccessTokensCount += 1
		invokedGetVaccinationAccessTokensParameters = (tvsToken, ())
		invokedGetVaccinationAccessTokensParametersList.append((tvsToken, ()))
		if let result = stubbedGetVaccinationAccessTokensCompletionResult {
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

	var invokedGetVaccinationEventProviders = false
	var invokedGetVaccinationEventProvidersCount = 0
	var stubbedGetVaccinationEventProvidersCompletionResult: (Result<[Vaccination.EventProvider], NetworkError>, Void)?

	func getVaccinationEventProviders(completion: @escaping (Result<[Vaccination.EventProvider], NetworkError>) -> Void) {
		invokedGetVaccinationEventProviders = true
		invokedGetVaccinationEventProvidersCount += 1
		if let result = stubbedGetVaccinationEventProvidersCompletionResult {
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
	var stubbedFetchVaccinationEventsCompletionResult: (Result<(TestResultWrapper, SignedResponse), NetworkError>, Void)?

	func fetchVaccinationEvents(
		provider: Vaccination.EventProvider,
		completion: @escaping (Result<(TestResultWrapper, SignedResponse), NetworkError>) -> Void) {
		invokedFetchVaccinationEvents = true
		invokedFetchVaccinationEventsCount += 1
		invokedFetchVaccinationEventsParameters = (provider, ())
		invokedFetchVaccinationEventsParametersList.append((provider, ()))
		if let result = stubbedFetchVaccinationEventsCompletionResult {
			completion(result.0)
		}
	}
}
