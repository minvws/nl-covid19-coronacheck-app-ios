/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import Transport
import XCTest
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift

class NetworkManagerTestProvidersTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v8/holder/config_providers"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, dataTLSCertificates: { [] })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	// MARK: Network errors

	func test_fetchTestProviders_noInternet() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}

	func test_fetchTestProviders_serverBusy() {

		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}

	func test_fetchTestProviders_timeOut() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}

	func test_fetchTestProviders_invalidHost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}

	func test_fetchTestProviders_networkConnectionLost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}

	func test_fetchTestProviders_cancelled() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}

	func test_fetchTestProviders_unknownError() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}

	// MARK: Signed Response Checks

	func test_fetchTestProviders_unsignedResponse() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"tokenProviders": [
						[
							"name": "CTP-TEST-MVWS1",
							"identifier": "ZZZ",
							"url": "https://coronacheck.nl/api/token",
							"cms": [
								OpenSSLData.providerCMSCertificate
							],
							"tls": [
								OpenSSLData.providerTLSCertificate
							],
							"usage": [
								"nt"
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
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchTestProviders_signedResponse_signatureNotBase64() {

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
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchTestProviders_signedResponse_payloadNotBase64() {

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
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchTestProviders_signedResponse_invalidSignature() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = false
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			dataTLSCertificates: { [] }
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
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)
				done()
			}
		}
	}

	func test_fetchTestProviders_signedResponse_invalidContent() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			dataTLSCertificates: { [] }
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
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchTestProviders_validContent() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			dataTLSCertificates: { [] }
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "eyJ0b2tlblByb3ZpZGVycyI6W3sibmFtZSI6IkNDIFRlc3QgUHJvdmlkZXIiLCJpZGVudGlmaWVyIjoiQ1RQIiwidXJsIjoiaHR0cHM6Ly9jb3JvbmFjaGVjay5ubC9hcGkvdG9rZW4iLCJjbXMiOlsidGVzdCJdLCJ0bHMiOlsidGVzdCJdLCJ1c2FnZSI6WyJudCJdfV19",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestProviders { result in

				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.first is TestProvider) == true
				expect(result.successValue?.first?.name) == "CC Test Provider"
				expect(result.successValue?.first?.identifier) == "CTP"
				expect(result.successValue?.first?.resultURL) == URL(string: "https://coronacheck.nl/api/token")
				expect(result.successValue?.first?.cmsCertificates.first) == "test"
				expect(result.successValue?.first?.tlsCertificates.first) == "test"
				done()
			}
		}
	}
}
