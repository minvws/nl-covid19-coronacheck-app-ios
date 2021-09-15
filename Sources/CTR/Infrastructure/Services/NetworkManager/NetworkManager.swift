/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length

import Foundation

class NetworkManager: Logging {

	private(set) var loggingCategory: String = "Network"
	private(set) var networkConfiguration: NetworkConfiguration

	/// Initializer
	/// - Parameters:
	///   - configuration: the network configuration
	required init(configuration: NetworkConfiguration) {

		self.networkConfiguration = configuration
	}
	
	// MARK: - Construct Request
	
	private func constructRequest(
		url: URL?,
		method: HTTPMethod = .GET,
		body: Encodable? = nil,
		headers: [HTTPHeaderKey: String] = [:]) -> URLRequest? {

		guard let url = url else {
			return nil
		}
		
		var request = URLRequest(
			url: url,
			cachePolicy: .useProtocolCachePolicy,
			timeoutInterval: 30
		)
		request.httpMethod = method.rawValue
		
		let defaultHeaders = [
			HTTPHeaderKey.contentType: HTTPContentType.json.rawValue
		]
		
		defaultHeaders.forEach { header, value in
			request.addValue(value, forHTTPHeaderField: header.rawValue)
		}
		
		headers.forEach { header, value in
			request.addValue(value, forHTTPHeaderField: header.rawValue)
		}

		if body is Data {
			request.httpBody = body as? Data
		}
		
		logVerbose("--REQUEST--")
		if let url = request.url { logVerbose(url.debugDescription) }
		if let allHTTPHeaderFields = request.allHTTPHeaderFields { logVerbose(allHTTPHeaderFields.debugDescription) }
		if let httpBody = request.httpBody { logVerbose(String(data: httpBody, encoding: .utf8)!) }
		logVerbose("--END REQUEST--")
		
		return request
	}

	// MARK: - Decode Signed Data
	
