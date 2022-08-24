/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class NetworkManager {

	internal let networkConfiguration: NetworkConfiguration
	private let signatureValidationFactory: SignatureValidationFactoryProtocol
	private let logHandler: Logging?

	/// Initializer
	/// - Parameters:
	///   - configuration: the network configuration
	required init(
		configuration: NetworkConfiguration,
		signatureValidationFactory: SignatureValidationFactoryProtocol = SignatureValidationFactory(),
		logHandler: Logging? = nil
	) {

		self.networkConfiguration = configuration
		self.signatureValidationFactory = signatureValidationFactory
		self.logHandler = logHandler
	}

	// MARK: - Decode Signed Data

	/// Decode a signed response into JSON
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler with object, signed response, data, urlResponse or server error
	private func decodeSignedJSONData<Object: Decodable>(
		request: URLRequest,
		strategy: SecurityStrategy = .data,
		signatureValidator: SignatureValidation,
		proceedToSuccessIfResponseIs400: Bool = false,
		completion: @escaping (Result<(Object, SignedResponse, Data, URLResponse), ServerError>) -> Void) {

		let session = createSession(strategy: strategy)
		data(request: request, session: session) { data, response, error in

			switch self.handleNetworkResponse(response: response, data: data, error: error) {
				case let .failure(serverError):
					completion(.failure(serverError))
				case let .success(networkResponse):

					// Decode to SignedResponse
					let signedResult: Result<SignedResponse, NetworkError> = self.decodeJson(json: networkResponse.data)
					switch signedResult {
						case let .success(signedResponse):
							
							self.validateSignedResponse(
								signatureValidator: signatureValidator,
								urlResponse: networkResponse.urlResponse,
								signedResponse: signedResponse,
								proceedToSuccessIfResponseIs400: proceedToSuccessIfResponseIs400,
								completion: completion
							)

						case let .failure(decodeError):
							if let networkError = NetworkError.inspect(response: networkResponse.urlResponse) {
								// Is there a actual network error? Report that rather than the signed response decode fail.
								completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: nil, error: networkError)))
							} else {
								// No signed response. Abort.
								completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: nil, error: decodeError)))
							}
					}
			}
			
			self.cleanupSession(session)
		}
	}
	
	private func decodeSignedData(
		request: URLRequest,
		strategy: SecurityStrategy = .data,
		signatureValidator: SignatureValidation,
		completion: @escaping (Result<Data, ServerError>) -> Void) {

		let session = createSession(strategy: strategy)
		data(request: request, session: session) { data, response, error in

			switch self.handleNetworkResponse(response: response, data: data, error: error) {
				case let .failure(serverError):
					completion(.failure(serverError))
				case let .success(networkResponse):

					// Decode to SignedResponse
					let signedResult: Result<SignedResponse, NetworkError> = self.decodeJson(json: networkResponse.data)
					switch signedResult {
						case let .success(signedResponse):
							self.validateSignedResponse(
								signatureValidator: signatureValidator,
								signedResponse: signedResponse,
								completion: completion
							)

						case let .failure(decodeError):
							if let networkError = NetworkError.inspect(response: networkResponse.urlResponse) {
								// Is there a actual network error? Report that rather than the signed response decode fail.
								completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: nil, error: networkError)))
							} else {
								// No signed response. Abort.
								completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: nil, error: decodeError)))
							}
					}
			}
			
			self.cleanupSession(session)
		}
	}
	
	private func validateSignedResponse<Object: Decodable>(
		signatureValidator: SignatureValidation,
		urlResponse: URLResponse,
		signedResponse: SignedResponse,
		proceedToSuccessIfResponseIs400: Bool = false,
		completion: @escaping (Result<(Object, SignedResponse, Data, URLResponse), ServerError>) -> Void) {
		
		// Make sure we have an actual payload and signature
		guard let decodedPayloadData = signedResponse.decodedPayload,
			  let signatureData = signedResponse.decodedSignature else {
			logHandler?.logError("we cannot decode the payload or signature (base64 decoding failed)")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)))
			return
		}

		// Validate signature (on the base64 payload)
		signatureValidator.validate(data: decodedPayloadData, signature: signatureData) { valid in
			if valid {
				
				completion(
					self.decodeToObject(
						decodedPayloadData,
						proceedToSuccessIfResponseIs400: proceedToSuccessIfResponseIs400,
						signedResponse: signedResponse,
						urlResponse: urlResponse
					)
				)
			} else {
				self.logHandler?.logError("We got an invalid signature!")
				completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)))
			}
		}
	}
	
	private func validateSignedResponse(
		signatureValidator: SignatureValidation,
		signedResponse: SignedResponse,
		completion: @escaping (Result<Data, ServerError>) -> Void) {
		
		// Make sure we have an actual payload and signature
		guard let decodedPayloadData = signedResponse.decodedPayload,
			  let signatureData = signedResponse.decodedSignature else {
			logHandler?.logError("we cannot decode the payload or signature (base64 decoding failed)")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)))
			return
		}

		// Validate signature (on the base64 payload)
		signatureValidator.validate(data: decodedPayloadData, signature: signatureData) { valid in
			if valid {
				completion(.success(decodedPayloadData))
				
			} else {
				self.logHandler?.logError("We got an invalid signature!")
				completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)))
			}
		}
	}

	/// Decode an unsigned response into JSON
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler with object or server error
	private func decodeUnsignedJSONData<Object: Decodable>(
		request: URLRequest,
		completion: @escaping (Result<Object, ServerError>) -> Void) {

		let session = createSession(strategy: .data)
		data(request: request, session: session) { data, response, error in

			let networkResult = self.handleNetworkResponse(response: response, data: data, error: error)
			// Result<(URLResponse, Data), ServerError>

			switch networkResult {
				case let .failure(serverError):
					completion(.failure(serverError))

				case let .success(networkResponse):

					// Try to cast to ServerResponse.
					// The Object might have all optional properties and be decodable with the ServerResponse
					let serverResponseResult: Result<ServerResponse, NetworkError> = self.decodeJson(json: networkResponse.data, logError: false)
					if let successValue = serverResponseResult.successValue {
						completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: successValue, error: .serverError)))
						return
					}
					
					// Decode to the expected object
					let decodedResult: Result<Object, NetworkError> = self.decodeJson(json: networkResponse.data)
					switch decodedResult {
						case let .success(object):
							completion(.success(object))

						case let .failure(responseError):
							// Did we experience a network error?
							let networkError = NetworkError.inspect(response: networkResponse.urlResponse)
							// Decode to a server response
							let serverResponseResult: Result<ServerResponse, NetworkError> = self.decodeJson(json: networkResponse.data)
							completion(.failure(ServerError.error(statusCode: networkResponse.urlResponse.httpStatusCode, response: serverResponseResult.successValue, error: networkError ?? responseError)))
					}
			}
			
			self.cleanupSession(session)
		}
	}

	private func decodeToObject<Object: Decodable>(
		_ decodedPayloadData: Data,
		proceedToSuccessIfResponseIs400: Bool = false,
		signedResponse: SignedResponse,
		urlResponse: URLResponse) -> Result<(Object, SignedResponse, Data, URLResponse), ServerError> {

		// Did we experience a network error?
		let networkError = NetworkError.inspect(response: urlResponse)

		// Decode to the expected object
		let decodedResult: Result<Object, NetworkError> = decodeJson(json: decodedPayloadData)

		switch (decodedResult, proceedToSuccessIfResponseIs400, networkError) {
			case (let .success(object), _, nil), (let .success(object), true, .resourceNotFound):
				// Success and no network error, or success and ignore 400
				return .success((object, signedResponse, decodedPayloadData, urlResponse))

			case (.success, _, _):
				let serverResponseResult: Result<ServerResponse, NetworkError> = self.decodeJson(json: decodedPayloadData)
				return .failure(ServerError.error(statusCode: urlResponse.httpStatusCode, response: serverResponseResult.successValue, error: networkError ?? .invalidResponse))

			case (let .failure(responseError), _, _):
				// Decode to a server response
				let serverResponseResult: Result<ServerResponse, NetworkError> = self.decodeJson(json: decodedPayloadData)
				return .failure(ServerError.error(statusCode: urlResponse.httpStatusCode, response: serverResponseResult.successValue, error: networkError ?? responseError))
		}
	}

	// MARK: - Download Data

	private func data(request: URLRequest, session: URLSession, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

		session.dataTask(with: request, completionHandler: completion).resume()
	}

	// MARK: - Utilities

	func handleNetworkResponse(
		response: URLResponse?,
		data: Data?,
		error: Error?) -> Result<(urlResponse: URLResponse, data: Data), ServerError> {

		logHandler?.logVerbose("--RESPONSE--")

		if let error = error {
			logHandler?.logDebug("Error with response: \(error)")
			switch URLError.Code(rawValue: (error as NSError).code) {
				case .notConnectedToInternet:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .noInternetConnection))
				case .timedOut:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .serverUnreachableTimedOut))
				case .cannotConnectToHost, .cannotFindHost:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .serverUnreachableInvalidHost))
				case .networkConnectionLost:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .serverUnreachableConnectionLost))
				case .cancelled:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .authenticationCancelled))
				default:
					return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .invalidResponse))
			}
		} else if let response = response as? HTTPURLResponse {
			self.logResponse(response, object: data)
		}
		logHandler?.logVerbose("--END RESPONSE--")

		guard let response = response,
			  let data = data else {
			return .failure(.error(statusCode: response?.httpStatusCode, response: nil, error: .invalidResponse))
		}

		if let networkError = NetworkError.inspect(response: response), networkError == .serverBusy {
			return .failure(.error(statusCode: response.httpStatusCode, response: nil, error: .serverBusy))
		}

		return .success((response, data))
	}

	func logResponse<Object>(_ response: HTTPURLResponse, object: Object?) {

		if response.statusCode != 200 {
			logHandler?.logDebug("Finished response to URL \(response.url?.absoluteString ?? "") with status \(response.statusCode)")
		}
		let headers = response.allHeaderFields.map { header, value in
			return String("\(header): \(value)")
		}.joined(separator: "\n")
		logHandler?.logVerbose("Response headers: \n\(headers)")
		if let objectData = object as? Data, let body = String(data: objectData, encoding: .utf8) {
			if !body.starts(with: "{\"signature") && !body.starts(with: "{\"payload") {
				logHandler?.logVerbose("Response body: \n\(body)")
			}
		}
	}

	/// Utility function to decode JSON
	/// - Parameter json: the json data
	/// - Returns: decoded json as Object, or a network error
	private func decodeJson<Object: Decodable>(json: Data, logError: Bool = true) -> Result<Object, NetworkError> {

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		do {
			let decodedObject = try decoder.decode(Object.self, from: json)
#if DEBUG
			// Next line might crash on production:
			logHandler?.logVerbose("Response Object: \(decodedObject)")
#endif
			return .success(decodedObject)
		} catch {
			if logError {
				logHandler?.logError("Error Deserializing `\(Object.self)`:\nError: \(error)\nRaw json: \(String(decoding: json, as: UTF8.self))")
			}
			return .failure(.cannotDeserialize)
		}
	}
	
	// MARK: - Private

	private func createSession(strategy: SecurityStrategy) -> URLSession {

		return URLSession(
			configuration: .ephemeral,
			delegate: NetworkManagerURLSessionDelegate(strategy: strategy),
			delegateQueue: nil
		)
	}
	
	private func cleanupSession(_ session: URLSession) {
		
		(session.delegate as? NetworkManagerURLSessionDelegate)?.cleanup()
		session.finishTasksAndInvalidate()
	}

	// MARK: - Helpers

	private func httpBodyFromDictionary(_ dictionary: [String: String?]) -> Data? {

		var body: Data?
		let filtered = dictionary.compactMapValues { $0 }
		if JSONSerialization.isValidJSONObject(filtered), // <=== first, check it is valid
		   let jsonBody = try? JSONSerialization.data(withJSONObject: filtered) {
			body = jsonBody
		}
		return body
	}

	private func headersWithAuthorizationToken(_ token: String) -> [HTTPHeaderKey: String] {

		return [
			HTTPHeaderKey.authorization: "Bearer \(token)",
			HTTPHeaderKey.tokenProtocolVersion: "3.0"
		]
	}
}

