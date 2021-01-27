/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Alamofire
import Foundation

/// The API Router
enum RemoteConfigurationRouter: ApiRouterProtocol, URLRequestConvertible {

	/// Get the app details
	case getRemoteConfiguration

	// MARK: - Host

	/// The Remote Config Host
	static let apiHost = Configuration().getRemoteConfigHost()

	// MARK: - Endpoints

	/// The remote config endpoint
	static let configEndpoint = Configuration().getRemoteConfigEndpoint()

	// MARK: - APIRouterProtocol

	/// The base url
	var baseUrl: URL {

		var url: URL
		do {

			url = try RemoteConfigurationRouter.apiHost.asURL()
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

		return .get
	}

	/// The endpoint path
	var path: String {

		return RemoteConfigurationRouter.configEndpoint
	}

	/// Query items
	var queryItems: [URLQueryItem]? {

		return nil
	}

	/// The http body
	var body: Data? {

		return nil
	}

	/// The encoding used
	var encoding: ParameterEncoding {

		return URLEncoding()
	}
}
