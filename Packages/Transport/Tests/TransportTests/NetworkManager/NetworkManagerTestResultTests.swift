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

class NetworkManagerTestResultsTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/testResult"
	private let provider = TestProvider(
		identifier: "CC",
		name: "CoronaCheck",
		resultURLString: "https://coronacheck.nl/testResult",
		cmsCertificates: [OpenSSLData.providerCMSCertificate],
		tlsCertificates: [OpenSSLData.providerTLSCertificate],
		usages: [.negativeTest]
	)
	
	private let token = RequestToken(
		token: "QGJ6Y2SBSY",
		protocolVersion: "3.0",
		providerIdentifier: "CC"
	)
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, dataTLSCertificates: { [] })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	// MARK: Pre flight errors
	
	func test_fetchTestResult_invalidUrl() {

		// Given
		let invalidResultsUrlprovider = TestProvider(
			identifier: "CC",
			name: "CoronaCheck",
			resultURLString: "https://coronacheck.nl?filter|test",
			cmsCertificates: [OpenSSLData.providerCMSCertificate],
			tlsCertificates: [OpenSSLData.providerTLSCertificate],
			usages: [.negativeTest]
		)

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: invalidResultsUrlprovider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.provider(provider: "CC", statusCode: nil, response: nil, error: .invalidRequest)
				done()
			}
		}
	}

	// MARK: Network errors

	func test_fetchEvents_noInternet() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}

	func test_fetchEvents_serverBusy() {

		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}

	func test_fetchEvents_timeOut() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}

	func test_fetchEvents_invalidHost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}

	func test_fetchEvents_networkConnectionLost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}

	func test_fetchEvents_cancelled() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}

	func test_fetchEvents_unknownError() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}

	// MARK: Signed Response Checks
	
	func test_fetchEvents_unsignedResponse() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"provider_identifier": "CC",
					"protocolVersion": "3.0",
					"status": "complete",
					"holder": [
						"firstName": "Corrie",
						"infix": "van",
						"lastName": "Geer",
						"birthDate": "1960-01-01"
					],
					"events": [
						[
							"type": "negativetest",
							"unique": "e5147b810046cd24fde6d5183cb27a31ff05b423",
							"isSpecimen": true,
							"negativetest": [
								"sampleDate": "2022-04-13T04:19:00Z",
								"negativeResult": true,
								"facility": "Yellow Banana Test Center",
								"sampleMethod": nil,
								"type": "LP217198-3",
								"name": "Test Rolus",
								"manufacturer": "2696"
							] as [String: Any?]
						] as [String: Any]
					]
				] as [String: Any],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEvents_signedResponse_signatureNotBase64() {

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
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEvents_signedResponse_payloadNotBase64() {

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
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEvents_signedResponse_invalidSignature() {

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
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)
				done()
			}
		}
	}

	func test_fetchEvents_signedResponse_invalidContent() {

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
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_fetchEvents_validContent() throws {

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
					"payload": "eyJwcm90b2NvbFZlcnNpb24iOiIzLjAiLCJwcm92aWRlcklkZW50aWZpZXIiOiJaWloiLCJzdGF0dXMiOiJjb21wbGV0ZSIsImhvbGRlciI6eyJmaXJzdE5hbWUiOiJCb2IiLCJsYXN0TmFtZSI6IkJvdXdlciIsImluZml4IjoiZGUiLCJiaXJ0aERhdGUiOiIxOTkyLTA0LTIwIn0sImV2ZW50cyI6W3sidHlwZSI6Im5lZ2F0aXZldGVzdCIsInVuaXF1ZSI6ImU1MTQ3YjgxMDA0NmNkMjRmZGU2ZDUxODNjYjI3YTMxZmYwNWI0MjMiLCJpc1NwZWNpbWVuIjp0cnVlLCJuZWdhdGl2ZXRlc3QiOnsic2FtcGxlRGF0ZSI6IjIwMjItMDQtMTNUMDQ6MTk6MDBaIiwibmVnYXRpdmVSZXN1bHQiOnRydWUsImZhY2lsaXR5IjoiWWVsbG93IEJhbmFuYSBUZXN0IENlbnRlciIsInNhbXBsZU1ldGhvZCI6bnVsbCwidHlwZSI6IkxQMjE3MTk4LTMiLCJuYW1lIjoiVGVzdCBSb2x1cyIsIm1hbnVmYWN0dXJlciI6IjI2OTYifX1dfQ==",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchTestResult(provider: self.provider, token: self.token, code: nil) { result in

				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.0 is EventFlow.EventResultWrapper) == true
				expect(result.successValue?.0.protocolVersion) == "3.0"
				expect(result.successValue?.0.identity?.firstName) == "Bob"
				expect(result.successValue?.0.events?.first?.negativeTest?.sampleDateString) == "2022-04-13T04:19:00Z"
				expect(result.successValue?.0.events?.first?.unique) == "e5147b810046cd24fde6d5183cb27a31ff05b423"
				done()
			}
		}
	}
}
