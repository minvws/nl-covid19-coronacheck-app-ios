/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
import XCTest
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift

class NetworkManagerEventProvidersTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v8/holder/config_providers"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, logHandler: LogHandlerSpy())
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	// MARK: Network errors

	func test_fetchEventProviders_noInternet() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}

	func test_fetchEventProviders_serverBusy() {

		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}

	func test_fetchEventProviders_timeOut() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}

	func test_fetchEventProviders_invalidHost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}

	func test_fetchEventProviders_networkConnectionLost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}

	func test_fetchEventProviders_cancelled() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}

	func test_fetchEventProviders_unknownError() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}

	// MARK: Signed Response Checks

	func test_fetchEventProviders_unsignedResponse() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"tokenProviders": [
						[
							"name": "CTP-TEST-MVWS1",
							"identifier": "ZZZ",
							"unomiUrl": "https://coronacheck.nl/api/unomi",
							"eventUrl": "https://coronacheck.nl/api/event",
							"cms": [
								OpenSSLData.providerCertificate
							],
							"tls": [
								OpenSSLData.providerCertificate
							],
							"usage": [
								"v"
							]
						]
					]
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEventProviders_signedResponse_signatureNotBase64() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test",
					"signature": "test\n"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEventProviders_signedResponse_payloadNotBase64() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test\n",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEventProviders_signedResponse_invalidSignature() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = false
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			logHandler: LogHandlerSpy()
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)
				done()
			}
		}
	}

	func test_fetchEventProviders_signedResponse_invalidContent() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			logHandler: LogHandlerSpy()
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEventProviders_validContent() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			logHandler: LogHandlerSpy()
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "eyJldmVudFByb3ZpZGVycyI6W3sibmFtZSI6IkNDIFRlc3QgUHJvdmlkZXIiLCJpZGVudGlmaWVyIjoiQ1RQIiwidW5vbWlVcmwiOiJodHRwczovL2Nvcm9uYWNoZWNrLm5sL2FwaS91bm9taSIsImV2ZW50VXJsIjoiaHR0cHM6Ly9jb3JvbmFjaGVjay5ubC9hcGkvZXZlbnQiLCJjbXMiOlsidGVzdCJdLCJ0bHMiOlsidGVzdCJdLCJ1c2FnZSI6WyJwdCIsIm50IiwiciIsInYiXX1dfQ==",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEventProviders { result in

				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.first is EventFlow.EventProvider) == true
				expect(result.successValue?.first?.name) == "CC Test Provider"
				expect(result.successValue?.first?.identifier) == "CTP"
				expect(result.successValue?.first?.unomiUrl) == URL(string: "https://coronacheck.nl/api/unomi")
				expect(result.successValue?.first?.eventUrl) == URL(string: "https://coronacheck.nl/api/event")
				expect(result.successValue?.first?.cmsCertificates.first) == "test"
				expect(result.successValue?.first?.tlsCertificates.first) == "test"
				done()
			}
		}
	}
}
