/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class NetworkManager: NetworkManaging, Logging {

	private(set) var loggingCategory: String = "Network"
	private(set) var networkConfiguration: NetworkConfiguration
	
	required init(configuration: NetworkConfiguration) {

		self.networkConfiguration = configuration
		self.sessionDelegate = NetworkManagerURLSessionDelegate(configuration)
		self.session = URLSession(
			configuration: .ephemeral,
			delegate: sessionDelegate,
			delegateQueue: nil)
	}
	
	func getRemoteConfiguration(completion: @escaping (Result<RemoteConfiguration, NetworkError>) -> Void) {
		let urlRequest = constructRequest(
			url: networkConfiguration.remoteConfigurationUrl,
			method: .GET
		)

		decodedSignedJSONData(request: urlRequest, completion: completion)
	}

	/// Get the nonce
	/// - Parameter completion: completion handler
	func getNonce(completion: @escaping (Result<NonceEnvelope, NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.nonceUrl,
			method: .GET
		)

		decodedSignedJSONData(request: urlRequest, completion: completion)
	}

	/// Fetch the test results with issue signature message
	/// - Parameters:
	///   - dictionary: dictionary
	///   - completionHandler: the completion handler
	func fetchTestResultsWithISM(
		dictionary: [String: AnyObject],
		completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {

		do {
			let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
			let urlRequest = constructRequest(
				url: networkConfiguration.testResultIsmUrl,
				method: .POST,
				body: jsonData
			)

			data(request: urlRequest) { resultwrapper in
				DispatchQueue.main.async {
					completion(resultwrapper)
				}
			}
		} catch {
			logError("Could not serialize dictionary")
			completion(.failure(.encodingError))
		}
	}

	/// Get the test providers
	/// - Parameter completion: completion handler
	func getTestProviders(completion: @escaping (Result<[TestProvider], NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.testProvidersUrl,
			method: .GET
		)

		func open(result: Result<ArrayEnvelope<TestProvider>, NetworkError>) {
			completion(result.map { $0.items })
		}

		decodedSignedJSONData(request: urlRequest, completion: open)
	}

	/// Get the test types
	/// - Parameter completion: completion handler
	func getTestTypes(completion: @escaping (Result<[TestType], NetworkError>) -> Void) {

		let urlRequest = constructRequest(
			url: networkConfiguration.testTypesUrl,
			method: .GET
		)

		func open(result: Result<ArrayEnvelope<TestType>, NetworkError>) {
			completion(result.map { $0.items })
		}

		decodedSignedJSONData(request: urlRequest, completion: open)
	}

	/// Get a test result
	/// - Parameters:
	///   - providerUrl: the url of the test provider
	///   - token: the token to fetch
	///   - code: the code for verification
	///   - completion: the completion handler
	func getTestResult(
		providerUrl: URL,
		token: TestToken,
		code: String?,
		completion: @escaping (Result<TestResultWrapper, NetworkError>) -> Void) {

		let headers: [HTTPHeaderKey: String] = [
			HTTPHeaderKey.authorization: "Bearer \(token.requestToken)",
			HTTPHeaderKey.acceptedContentType: HTTPContentType.json.rawValue
		]

		if var urlComps = URLComponents(url: providerUrl, resolvingAgainstBaseURL: false) {
			urlComps.queryItems = [URLQueryItem(name: "sigInline", value: "1")]
			if let appendedUrl = urlComps.url {

				var body: Data?

				if let requiredCode = code {
					let dictionary: [String: AnyObject] = ["verificationCode": requiredCode as AnyObject]
					body = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
				}
				let urlRequest = constructRequest(url: appendedUrl, method: .POST, body: body, headers: headers)

				decodedSignedJSONData(request: urlRequest, completion: completion)
			}
		}
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
			timeoutInterval: 10)
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
		
		logDebug("--REQUEST--")
		if let url = request.url { logDebug(url.debugDescription) }
		if let allHTTPHeaderFields = request.allHTTPHeaderFields { logDebug(allHTTPHeaderFields.debugDescription) }
		if let httpBody = request.httpBody { logDebug(String(data: httpBody, encoding: .utf8)!) }
		logDebug("--END REQUEST--")
		
		return .success(request)
	}
	
	// MARK: - Download Data
	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		session
			.dataTask(with: request, completionHandler: completionHandler)
			.resume()
	}
	
	private func data(request: Result<URLRequest, NetworkError>, completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {
		switch request {
			case let .success(request):
				data(request: request, completion: completion)
			case let .failure(error):
				completion(.failure(error))
		}
	}
	
	private func data(request: URLRequest, completion: @escaping (Result<(URLResponse, Data), NetworkError>) -> Void) {
		dataTask(with: request) { data, response, error in
			self.handleNetworkResponse(
				data,
				response: response,
				error: error,
				completion: completion)
		}
	}
	
	private func decodedJSONData<Object: Decodable>(request: Result<URLRequest, NetworkError>, completion: @escaping (Result<Object, NetworkError>) -> Void) {
		data(request: request) { result in
			let decodedResult: Result<Object, NetworkError> = self.jsonResponseHandler(result: result)
			
			DispatchQueue.main.async {
				completion(decodedResult)
			}
		}
	}

	private func decodedSignedJSONData<Object: Decodable>(
		request: Result<URLRequest, NetworkError>,
		completion: @escaping (Result<Object, NetworkError>) -> Void) {
		data(request: request) { result in

			/// Decode to SignedResult
			let signedResult: Result<SignedResponse, NetworkError> = self.jsonResponseHandler(result: result)
			switch signedResult {
				case let .success(signedResponse):
                    
                    if let payloadData = signedResponse.payload.data(using: .utf8),
                       let decodedPayloadData = Data(base64Encoded: signedResponse.payload),
                  let signatureData = Data(base64Encoded: signedResponse.signature) {
						let validator = CryptoUtility(signatureValidator: SignatureValidator())
                        validator.validate(data: payloadData, signature: signatureData) { valid in
							// Todo: return error on invalid
                            self.logDebug("We got: \(decodedPayloadData)")
                            let decodedResult: Result<Object, NetworkResponseHandleError> = self.decodeJson(data: decodedPayloadData)
							DispatchQueue.main.async {
								switch decodedResult {
									case let .success(object):
										completion(.success(object))
									case let .failure(responseError):
										completion(.failure(responseError.asNetworkError))
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
	
	// MARK: - Utilities
	
	/// Checks for failures and inspects status code
	private func handleNetworkResponse<Object>(
		_ object: Object?,
		response: URLResponse?,
		error: Error?,
		completion: @escaping (Result<(URLResponse, Object), NetworkError>) -> Void) {
		if error != nil {
			completion(.failure(.invalidResponse))
			return
		}
		
		logDebug("--RESPONSE--")
		if let response = response as? HTTPURLResponse {
			logDebug("Finished response to URL \(response.url?.absoluteString ?? "") with status \(response.statusCode)")
			
			let headers = response.allHeaderFields.map { header, value in
				return String("\(header): \(value)")
			}.joined(separator: "\n")
			
			logDebug("Response headers: \n\(headers)")
			
			if let objectData = object as? Data, let body = String(data: objectData, encoding: .utf8) {
				logDebug("Resonse body: \n\(body)")
			}
		} else if let error = error {
			logDebug("Error with response: \(error)")
		}
		
		logDebug("--END RESPONSE--")
		
		guard let response = response,
			  let object = object else {
			completion(.failure(.invalidResponse))
			return
		}

		if let error = self.inspect(response: response) {
			completion(.failure(error))
			return
		}
		
		completion(.success((response, object)))
	}
	
	/// Utility function to decode JSON
	private func decodeJson<Object: Decodable>(data: Data) -> Result<Object, NetworkResponseHandleError> {
		do {
			let object = try self.jsonDecoder.decode(Object.self, from: data)
			self.logDebug("Response Object: \(object)")
			return .success(object)
		} catch {
			if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
				self.logDebug("Raw JSON: \(json)")
			}
			self.logError("Error Deserializing \(Object.self): \(error)")
			return .failure(.cannotDeserialize)
		}
	}
	
	/// Response handler which decodes JSON
	private func jsonResponseHandler<Object: Decodable>(result: Result<(URLResponse, Data), NetworkError>) -> Result<Object, NetworkError> {
		switch result {
			case let .success(result):
				return decodeJson(data: result.1)
					.mapError { $0.asNetworkError }
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
	private let sessionDelegate: URLSessionDelegate? // swiftlint ignore: this // hold on to delegate to prevent deallocation
	
	private lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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
		decoder.dateDecodingStrategy = .formatted(dateFormatter)
		decoder.source = .api
		return decoder
	}()
}
