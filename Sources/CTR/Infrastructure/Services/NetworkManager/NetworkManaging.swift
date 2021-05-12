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
	case invalidPublicKeys
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
		return .invalidResponse
	}
}

enum HTTPHeaderKey: String {
	case contentType = "Content-Type"
	case acceptedContentType = "Accept"
	case authorization = "Authorization"
	case tokenProtocolVersion = "CoronaCheck-Protocol-Version"
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

	/// Get the access tokens
	/// - Parameters:
	///   - tvsToken: the tvs token
	///   - completion: completion handler
	func getAccessTokens(tvsToken: String, completion: @escaping (Result<[AccessToken], NetworkError>) -> Void)

	/// Get the nonce
	/// - Parameter completion: completion handler
	func getNonce(completion: @escaping (Result<NonceEnvelope, NetworkError>) -> Void)
	
	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<[IssuerPublicKey], NetworkError>) -> Void)
	
	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<RemoteConfiguration, NetworkError>) -> Void)
	
	/// - Parameters:
	///   - dictionary: dictionary
	///   - completionHandler: the completion handler
	func fetchTestResultsWithISM(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<Data, NetworkError>) -> Void)
	
	/// Get the test providers
	/// - Parameter completion: completion handler
	func getTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void)

	/// Get the event providers
	/// - Parameter completion: completion handler
	func getEventProviders(completion: @escaping (Result<[EventProvider], NetworkError>) -> Void)
	
	/// Get a test result
	/// - Parameters:
	///   - provider: the the test provider
	///   - token: the token to fetch
	///   - code: the code for verification
	///   - completion: the completion handler
	func getTestResult(
		provider: TestProvider,
		token: RequestToken,
		code: String?,
		completion: @escaping (Result<(TestResultWrapper, SignedResponse), NetworkError>) -> Void)
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
