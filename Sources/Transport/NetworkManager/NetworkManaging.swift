/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct ServerResponse: Decodable, Equatable {
	public let status: String
	public let code: Int
}

public enum ServerError: Error, Equatable {
	case error(statusCode: Int?, response: ServerResponse?, error: NetworkError)
	case provider(provider: String?, statusCode: Int?, response: ServerResponse?, error: NetworkError)
}

public enum NetworkError: String, Error, Equatable {
	case invalidRequest
	case serverUnreachableTimedOut
	case serverUnreachableInvalidHost
	case serverUnreachableConnectionLost
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
	case authenticationCancelled

	public func getClientErrorCode() -> ErrorCode.ClientCode? {

		switch self {

			case .invalidRequest:
				return ErrorCode.ClientCode(value: "002")
			case .serverUnreachableTimedOut:
				return ErrorCode.ClientCode(value: "004")
			case .serverUnreachableInvalidHost:
				return ErrorCode.ClientCode(value: "002")
			case .serverUnreachableConnectionLost:
				return ErrorCode.ClientCode(value: "005")
			case .invalidResponse:
				return ErrorCode.ClientCode(value: "003")
			case .authenticationCancelled:
				return ErrorCode.ClientCode(value: "010")
			case .invalidSignature:
				return ErrorCode.ClientCode(value: "020")
			case .cannotDeserialize:
				return ErrorCode.ClientCode(value: "030")
			case .cannotSerialize:
				return ErrorCode.ClientCode(value: "031")
			default:
				// For noInternetConnection: not needed
				// For responseCached, serverError, resourceNotFound, redirection, serverBusy: use the http status code
				return nil
		}
	}

	/// Checks for valid HTTPResponse and status codes
	public static func inspect(response: URLResponse) -> NetworkError? {
		guard let response = response as? HTTPURLResponse else {
			return .invalidResponse
		}

		switch response.statusCode {
			case 200 ... 299:
				return nil
			case 304:
				return .responseCached
			case 300 ... 399:
				return .redirection
			case 429:
				return .serverBusy
			case 400 ... 499:
				return .resourceNotFound
			case 500 ... 599:
				return .serverError
			default:
				return .invalidResponse
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

enum HTTPBodyKeys: String {
	case verificationCode
}

/// - Tag: NetworkManaging
public protocol NetworkManaging: AnyObject {
	
	/// The network configuration
	var networkConfiguration: NetworkConfiguration { get }
	
	/// Get the access tokens
	/// - Parameters:
	///   - maxToken: the tvs token
	///   - completion: completion handler
	func fetchEventAccessTokens(maxToken: String, completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void)

	/// Get the nonce
	/// - Parameter completion: completion handler
	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, ServerError>) -> Void)
	
	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<Data, ServerError>) -> Void)
	
	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), ServerError>) -> Void)
	
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
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse, URLResponse), ServerError>) -> Void)

	/// Get a unomi result (check if a event provider knows me)
	/// - Parameters:
	///   - provider: the event provider
	///   - completion: the completion handler
	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, ServerError>) -> Void)

	/// Get  events from an event provider
	/// - Parameters:
	///   - provider: the event provider
	///   - completion: the completion handler
	func fetchEvents(
		provider: EventFlow.EventProvider,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void)

	/// Check the coupling status
	/// - Parameters:
	///   - dictionary: the dcc and the coupling code as dictionary
	///   - completion: completion handler
	func checkCouplingStatus(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void)
}