extension NetworkManager: NetworkManaging {

	/// Get the access tokens for the various event providers
	/// - Parameters:
	///   - maxToken: the tvs token
	///   - completion: completion handler
	func fetchEventAccessTokens(
		maxToken: String,
		completion: @escaping (Result<[EventFlow.AccessToken], ServerError>) -> Void) {
		
		let tokenHeader = [HTTPHeaderKey.authorization: "Bearer \(maxToken)"]
		guard let url = networkConfiguration.eventAccessTokensUrl,
			  let urlRequest = URLRequest(url: url, method: .POST, headers: tokenHeader) else {
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeUnsignedJSONData(request: urlRequest) { (result: Result<ArrayEnvelope<EventFlow.AccessToken>, ServerError>) in
			DispatchQueue.main.async {
				completion(result.map { decodable in (decodable.items) })
			}
		}
	}

	/// Prepare the issue (get the nonce)
	/// - Parameter completion: completion handler
	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, ServerError>) -> Void) {

		guard let url = networkConfiguration.prepareIssueUrl, let urlRequest = URLRequest(url: url) else {
			logHandler?.logError("NetworkManager - prepareIssue: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeUnsignedJSONData(request: urlRequest) { (result: Result<PrepareIssueEnvelope, ServerError>) in
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}

	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<Data, ServerError>) -> Void) {

		guard let url = networkConfiguration.publicKeysUrl, let urlRequest = URLRequest(url: url, timeOutInterval: 10.0) else {
			logHandler?.logError("NetworkManager - getPublicKeys: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeSignedData(
			request: urlRequest,
			strategy: .config,
			signatureValidator: signatureValidationFactory.getSignatureValidator(.config),
			completion: { (result: Result<Data, ServerError>) in
				// Not interested in the object (anycodable), we just want the data.
				DispatchQueue.main.async {
					completion(result)
				}
			}
		)
	}

	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), ServerError>) -> Void) {

		guard let url = networkConfiguration.remoteConfigurationUrl, let urlRequest = URLRequest(url: url, timeOutInterval: 10.0) else {
			logHandler?.logError("NetworkManager - getRemoteConfiguration: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		
		decodeSignedJSONData(
			request: urlRequest,
			strategy: .config,
			signatureValidator: signatureValidationFactory.getSignatureValidator(.config),
			completion: { (result: Result<(RemoteConfiguration, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, _, data, urlResponse in (decodable, data, urlResponse) })
				}
			}
		)
	}

	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, ServerError>) -> Void) {

		guard JSONSerialization.isValidJSONObject(dictionary), // <=== first, check it is valid
			  let body = try? JSONSerialization.data(withJSONObject: dictionary) else {
			logHandler?.logError("NetworkManager - fetchGreencards: could not serialize dictionary")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)))
			return
		}

		guard let url = networkConfiguration.credentialUrl,
			  let urlRequest = URLRequest(url: url, method: .POST, body: body) else {
			logHandler?.logError("NetworkManager - fetchGreencards: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeUnsignedJSONData(request: urlRequest) { (result: Result<RemoteGreenCards.Response, ServerError>) in
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}

	/// Get the test providers
	/// - Parameter completion: completion handler
	func fetchTestProviders(completion: @escaping (Result<[TestProvider], ServerError>) -> Void) {

		fetchProviders(completion: completion)
	}

	/// Get the event providers
	/// - Parameter completion: completion handler
	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], ServerError>) -> Void) {

		fetchProviders(completion: completion)
	}

	private func fetchProviders<T: Envelopable & Codable>(completion: @escaping (Result<[T], ServerError>) -> Void) {

		guard let url = networkConfiguration.providersUrl, let urlRequest = URLRequest(url: url) else {
			logHandler?.logError("NetworkManager - fetchProviders: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeSignedJSONData(
			request: urlRequest,
			strategy: .config,
			signatureValidator: signatureValidationFactory.getSignatureValidator(.config),
			completion: {(result: Result<(ArrayEnvelope<T>, SignedResponse, Data, URLResponse), ServerError>) in
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
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse, URLResponse), ServerError>) -> Void) {

		guard let providerUrl = provider.resultURL else {
			logHandler?.logError("No url provided for \(provider)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(token.token)",
			HTTPHeaderKey.tokenProtocolVersion: token.protocolVersion
		]

		guard let urlRequest = URLRequest(url: providerUrl, method: .POST, body: httpBodyFromDictionary([HTTPBodyKeys.verificationCode.rawValue: code]), headers: headers) else {
			logHandler?.logError("NetworkManager - fetchTestResult: invalid request")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeSignedJSONData(
			request: urlRequest,
			strategy: SecurityStrategy.provider(provider),
			signatureValidator: signatureValidationFactory.getSignatureValidator(.provider(provider)),
			proceedToSuccessIfResponseIs400: true,
			completion: { (result: Result<(EventFlow.EventResultWrapper, SignedResponse, Data, URLResponse), ServerError>) in
				DispatchQueue.main.async {
					completion(result.map { decodable, signedResponse, _, urlResponse in (decodable, signedResponse, urlResponse) })
				}
			}
		)
	}

	/// Get a unomi result (check if a event provider knows me)
	/// - Parameters:
	///   - provider: the event provider
	///   - completion: the completion handler
	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, ServerError>) -> Void) {

		guard let providerUrl = provider.unomiUrl else {
			logHandler?.logError("No url provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		guard let accessToken = provider.accessToken?.unomiAccessToken else {
			logHandler?.logError("No unomi token provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		let body = httpBodyFromDictionary(provider.queryFilter)
		guard let urlRequest = URLRequest(url: providerUrl, method: .POST, body: body, headers: headersWithAuthorizationToken(accessToken)) else {
			logHandler?.logError("NetworkManager - fetchEventInformation: invalid request")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeSignedJSONData(
			request: urlRequest,
			strategy: SecurityStrategy.provider(provider),
			signatureValidator: signatureValidationFactory.getSignatureValidator(.provider(provider)),
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
	///   - completion: the completion handler
	func fetchEvents(
		provider: EventFlow.EventProvider,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), ServerError>) -> Void) {

		guard let providerUrl = provider.eventUrl else {
			logHandler?.logError("No url provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		guard let accessToken = provider.accessToken?.eventAccessToken else {
			logHandler?.logError("No event token provided for \(provider.name)")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}
		
		let body = httpBodyFromDictionary(provider.queryFilter)
		guard let urlRequest = URLRequest(url: providerUrl, method: .POST, body: body, headers: headersWithAuthorizationToken(accessToken)) else {
			logHandler?.logError("NetworkManager - fetchEvents: invalid request")
			completion(.failure(ServerError.provider(provider: provider.identifier, statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeSignedJSONData(
			request: urlRequest,
			strategy: SecurityStrategy.provider(provider),
			signatureValidator: signatureValidationFactory.getSignatureValidator(.provider(provider)),
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
			logHandler?.logError("NetworkManager - checkCouplingStatus: could not serialize dictionary")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)))
			return
		}

		guard let url = networkConfiguration.couplingUrl,
			  let urlRequest = URLRequest(url: url, method: .POST, body: body) else {
			logHandler?.logError("NetworkManager - checkCouplingStatus: invalid request")
			completion(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidRequest)))
			return
		}

		decodeUnsignedJSONData(request: urlRequest) { (result: Result<DccCoupling.CouplingResponse, ServerError>) in
			DispatchQueue.main.async {
				completion(result)
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

fileprivate extension URLRequest {
	
	init?(
		url: URL,
		method: HTTPMethod = .GET,
		body: Encodable? = nil,
		timeOutInterval: TimeInterval = 30,
		headers: [HTTPHeaderKey: String] = [:]) {
		
		self.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOutInterval)
		
		httpMethod = method.rawValue
		
		let defaultHeaders = [
			HTTPHeaderKey.contentType: HTTPContentType.json.rawValue
		]
		
		defaultHeaders.forEach { header, value in
			addValue(value, forHTTPHeaderField: header.rawValue)
		}
		
		headers.forEach { header, value in
			addValue(value, forHTTPHeaderField: header.rawValue)
		}
		
		if body is Data {
			httpBody = body as? Data
		}
	}
}
