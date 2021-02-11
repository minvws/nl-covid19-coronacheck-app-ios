/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

enum NetworkResponseHandleError: Error {
    case cannotUnzip
    case invalidSignature
    case cannotDeserialize
}

enum NetworkError: Error {
    case invalidRequest
    case serverNotReachable
    case invalidResponse
    case responseCached
    case serverError
    case resourceNotFound
    case encodingError
    case redirection
}

extension NetworkResponseHandleError {
	var asNetworkError: NetworkError {
		switch self {
			case .cannotDeserialize:
				return .invalidResponse
			case .cannotUnzip:
				return .invalidResponse
			case .invalidSignature:
				return .invalidResponse
		}
	}
}

enum HTTPHeaderKey: String {
    case contentType = "Content-Type"
    case acceptedContentType = "Accept"
	case authorization = "Authorization"
}

enum HTTPContentType: String {
    case all = "*/*"
    case json = "application/json"
}

/// - Tag: NetworkManaging
protocol NetworkManaging {

	/// The network configuration
    var networkConfiguration: NetworkConfiguration { get }

	/// Initializer
	/// - Parameters:
	///   - configuration: the network configuration
	///   - validator: the signature validator
	init(configuration: NetworkConfiguration, validator: CryptoUtilityProtocol)

	/// Get the remote configuration
	/// - Parameter completion: completion handler
    func getRemoteConfiguration(completion: @escaping (Result<RemoteConfiguration, NetworkError>) -> Void)

	/// Get the nonce
	/// - Parameter completion: completion handler
	func getNonce(completion: @escaping (Result<NonceEnvelope, NetworkError>) -> Void)

	/// Fetch the test results with issue signature message
	/// - Parameters:
	///   - dictionary: dictionary
	///   - completionHandler: the completion handler
	func fetchTestResultsWithISM(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void)

	/// Get the test providers
	/// - Parameter completion: completion handler
	func getTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void)

	/// Get the test types
	/// - Parameter completion: completion handler
	func getTestTypes(completion: @escaping (Result<[TestType], NetworkError>) -> Void)

	/// Get a test result
	/// - Parameters:
	///   - providerUrl: the url of the test provider
	///   - token: the token to fetch
	///   - code: the code for verification
	///   - completion: the completion handler
	func getTestResult(
		providerUrl: URL,
		token: TestToken,
		code: String?,
		completion: @escaping (Result<TestResultWrapper, NetworkError>) -> Void)
}

struct SignedResponse: Codable {

	/// The payload
	let payload: String

	/// The signature
	let signature: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case payload
		case signature
	}
}
