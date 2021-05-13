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

	var invokedGetAccessTokens = false
	var invokedGetAccessTokensCount = 0
	var invokedGetAccessTokensParameters: (tvsToken: String, Void)?
	var invokedGetAccessTokensParametersList = [(tvsToken: String, Void)]()
	var stubbedGetAccessTokensCompletionResult: (Result<[Vaccination.AccessToken], NetworkError>, Void)?

	func getAccessTokens(tvsToken: String, completion: @escaping (Result<[Vaccination.AccessToken], NetworkError>) -> Void) {
		invokedGetAccessTokens = true
		invokedGetAccessTokensCount += 1
		invokedGetAccessTokensParameters = (tvsToken, ())
		invokedGetAccessTokensParametersList.append((tvsToken, ()))
		if let result = stubbedGetAccessTokensCompletionResult {
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

	var invokedGetVaccinationUnomi = false
	var invokedGetVaccinationUnomiCount = 0
	var invokedGetVaccinationUnomiParameters: (provider: Vaccination.EventProvider, Void)?
	var invokedGetVaccinationUnomiParametersList = [(provider: Vaccination.EventProvider, Void)]()
	var stubbedGetVaccinationUnomiCompletionResult: (Result<Vaccination.EventInformationAvailable, NetworkError>, Void)?

	func getVaccinationUnomi(
		provider: Vaccination.EventProvider,
		completion: @escaping (Result<Vaccination.EventInformationAvailable, NetworkError>) -> Void) {
		invokedGetVaccinationUnomi = true
		invokedGetVaccinationUnomiCount += 1
		invokedGetVaccinationUnomiParameters = (provider, ())
		invokedGetVaccinationUnomiParametersList.append((provider, ()))
		if let result = stubbedGetVaccinationUnomiCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetVaccinationEvents = false
	var invokedGetVaccinationEventsCount = 0
	var invokedGetVaccinationEventsParameters: (provider: Vaccination.EventProvider, Void)?
	var invokedGetVaccinationEventsParametersList = [(provider: Vaccination.EventProvider, Void)]()
	var stubbedGetVaccinationEventsCompletionResult: (Result<(TestResultWrapper, SignedResponse), NetworkError>, Void)?

	func getVaccinationEvents(
		provider: Vaccination.EventProvider,
		completion: @escaping (Result<(TestResultWrapper, SignedResponse), NetworkError>) -> Void) {
		invokedGetVaccinationEvents = true
		invokedGetVaccinationEventsCount += 1
		invokedGetVaccinationEventsParameters = (provider, ())
		invokedGetVaccinationEventsParametersList.append((provider, ()))
		if let result = stubbedGetVaccinationEventsCompletionResult {
			completion(result.0)
		}
	}
}
