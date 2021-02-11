/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class NetworkSpy: NetworkManaging {

	var networkConfiguration: NetworkConfiguration
	var remoteConfig: RemoteConfiguration?
	var getNonceCalled = false
	var shouldReturnNonce = false
	var nonceEnvelope: NonceEnvelope?
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

	func fetchTestResultsWithISM(dictionary: [String: AnyObject], completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {
		// Nothing yet
	}

	func getTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void) {
		// Nothing yet
	}

	func getTestTypes(completion: @escaping (Result<[TestType], NetworkError>) -> Void) {
		// Nothing yet
	}

	func getTestResult(providerUrl: URL, token: TestToken, code: String?, completion: @escaping (Result<TestResultWrapper, NetworkError>) -> Void) {
		// Nothing yet
	}
}
