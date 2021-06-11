/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

class NetworkManager: NetworkManaging, Logging {

	private(set) var loggingCategory: String = "Network"
	private(set) var networkConfiguration: NetworkConfiguration
	private(set) var validator: CryptoUtilityProtocol

	/// Initializer
	/// - Parameters:
	///   - configuration: the network configuration
	///   - validator: the signature validator
	required init(configuration: NetworkConfiguration, validator: CryptoUtilityProtocol) {

		self.networkConfiguration = configuration
		self.validator = validator
		self.sessionDelegate = NetworkManagerURLSessionDelegate(configuration)
		self.session = URLSession(
			configuration: .ephemeral,
			delegate: sessionDelegate,
			delegateQueue: nil)
	}

	/// Get the access tokens for the various event providers
	/// - Parameters:
	///   - tvsToken: the tvs token
	///   - completion: completion handler
	func fetchEventAccessTokens(
		tvsToken: String,
		completion: @escaping (Result<[EventFlow.AccessToken], NetworkError>) -> Void) {

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(tvsToken)",
			HTTPHeaderKey.acceptedContentType: HTTPContentType.json.rawValue
		]

		let urlRequest = constructRequest(
			url: networkConfiguration.vaccinationAccessTokensUrl,
			method: .POST,
			headers: headers
		)
		
