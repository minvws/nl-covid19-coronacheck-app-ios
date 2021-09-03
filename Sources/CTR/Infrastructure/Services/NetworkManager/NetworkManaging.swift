/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct ServerResponse: Decodable, Equatable {
	let status: String
	let code: Int
}

enum ServerError: Error, Equatable {
	case error(statusCode: Int?, response: ServerResponse?, error: NetworkError)
	case provider(provider: String?, statusCode: Int?, response: ServerResponse?, error: NetworkError)
}

enum NetworkError: String, Error, Equatable {
	case invalidRequest
	case serverUnreachable
	case noInternetConnection
	case invalidResponse
	case responseCached
	case serverError
	case resourceNotFound
	case redirection
	case serverBusy
	case invalidSignature
	case cannotSerialize
	case cannotDeserialize

	func getClientErrorCode() -> String? {

		switch self {

			case .invalidRequest:
				return "002"
			//			case .serverUnreachable:
			//			case .noInternetConnection:
			case .invalidResponse:
				return "003"
			//			case .responseCached:
			//			case .serverError:
			//			case .resourceNotFound:
			//			case .redirection:
			//			case .serverBusy:
			case .invalidSignature:
				return "020"
			case .cannotDeserialize:
				return "030"
			case .cannotSerialize:
				return "031"
			default:
				return nil
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
protocol NetworkManaging: AnyObject {
	
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
	func fetchEventAccessTokens(tvsToken: String, completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void)

	/// Get the nonce
	/// - Parameter completion: completion handler
	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, ServerError>) -> Void)
	
	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<Data, NetworkError>) -> Void)
	
	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), NetworkError>) -> Void)
	
	/// Get the test providers
	/// - Parameter completion: completion handler
	func fetchTestProviders(completion: @escaping (Result<[TestProvider], ServerError>) -> Void)

	/// Get the event providers
	/// - Parameter completion: completion handler
	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], ServerError>) -> Void)

	/// Get the greenCards
	/// - Parameters:
	///   - dictionary: a dictionary of events
	///   - completion: completion handler
	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, ServerError>) -> Void)

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
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void)

	/// Get a unomi result (check if a event provider knows me)
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, ServerError>) -> Void)

	/// Get  events from an event provider
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEvents(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void)

	/// Check the coupling status
	/// - Parameters:
	///   - dictionary: the dcc and the coupling code as dictionary
	///   - completion: completion handler
	func checkCouplingStatus(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void)
}