	/// Decode a signed response into Data
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler
	private func decodeSignedData(
		request: URLRequest,
		session: URLSession,
		ignore400: Bool = false,
		completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {
		// Fetch data
		data(request: request, session: session, ignore400: ignore400) { (result: Result<(URLResponse, Data), NetworkError>) in
			
			/// Decode to SignedResult
			let signedResult: Result<(URLResponse, SignedResponse), NetworkError> = self.jsonResponseHandler(result: result)
			switch signedResult {
				case let .success((urlResponse, signedResponse)):
					
					guard let decodedPayloadData = Data(base64Encoded: signedResponse.payload),
						  let signatureData = Data(base64Encoded: signedResponse.signature) else {
						self.logError("we cannot decode the payload or signature (base64 decoding failed)")
						completion(.failure(NetworkError.cannotDeserialize))
						return
					}

					if let checker = (session.delegate as? NetworkManagerURLSessionDelegate)?.checker {
						// Validate signature (on the base64 payload)
						checker.validate(data: decodedPayloadData, signature: signatureData) { valid in
							if valid {
								DispatchQueue.main.async {
									completion(.success((urlResponse, decodedPayloadData)))
								}
							} else {
								self.logError("We got an invalid signature!")
								completion(.failure(NetworkError.invalidSignature))
							}
						}
					}
				case let .failure(networkError):
					DispatchQueue.main.async {
						completion(.failure(networkError))
					}
			}
		}
	}

	/// Decode a signed response into JSON
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler with object, data, urlResponse or network error
	private func decodeSignedJSONData<Object: Decodable>(
		request: URLRequest,
		session: URLSession,
		ignore400: Bool = false,
		completion: @escaping (Result<(Object, Data, URLResponse), NetworkError>) -> Void) {
		// Fetch data
		data(request: request, session: session, ignore400: ignore400) { (result: Result<(URLResponse, Data), NetworkError>) in

			/// Decode to SignedResult
			let signedResult: Result<(URLResponse, SignedResponse), NetworkError> = self.jsonResponseHandler(result: result)
			switch signedResult {
				case let .success((urlResponse, signedResponse)):

					guard let decodedPayloadData = Data(base64Encoded: signedResponse.payload),
						  let signatureData = Data(base64Encoded: signedResponse.signature) else {
						self.logError("we cannot decode the payload or signature (base64 decoding failed)")
						DispatchQueue.main.async {
							completion(.failure(NetworkError.cannotDeserialize))
						}
						return
					}

					if let checker = (session.delegate as? NetworkManagerURLSessionDelegate)?.checker {
						// Validate signature (on the base64 payload)
						checker.validate(data: decodedPayloadData, signature: signatureData) { valid in
							if valid {
								let decodedResult: Result<Object, NetworkError> = self.decodeJson(json: decodedPayloadData)
								DispatchQueue.main.async {
									switch (decodedResult, decodedPayloadData) {
										case (.success(let object), let decodedPayloadData):
											completion(.success((object, decodedPayloadData, urlResponse)))
										case (.failure(let responseError), _):
											completion(.failure(responseError))
									}
								}
							} else {
								self.logError("We got an invalid signature!")
								DispatchQueue.main.async {
									completion(.failure(NetworkError.invalidSignature))
								}
							}
						}
					}

				case let .failure(networkError):
					DispatchQueue.main.async {
						completion(.failure(networkError))
					}
			}
		}
	}

	/// Decode a signed response into JSON
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler with object, signed response, data, urlResponse or server error
	private func decodeSignedJSONData<Object: Decodable>(
		request: URLRequest,
		session: URLSession,
		proceedToSuccessIfResponseIs400: Bool = false,
		completion: @escaping (Result<(Object, SignedResponse, Data, URLResponse), ServerError>) -> Void) {

		data(request: request, session: session, proceedToSuccessIfResponseIs400: proceedToSuccessIfResponseIs400) { data, response, error in

			let networkResult = self.handleNetworkResponse(response: response, data: data, error: error)
			// Result<(URLResponse, Data), ServerError>

			switch networkResult {
				case let .failure(serverError):
					completion(.failure(serverError))
				case let .success(networkResponse):

					// Decode to SignedResponse
					let signedResult: Result<SignedResponse, NetworkError> = self.decodeJson(json: networkResponse.data)
					switch signedResult {
						case let .success(signedResponse):

							// Make sure we have an actual payload and signature
							guard let decodedPayloadData = signedResponse.decodedPayload,
								  let signatureData = signedResponse.decodedSignature else {
								self.logError("we cannot decode the payload or signature (base64 decoding failed)")
								completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)))
								return
							}

							if let checker = (session.delegate as? NetworkManagerURLSessionDelegate)?.checker {
								// Validate signature (on the base64 payload)
								checker.validate(data: decodedPayloadData, signature: signatureData) { valid in
									if valid {

										self.decodeToObject(
											decodedPayloadData,
											proceedToSuccessIfResponseIs400: proceedToSuccessIfResponseIs400,
											signedResponse: signedResponse,
											urlResponse: networkResponse.urlResponse,
											completion: completion
										)
									} else {
										self.logError("We got an invalid signature!")
										completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)))
									}
								}
							}
						case let .failure(decodeError):
							if let networkError = self.inspect(response: networkResponse.urlResponse) {
								// Is there a actual network error? Report that rather than the signed response decode fail.
								completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: nil, error: networkError)))
							} else {
								// No signed response. Abort.
								completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: nil, error: decodeError)))
							}
					}
			}
		}
	}

	private func decodeToObject<Object: Decodable>(
		_ decodedPayloadData: Data,
		proceedToSuccessIfResponseIs400: Bool = false,
		signedResponse: SignedResponse,
		urlResponse: URLResponse,
		completion: @escaping (Result<(Object, SignedResponse, Data, URLResponse), ServerError>) -> Void) {

		// Did we experience a network error?
		let networkError = self.inspect(response: urlResponse)

		// Decode to the expected object
		let decodedResult: Result<Object, NetworkError> = decodeJson(json: decodedPayloadData)

		switch (decodedResult, proceedToSuccessIfResponseIs400, networkError) {
			case (let .success(object), _, nil), (let .success(object), true, .resourceNotFound):
				// Success and no network error, or success and ignore 400
				completion(.success((object, signedResponse, decodedPayloadData, urlResponse)))

			case (.success, _, _):
				let serverResponseResult: Result<ServerResponse, NetworkError> = self.decodeJson(json: decodedPayloadData)
				completion(.failure(ServerError.error(statusCode: urlResponse.httpStatusCode, response: serverResponseResult.successValue, error: networkError ?? .invalidResponse)))

			case (let .failure(responseError), _, _):
				// Decode to a server response
				let serverResponseResult: Result<ServerResponse, NetworkError> = self.decodeJson(json: decodedPayloadData)
				completion(.failure(ServerError.error(statusCode: urlResponse.httpStatusCode, response: serverResponseResult.successValue, error: networkError ?? responseError)))
		}
	}

	// MARK: - Download Data

	private func data(request: URLRequest, session: URLSession, ignore400: Bool = false, completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {

		session.dataTask(with: request, completionHandler: { data, response, error in
			self.handleNetworkResponse(
				data,
				response: response,
				error: error,
				ignore400: ignore400,
				completion: completion
			)
		}
		).resume()
	}

	private func data(request: URLRequest, session: URLSession, proceedToSuccessIfResponseIs400: Bool = false, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

		session.dataTask(with: request, completionHandler: completion).resume()
	}

	// MARK: - Utilities
	
	/// Checks for failures and inspects status code
	private func handleNetworkResponse<Object>(
		_ object: Object?,
		response: URLResponse?,
		error: Error?,
		ignore400: Bool = false,
		completion: @escaping (Result<(URLResponse, Object), NetworkError>) -> Void) {

		logVerbose("--RESPONSE--")

		if let error = error {
			logDebug("Error with response: \(error)")
			switch URLError.Code(rawValue: (error as NSError).code) {
				case .notConnectedToInternet:
					completion(.failure(.noInternetConnection))
				case .timedOut:
					completion(.failure(.serverUnreachableTimedOut))
				case .cannotConnectToHost, .cannotFindHost:
					completion(.failure(.serverUnreachableInvalidHost))
				case .networkConnectionLost:
					completion(.failure(.serverUnreachableConnectionLost))
				default:
					completion(.failure(.invalidResponse))
			}
			return
		} else if let response = response as? HTTPURLResponse {
			logResponse(response, object: object)
		}
		logVerbose("--END RESPONSE--")

		guard let response = response,
			  let object = object else {
			completion(.failure(.invalidResponse))
			return
		}

		if let error = self.inspect(response: response) {
			// serverBusy == 429, resourceNotFound = 4xx
			if !ignore400 || !(error == .resourceNotFound || error == .serverBusy) {
				completion(.failure(error))
				return
			}
		}
		
		completion(.success((response, object)))
	}

	func handleNetworkResponse(
		response: URLResponse?,
		data: Data?,
		error: Error?) -> Result<(urlResponse: URLResponse, data: Data), ServerError> {

		self.logVerbose("--RESPONSE--")

		if let error = error {
			self.logDebug("Error with response: \(error)")
			switch URLError.Code(rawValue: (error as NSError).code) {
				case .notConnectedToInternet:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .noInternetConnection))
				case .timedOut, .cannotConnectToHost, .cannotFindHost, .networkConnectionLost:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .serverUnreachable))
				default:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .invalidResponse))
			}
		} else if let response = response as? HTTPURLResponse {
			self.logResponse(response, object: data)
		}
		self.logVerbose("--END RESPONSE--")

		guard let response = response,
			  let data = data else {
			return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .invalidResponse))
		}

		if let networkError = self.inspect(response: response), networkError == .serverBusy {
			return .failure(.error(statusCode: response.httpStatusCode, response: nil, error: .serverBusy))
		}

		return .success((response, data))
	}

	func logResponse<Object>(_ response: HTTPURLResponse, object: Object?) {

		logDebug("Finished response to URL \(response.url?.absoluteString ?? "") with status \(response.statusCode)")
		let headers = response.allHeaderFields.map { header, value in
			return String("\(header): \(value)")
		}.joined(separator: "\n")
		logVerbose("Response headers: \n\(headers)")
		if let objectData = object as? Data, let body = String(data: objectData, encoding: .utf8) {
			if !body.starts(with: "{\"signature") && !body.starts(with: "{\"payload") {
				logVerbose("Response body: \n\(body)")
			}
		}
	}

	/// Utility function to decode JSON
	/// - Parameter json: the json data
	/// - Returns: decoded json as Object, or a network error
	private func decodeJson<Object: Decodable>(json: Data) -> Result<Object, NetworkError> {
		do {
			let object = try self.jsonDecoder.decode(Object.self, from: json)
			self.logVerbose("Response Object: \(object)")
			return .success(object)
		} catch {
			self.logError("Error Deserializing \(Object.self):\nError: \(error)\nRaw json: \(String(decoding: json, as: UTF8.self))")
			return .failure(.cannotDeserialize)
		}
	}
	
	/// Response handler which decodes JSON
	private func jsonResponseHandler<Object: Decodable>(result: Result<(URLResponse, Data), NetworkError>) -> Result<(URLResponse, Object), NetworkError> {
		switch result {
			case let .success(result):
				return decodeJson(json: result.1)
					.mapError {
						$0
					}
					.map {
						(result.0, $0)
					}
			case let .failure(error):
				return .failure(error)
		}
	}

	/// Checks for valid HTTPResponse and status codes
	private func inspect(response: URLResponse) -> NetworkError? {
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
	
	// MARK: - Private
	
	private lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		return dateFormatter
	}()
	
	private lazy var jsonEncoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .formatted(dateFormatter)
		encoder.target = .api
		return encoder
	}()
	
	private lazy var jsonDecoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.source = .api
		return decoder
	}()
}

