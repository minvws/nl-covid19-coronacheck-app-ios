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

	var invokedGetEventProviders = false
	var invokedGetEventProvidersCount = 0
	var stubbedGetEventProvidersCompletionResult: (Result<[EventProvider], NetworkError>, Void)?

	func getEventProviders(completion: @escaping (Result<[EventProvider], NetworkError>) -> Void) {
		invokedGetEventProviders = true
		invokedGetEventProvidersCount += 1
		if let result = stubbedGetEventProvidersCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetTestTypes = false
	var invokedGetTestTypesCount = 0
	var stubbedGetTestTypesCompletionResult: (Result<[TestType], NetworkError>, Void)?

	func getTestTypes(completion: @escaping (Result<[TestType], NetworkError>) -> Void) {
		invokedGetTestTypes = true
		invokedGetTestTypesCount += 1
		if let result = stubbedGetTestTypesCompletionResult {
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
}

/*

var networkConfiguration: NetworkConfiguration
var remoteConfig: RemoteConfiguration?
var getNonceCalled = false
var shouldReturnNonce = false
var nonceEnvelope: NonceEnvelope?
var getPublicKeysCalled = false
var shouldReturnPublicKeys = false
var publicKeys: [IssuerPublicKey] = []
var publicKeyError: NetworkError?
//		var getTestResultsCalled = false
//		var getTestResultsIdentifier: String?
//		var getTestResultsWithISMCalled = false

required init(configuration: NetworkConfiguration, validator: CryptoUtilityProtocol) {

networkConfiguration = configuration
}

func getRemoteConfiguration(completion: @escaping (Result<RemoteConfiguration, NetworkError>) -> Void) {
if let config = remoteConfig {
completion(.success(config))
} else {
completion(.failure(.serverError))
}
}

func getNonce(completion: @escaping (Result<NonceEnvelope, NetworkError>) -> Void) {

getNonceCalled = true
if shouldReturnNonce, let envelope = nonceEnvelope {
completion(.success(envelope))
}
}

func fetchTestResultsWithISM(dictionary: [String: AnyObject], completion: @escaping (Result<Data, NetworkError>) -> Void) {
// Nothing yet
}

func getTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void) {
// Nothing yet
}

func getEventProviders(completion: @escaping (Result<[EventProvider], NetworkError>) -> Void) {
// Nothing yet
}

func getTestTypes(completion: @escaping (Result<[TestType], NetworkError>) -> Void) {
// Nothing yet
}

func getTestResult(
provider: TestProvider,
token: RequestToken,
code: String?,
completion: @escaping (Result<(TestResultWrapper, SignedResponse), NetworkError>) -> Void) {
// Nothing yet
}

func getPublicKeys(completion: @escaping (Result<[IssuerPublicKey], NetworkError>) -> Void) {

getPublicKeysCalled = true
if shouldReturnPublicKeys {
completion(.success(publicKeys))
}
if let error = publicKeyError {
completion(.failure(error))
}
}
*/
