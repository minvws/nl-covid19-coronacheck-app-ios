/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Alamofire

protocol APIRouterProtocol {

	/// The base url
	var baseUrl: URL { get }

	/// The HTTP Headers
	var headers: [String: String?] { get }

	/// The HTTP Method (POST, GET)
	var method: HTTPMethod { get }

	/// The endpoint path
	var path: String { get }

	/// Query items to append to the url
	var queryItems: [URLQueryItem]? { get }

	/// The body of the request
	var body: Data? { get }

	/// The encoding used
	var encoding: ParameterEncoding { get }

	/// Get the url
	/// - Throws: endoding error
	/// - Returns: url request
	func asURLRequest() throws -> URLRequest
}

extension APIRouterProtocol {

	// MARK: - URLRequestConvertible

	/// Get the url
	/// - Throws: endoding error
	/// - Returns: url request
	func asURLRequest() throws -> URLRequest {

		var url = self.baseUrl.appendingPathComponent(path)
		if let queryItems = self.queryItems,
			var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
			components.queryItems = queryItems
			if let updatedUrl = components.url {
				url = updatedUrl
			}
		}

		var urlRequest = URLRequest(url: url)

		urlRequest.addHeaders(headers)
		urlRequest.httpMethod = method.rawValue
		urlRequest.httpBody = body

		return try encoding.encode(urlRequest, with: nil)
	}
}