extension NetworkManager: NetworkManaging {

	/// Get the access tokens for the various event providers
	/// - Parameters:
	///   - tvsToken: the tvs token
	///   - completion: completion handler
	func fetchEventAccessTokens(
		tvsToken: String,
		completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void) {

		guard let urlRequest = constructRequest(
			url: networkConfiguration.vaccinationAccessTokensUrl,
			method: .POST,
			headers: [HTTPHeaderKey.authorization: "Bearer \(tvsToken)"]
		) else {
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)
		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: false,
			completion: {(result: Result<(ArrayEnvelope<EventFlow.AccessToken>, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, _, _, _ in (decodable.items) })
				}
			}
		)
	}

	/// Prepare the issue (get the nonce)
	/// - Parameter completion: completion handler
	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, ServerError>) -> Void) {

		guard let urlRequest = constructRequest(url: networkConfiguration.prepareIssueUrl) else {
			logError("NetworkManager - prepareIssue: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)

		decodeSignedJSONData(request: urlRequest, session: session, proceedToSuccessIfResponseIs400: false) { result in
			DispatchQueue.main.async {
				completion(result.map { decodable, _, _, _ in (decodable) })
			}
		}
	}

	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<Data, NetworkError>) -> Void) {

		guard let urlRequest = constructRequest(url: networkConfiguration.publicKeysUrl) else {
			completion(.failure(.invalidRequest))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)
		decodeSignedData(request: urlRequest, session: session, completion: { result in
			completion(result.map { _, data in data })
		})
	}

	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), NetworkError>) -> Void) {
		guard let urlRequest = constructRequest(url: networkConfiguration.remoteConfigurationUrl) else {
			completion(.failure(.invalidRequest))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)
		decodeSignedJSONData(request: urlRequest, session: session, completion: { result in
			completion(result.map { decodable, data, urlResponse in (decodable, data, urlResponse) })
		})
	}

	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, ServerError>) -> Void) {

		guard JSONSerialization.isValidJSONObject(dictionary), // <=== first, check it is valid
			  let body = try? JSONSerialization.data(withJSONObject: dictionary) else {
			logError("NetworkManager - fetchGreencards: could not serialize dictionary")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)))
			return
		}

		guard let urlRequest = constructRequest(
			url: networkConfiguration.credentialUrl,
			method: .POST,
			body: body
		) else {
			logError("NetworkManager - fetchGreencards: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)

		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: false,
			completion: { (result: Result<(RemoteGreenCards.Response, SignedResponse, Data, URLResponse), ServerError>) in

			DispatchQueue.main.async {
				completion(result.map { decodable, _, _, _ in (decodable) })
			}
		})
	}

	/// Get the test providers
	/// - Parameter completion: completion handler
	func fetchTestProviders(completion: @escaping (Result<[TestProvider], ServerError>) -> Void) {

		guard let urlRequest = constructRequest(url: networkConfiguration.providersUrl) else {
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)
		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: false,
			completion: {(result: Result<(ArrayEnvelope<TestProvider>, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, _, _, _ in (decodable.items) })
				}
			}
		)
	}

	/// Get the event providers
	/// - Parameter completion: completion handler
	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], ServerError>) -> Void) {

		guard let urlRequest = constructRequest(url: networkConfiguration.providersUrl) else {
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)

		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: false,
			completion: {(result: Result<(ArrayEnvelope<EventFlow.EventProvider>, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, _, _, _ in (decodable.items) })
				}
			}
		)
	}

	/// Get a test result
	/// - Parameters:
	///   - provider: the the test provider
	///   - token: the token to fetch
	///   - code: the code for verification
	///   - completion: the completion handler
	func fetchTestResult(
		provider: TestProvider,
		token: RequestToken,
		code: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void) {

		guard let providerUrl = provider.resultURL else {
			self.logError("No url provided for \(provider)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(token.token)",
			HTTPHeaderKey.tokenProtocolVersion: token.protocolVersion
		]

		var body: Data?
		if let requiredCode = code {
			let dictionary: [String: AnyObject] = ["verificationCode": requiredCode as AnyObject]
			if JSONSerialization.isValidJSONObject(dictionary), // <=== first, check it is valid
			   let jsonBody = try? JSONSerialization.data(withJSONObject: dictionary) {
				body = jsonBody
			}
		}

		guard let urlRequest = constructRequest(url: providerUrl, method: .POST, body: body, headers: headers) else {
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.provider(provider)),
			delegateQueue: nil
		)
		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: true,
			completion: { (result: Result<(EventFlow.EventResultWrapper, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, signedResponse, _, _ in (decodable, signedResponse) })
				}
			}
		)
	}

	/// Get a unomi result (check if a event provider knows me)
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, ServerError>) -> Void) {

		guard let providerUrl = provider.unomiURL else {
			self.logError("No url provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		guard let accessToken = provider.accessToken?.unomiAccessToken else {
			self.logError("No unomi token provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(accessToken)",
			HTTPHeaderKey.tokenProtocolVersion: "3.0"
		]

		var body: Data?
		if let filter = filter {
			let dictionary: [String: AnyObject] = ["filter": filter as AnyObject]

			if JSONSerialization.isValidJSONObject(dictionary), // <=== first, check it is valid
			   let jsonBody = try? JSONSerialization.data(withJSONObject: dictionary) {
				body = jsonBody
			}
		}

		guard let urlRequest = constructRequest(url: providerUrl, method: .POST, body: body, headers: headers) else {
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.provider(provider)),
			delegateQueue: nil
		)
		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: false,
			completion: { (result: Result<(EventFlow.EventInformationAvailable, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, _, _, _ in (decodable) })
				}
			}
		)
	}

	/// Get  events from an event provider
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEvents(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void) {

		guard let providerUrl = provider.eventURL else {
			self.logError("No url provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		guard let accessToken = provider.accessToken?.eventAccessToken else {
			self.logError("No event token provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(accessToken)",
			HTTPHeaderKey.tokenProtocolVersion: "3.0"
		]

		var body: Data?
		if let filter = filter {
			let dictionary: [String: AnyObject] = ["filter": filter as AnyObject]
			if JSONSerialization.isValidJSONObject(dictionary), // <=== first, check it is valid
			   let jsonBody = try? JSONSerialization.data(withJSONObject: dictionary) {
				body = jsonBody
			}
		}

		guard let urlRequest = constructRequest(url: providerUrl, method: .POST, body: body, headers: headers) else {
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.provider(provider)),
			delegateQueue: nil
		)
		decodeSignedJSONData(
			request: urlRequest,
			session: session,
			proceedToSuccessIfResponseIs400: false,
			completion: { (result: Result<(EventFlow.EventResultWrapper, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, signedResponse, _, _ in (decodable, signedResponse) })
				}
			}
		)
	}

	/// Check the coupling status
	/// - Parameters:
	///   - dictionary: the dcc and the coupling code as dictionary
	///   - completion: completion handler
	func checkCouplingStatus(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void) {

		guard JSONSerialization.isValidJSONObject(dictionary), // <=== first, check it is valid
			  let body = try? JSONSerialization.data(withJSONObject: dictionary) else {
			logError("NetworkManager - checkCouplingStatus: could not serialize dictionary")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)))
			return
		}

		guard let urlRequest = constructRequest(
			url: networkConfiguration.couplingUrl,
			method: .POST,
			body: body
		) else {
			logError("NetworkManager - checkCouplingStatus: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		let session = URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(networkConfiguration, strategy: SecurityStrategy.data),
			delegateQueue: nil
		)

		decodeSignedJSONData(request: urlRequest, session: session, proceedToSuccessIfResponseIs400: false) { result in
			// Result<(Object, SignedResponse, Data, URLResponse), ServerError>
			DispatchQueue.main.async {
				completion(result.map { decodable, _, _, _ in (decodable) })
			}
		}
	}
}

// MARK: URLResponse

extension URLResponse {

	var httpStatusCode: Int? {

		(self as? HTTPURLResponse)?.statusCode
	}
}
