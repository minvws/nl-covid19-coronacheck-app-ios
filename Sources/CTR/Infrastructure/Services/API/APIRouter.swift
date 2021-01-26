/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Alamofire
import Foundation

/// The API Router
enum ApiRouter: APIRouterProtocol, URLRequestConvertible {

	/// Get the agent details
	case agent(identifier: String)

	/// Get event details
	case event(identifier: String)

	/// Get the public keys
	case publicKeys

	/// Get the test results
	case testResults(identifier: String)

	/// Post the authorization token
	case authorizationToken(token: String)

	// MARK: - Host

	/// The API Host
	static let apiHost = Configuration().getAPIHost()

	// MARK: - Endpoints

	/// The agent endpoint
	static let agentEndpoint = Configuration().getAgentEndpoint()

	/// The event endpoint
	static let eventEndpoint = Configuration().getEventEndpoint()

	/// The public keys endpoint
	static let publicKeysEndpoint = Configuration().getPublicKeysEndpoint()

	/// The test resutlsendpoint
	static let testResultsEndpoint = Configuration().getTestResultsEndpoint()

	/// The test resutlsendpoint
	static let authorizationTokenEndpoint = "/to_be_decided"

	// MARK: - APIRouterProtocol

	/// The base url
	var baseUrl: URL {

		var url: URL
		do {

			url = try ApiRouter.apiHost.asURL()
		} catch {
			fatalError("Configuration: No valid url provided")
		}

		return url
	}

	/// The HTTP Headers
	var headers: [String: String?] {

		// Common Headers
		let result: [String: String?] = [
			HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
			HTTPHeaderField.acceptType.rawValue: ContentType.json.rawValue
		]

		return result
	}

	/// The HTTP Method (POST, GET)
	var method: HTTPMethod {

		if case ApiRouter.authorizationToken = self {
			return .post
		}

		return .get
	}

	/// The endpoint path
	var path: String {

		switch self {
			case let .agent(identifier):
				return ApiRouter.agentEndpoint + "/" + identifier

			case let .event(identifier):
				return ApiRouter.eventEndpoint + "/" + identifier

			case .publicKeys:
				return ApiRouter.publicKeysEndpoint

			case .testResults:
				return ApiRouter.testResultsEndpoint + "/"

			case .authorizationToken:
				return ApiRouter.authorizationTokenEndpoint
		}
	}

	/// Query items
	var queryItems: [URLQueryItem]? {
		switch self {
			case let .testResults(identifier):

				return [
					URLQueryItem(name: "userUUID", value: identifier)
				]

			default:
				return nil
		}
	}

	/// The http body
	var body: Data? {

		if case let ApiRouter.authorizationToken(token) = self {

			return "token: \(token)".data(using: .utf8)
		}
		return nil
	}

	/// The encoding used
	var encoding: ParameterEncoding {

		return URLEncoding()
	}
}
