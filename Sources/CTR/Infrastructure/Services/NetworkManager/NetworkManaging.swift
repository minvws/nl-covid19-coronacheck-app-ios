/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum NetworkError: Error {

	case invalidRequest
	case requestTimedOut
	case noInternetConnection
	case invalidResponse
	case responseCached
	case serverError
	case resourceNotFound
	case encodingError
	case redirection
	case serverBusy
	case invalidSignature
	case cannotDeserialize

	func toMappedErrorCode() -> String {

		switch self {
			case .invalidRequest:
				return "160: invalidRequest"
			case .requestTimedOut:
				return "161 requestTimedOut"
			case .noInternetConnection:
				return "162 noInternetConnection"
			case .invalidResponse:
				return "163 invalidResponse"
			case .responseCached:
				return "164 responseCached"
			case .serverError:
				return "165 serverError"
			case .resourceNotFound:
				return "166 resourceNotFound"
			case .encodingError:
				return "167 encodingError"
			case .redirection:
				return "168 redirection"
			case .serverBusy:
				return "169 serverBusy"
			case .invalidSignature:
				return "170 invalidSignature"
			case .cannotDeserialize:
				return "171 cannotDeserialize"
		}
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
	init(configuration: NetworkConfiguration)

	/// Get the access tokens
	/// - Parameters:
	///   - tvsToken: the tvs token
	///   - completion: completion handler
	func fetchEventAccessTokens(tvsToken: String, completion: @escaping (Result<[EventFlow.AccessToken], NetworkError>) -> Void)

	/// Get the nonce
	/// - Parameter completion: completion handler
	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, NetworkError>) -> Void)
	
	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<(IssuerPublicKeys, Data), NetworkError>) -> Void)
	
	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data), NetworkError>) -> Void)
	
	/// Get the test providers
	/// - Parameter completion: completion handler
	func fetchTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void)

	/// Get the event providers
	/// - Parameter completion: completion handler
	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], NetworkError>) -> Void)

	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, NetworkError>) -> Void)

	/// Get a test result
	/// - Parameters:
	///   - provider: the test provider
	///   - token: the token to fetch
	///   - code: the code for verification
	///   - completion: the completion handler
	func fetchTestResult(
		provider: TestProvider,
		token: RequestToken,
		code: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>) -> Void)

	/// Get a unomi result (check if a event provider knows me)
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventInformationAvailable, SignedResponse), NetworkError>) -> Void)

	/// Get  events from an event provider
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEvents(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>) -> Void)
}