		func open(result: Result<ArrayEnvelope<EventFlow.AccessToken>, NetworkError>) {
			completion(result.map { $0.items })
		}
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.data)
		decodeSignedJSONData(request: urlRequest, completion: open)
	}

	/// Get the nonce
	/// - Parameter completion: completion handler
	func prepareIssue(completion: @escaping (Result<PrepareIssueEnvelope, NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.prepareIssueUrl,
			method: .GET
		)
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.data)
		decodeSignedJSONData(request: urlRequest, completion: completion)
	}

	/// Get the public keys
	/// - Parameter completion: completion handler
	func getPublicKeys(completion: @escaping (Result<(IssuerPublicKeys, Data), NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.publicKeysUrl,
			method: .GET
		)
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.data)
		decodeSignedJSONData(request: urlRequest, completion: completion)
	}

	/// Get the remote configuration
	/// - Parameter completion: completion handler
	func getRemoteConfiguration(completion: @escaping (Result<(RemoteConfiguration, Data), NetworkError>) -> Void) {
		let urlRequest = constructRequest(
			url: networkConfiguration.remoteConfigurationUrl,
			method: .GET
		)
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.config)
		decodeSignedJSONData(request: urlRequest, completion: completion)
	}

	func fetchGreencards(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<RemoteGreenCards.Response, NetworkError>) -> Void) {

		do {
			let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
			let urlRequest = constructRequest(
				url: networkConfiguration.credentialUrl,
				method: .POST,
				body: jsonData
			)
			sessionDelegate?.setSecurityStrategy(SecurityStrategy.data)
			decodeSignedJSONData(request: urlRequest, completion: completion)
		} catch {
			logError("Could not serialize dictionary")
			completion(.failure(.encodingError))
		}
	}

	/// Get the test providers
	/// - Parameter completion: completion handler
	func fetchTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.providersUrl,
			method: .GET
		)
		func open(result: Result<ArrayEnvelope<TestProvider>, NetworkError>) {
			completion(result.map { $0.items })
		}

		sessionDelegate?.setSecurityStrategy(SecurityStrategy.data)
		decodeSignedJSONData(request: urlRequest, completion: open)
	}

	/// Get the event providers
	/// - Parameter completion: completion handler
	func fetchEventProviders(completion: @escaping (Result<[EventFlow.EventProvider], NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.providersUrl,
			method: .GET
		)
		func open(result: Result<ArrayEnvelope<EventFlow.EventProvider>, NetworkError>) {
			completion(result.map { $0.items })
		}

		sessionDelegate?.setSecurityStrategy(SecurityStrategy.data)
		decodeSignedJSONData(request: urlRequest, completion: open)
	}

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
		completion: @escaping (Result<(TestResultWrapper, SignedResponse), NetworkError>) -> Void) {

		guard let providerUrl = provider.resultURL else {
			self.logError("No url provided for \(provider)")
			completion(.failure(NetworkError.invalidRequest))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(token.token)",
			HTTPHeaderKey.acceptedContentType: HTTPContentType.json.rawValue,
			HTTPHeaderKey.tokenProtocolVersion: token.protocolVersion
		]
		var body: Data?

		if let requiredCode = code {
			let dictionary: [String: AnyObject] = ["verificationCode": requiredCode as AnyObject]
			body = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
		}
		let urlRequest = constructRequest(url: providerUrl, method: .POST, body: body, headers: headers)
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.provider(provider))
		decodedAndReturnSignedJSONData(request: urlRequest, ignore400: true, completion: completion)
	}

	/// Get a unomi result (check if a event provider knows me)
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEventInformation(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<EventFlow.EventInformationAvailable, NetworkError>) -> Void) {

		guard let providerUrl = provider.unomiURL else {
			self.logError("No url provided for \(provider.name)")
			completion(.failure(NetworkError.invalidRequest))
			return
		}

		guard let accessToken = provider.accessToken?.unomiAccessToken else {
			self.logError("No unomi token provided for \(provider.name)")
			completion(.failure(NetworkError.invalidRequest))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(accessToken)",
			HTTPHeaderKey.acceptedContentType: HTTPContentType.json.rawValue,
			HTTPHeaderKey.tokenProtocolVersion: "3.0"
		]

		var body: Data?
		if let filter = filter {
			let dictionary: [String: AnyObject] = ["filter": filter as AnyObject]
			body = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
		}

		let urlRequest = constructRequest(url: providerUrl, method: .POST, body: body, headers: headers)
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.provider(provider))
		
		decodeSignedJSONData(request: urlRequest, ignore400: true, completion: completion)
	}

	/// Get  events from an event provider
	/// - Parameters:
	///   - provider: the event provider
	///   - filter: filter on test or vaccination
	///   - completion: the completion handler
	func fetchEvents(
		provider: EventFlow.EventProvider,
		filter: String?,
		completion: @escaping (Result<(EventFlow.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {

		guard let providerUrl = provider.eventURL else {
			self.logError("No url provided for \(provider.name)")
			completion(.failure(NetworkError.invalidRequest))
			return
		}

		guard let accessToken = provider.accessToken?.eventAccessToken else {
			self.logError("No event token provided for \(provider.name)")
			completion(.failure(NetworkError.invalidRequest))
			return
		}

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(accessToken)",
			HTTPHeaderKey.acceptedContentType: HTTPContentType.json.rawValue,
			HTTPHeaderKey.tokenProtocolVersion: "3.0"
		]

		var body: Data?
		if let filter = filter {
			let dictionary: [String: AnyObject] = ["filter": filter as AnyObject]
			body = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
		}

		let urlRequest = constructRequest(url: providerUrl, method: .POST, body: body, headers: headers)
		sessionDelegate?.setSecurityStrategy(SecurityStrategy.provider(provider))
		decodedAndReturnSignedJSONData(request: urlRequest, ignore400: true, completion: completion)
	}
	
	// MARK: - Construct Request
	
	private func constructRequest(
		url: URL?,
		method: HTTPMethod = .GET,
		body: Encodable? = nil,
		headers: [HTTPHeaderKey: String] = [:]) -> Result<URLRequest, NetworkError> {

		guard let url = url else {
			return .failure(.invalidRequest)
		}
		
		var request = URLRequest(
			url: url,
			cachePolicy: .useProtocolCachePolicy,
			timeoutInterval: 30)
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
		} else {
			if let body = body.flatMap({ try? self.jsonEncoder.encode(AnyEncodable($0)) }) {
				request.httpBody = body
			}
		}
		
		logVerbose("--REQUEST--")
		if let url = request.url { logVerbose(url.debugDescription) }
		if let allHTTPHeaderFields = request.allHTTPHeaderFields { logVerbose(allHTTPHeaderFields.debugDescription) }
		if let httpBody = request.httpBody { logVerbose(String(data: httpBody, encoding: .utf8)!) }
		logVerbose("--END REQUEST--")
		
		return .success(request)
	}
	
	// MARK: - Download Data
	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		session
			.dataTask(with: request, completionHandler: completionHandler)
			.resume()
	}
	
	private func data(request: Result<URLRequest, NetworkError>, ignore400: Bool = false, completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {
		switch request {
			case let .success(request):
				data(request: request, ignore400: ignore400, completion: completion)
			case let .failure(error):
				completion(.failure(error))
		}
	}
	
	private func data(request: URLRequest, ignore400: Bool = false, completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {
		dataTask(with: request) { data, response, error in
			self.handleNetworkResponse(
				data,
				response: response,
				error: error,
				ignore400: ignore400,
				completion: completion)
		}
	}
	
	private func decodedJSONData<Object: Decodable>(request: Result<URLRequest, NetworkError>, ignore400: Bool = false, completion: @escaping (Result<Object, NetworkError>) -> Void) {
		data(request: request, ignore400: ignore400) { result in
			let decodedResult: Result<Object, NetworkError> = self.jsonResponseHandler(result: result)
			
			DispatchQueue.main.async {
				completion(decodedResult)
			}
		}
	}

	/// Decode a signed response into JSON
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler
	private func decodeSignedJSONData<Object: Decodable>(
		request: Result<URLRequest, NetworkError>,
		ignore400: Bool = false,
		completion: @escaping (Result<(Object, Data), NetworkError>) -> Void) {
		// Fetch data
		data(request: request, ignore400: ignore400) { (result: Result<(URLResponse, Data), NetworkError>) in

			/// Decode to SignedResult
			let signedResult: Result<SignedResponse, NetworkError> = self.jsonResponseHandler(result: result)
			switch signedResult {
				case let .success(signedResponse):

					if let decodedPayloadData = Data(base64Encoded: signedResponse.payload),
					   let signatureData = Data(base64Encoded: signedResponse.signature) {

						// Validate signature (on the base64 payload)
						self.validator.validate(data: decodedPayloadData, signature: signatureData) { valid in
							if valid {
								let decodedResult: Result<Object, NetworkResponseHandleError> = self.decodeJson(data: decodedPayloadData)
								DispatchQueue.main.async {
									switch (decodedResult, decodedPayloadData) {
										case (.success(let object), let decodedPayloadData):
											completion(.success((object, decodedPayloadData)))
										case (.failure(let responseError), _):
											completion(.failure(responseError.asNetworkError))
									}
								}
							} else {
								self.logError("We got an invalid signature!")
								completion(.failure(NetworkResponseHandleError.invalidSignature.asNetworkError))
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
	///   - completion: completion handler
	private func decodeSignedJSONData<Object: Decodable>(
		request: Result<URLRequest, NetworkError>,
		ignore400: Bool = false,
		completion: @escaping (Result<Object, NetworkError>) -> Void) {
		
		decodeSignedJSONData(request: request, ignore400: ignore400) { (result: Result<(Object, Data), NetworkError>) in
			switch result {
				case .success((let object, _)):
					completion(.success(object))
				case .failure(let error):
					completion(.failure(error))
			}
		}
	}

	/// Decode a signed response into JSON
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler
	private func decodedAndReturnSignedJSONData<Object: Decodable>(
		request: Result<URLRequest, NetworkError>,
		ignore400: Bool = false,
		completion: @escaping (Result<(Object, SignedResponse), NetworkError>) -> Void) {
		data(request: request, ignore400: ignore400) { [self] result in

			/// Decode to SignedResult
			let signedResult: Result<SignedResponse, NetworkError> = self.jsonResponseHandler(result: result)
			switch signedResult {
				case let .success(signedResponse):

					if let decodedPayloadData = Data(base64Encoded: signedResponse.payload),
					   let signatureData = Data(base64Encoded: signedResponse.signature) {

						if let checker = self.sessionDelegate?.checker {
							checker.validate(data: decodedPayloadData, signature: signatureData) { valid in
								if valid {
									let decodedResult: Result<Object, NetworkResponseHandleError> = self.decodeJson(data: decodedPayloadData)
									DispatchQueue.main.async {
										switch decodedResult {
											case let .success(object):
												completion(.success((object, signedResponse)))
											case let .failure(responseError):
												completion(.failure(responseError.asNetworkError))
										}
									}
								} else {
									self.logError("We got an invalid signature!")
									completion(.failure(NetworkResponseHandleError.invalidSignature.asNetworkError))
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

	/// Decode a signed response into Data
	/// - Parameters:
	///   - request: the network request
	///   - completion: completion handler
	private func decodedSignedData(
		request: Result<URLRequest, NetworkError>,
		ignore400: Bool = false,
		completion: @escaping (Result<Data, NetworkError>) -> Void) {
		data(request: request, ignore400: ignore400) { result in

			/// Decode to SignedResult
			let signedResult: Result<SignedResponse, NetworkError> = self.jsonResponseHandler(result: result)
			switch signedResult {
				case let .success(signedResponse):

					if let decodedPayloadData = Data(base64Encoded: signedResponse.payload),
					   let signatureData = Data(base64Encoded: signedResponse.signature) {

						// Validate signature (on the base64 payload)
						self.validator.validate(data: decodedPayloadData, signature: signatureData) { valid in
							if valid {
								completion(.success(decodedPayloadData))
							} else {
								self.logError("We got an invalid signature!")
								completion(.failure(NetworkResponseHandleError.invalidSignature.asNetworkError))
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
	
	// MARK: - Utilities
	
	/// Checks for failures and inspects status code
	private func handleNetworkResponse<Object>(
		_ object: Object?,
		response: URLResponse?,
		error: Error?,
		ignore400: Bool = false,
		completion: @escaping (Result<(URLResponse, Object), NetworkError>) -> Void) {
		if error != nil {
			completion(.failure(.invalidResponse))
			return
		}
		
		logVerbose("--RESPONSE--")
		if let response = response as? HTTPURLResponse {
			logDebug("Finished response to URL \(response.url?.absoluteString ?? "") with status \(response.statusCode)")
			
//			let headers = response.allHeaderFields.map { header, value in
//				return String("\(header): \(value)")
//			}.joined(separator: "\n")
//			
//			logDebug("Response headers: \n\(headers)")
			
			if let objectData = object as? Data, let body = String(data: objectData, encoding: .utf8) {
				if !body.starts(with: "{\"signature") && !body.starts(with: "{\"payload") {
					logVerbose("Response body: \n\(body)")
				}
			}
		} else if let error = error {
			logDebug("Error with response: \(error)")
		}
		
		logVerbose("--END RESPONSE--")
		
		guard let response = response,
			  let object = object else {
			completion(.failure(.invalidResponse))
			return
		}

		if let error = self.inspect(response: response) {
			if error == .resourceNotFound && !ignore400 {
				completion(.failure(error))
				return
			}
		}
		
		completion(.success((response, object)))
	}
	
	/// Utility function to decode JSON
	private func decodeJson<Object: Decodable>(data: Data) -> Result<Object, NetworkResponseHandleError> {
		do {
			let object = try self.jsonDecoder.decode(Object.self, from: data)
			self.logVerbose("Response Object: \(object)")
			return .success(object)
		} catch {
//			if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
				self.logDebug("Raw: \(String(decoding: data, as: UTF8.self))")
//				self.logDebug("Raw JSON: \(json)")
//			}
			self.logError("Error Deserializing \(Object.self): \(error)")
			return .failure(.cannotDeserialize)
		}
	}
	
	/// Response handler which decodes JSON
	private func jsonResponseHandler<Object: Decodable>(
		result: Result<(URLResponse, Data), NetworkError>) -> Result<Object, NetworkError> {
		switch result {
			case let .success(result):
				return decodeJson(data: result.1)
					.mapError {
						$0.asNetworkError
						
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
	
	private let session: URLSession
	// swiftlint:disable:next weak_delegate
	private let sessionDelegate: NetworkManagerURLSessionDelegate? // swiftlint ignore: this // hold on to delegate to prevent deallocation
	
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
//		decoder.dateDecodingStrategy = .formatted(dateFormatter)
		decoder.dateDecodingStrategy = .iso8601
		decoder.source = .api
		return decoder
	}()
}

private extension Result where Success == (URLResponse, Data) {
	
	func data() -> Data? {
		switch self {
			case .success((_, let data)):
				return data
			default:
				return nil
		}
	}
}
