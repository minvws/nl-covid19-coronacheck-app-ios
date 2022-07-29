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

class NetworkManagerEventTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/event"
	private let provider = EventFlow.EventProvider(
		identifier: "CC",
		name: "CoronaCheck",
		unomiUrl: URL(string: "https://coronacheck.nl/unomi"),
		eventUrl: URL(string: "https://coronacheck.nl/event"),
		cmsCertificates: [OpenSSLData.providerCertificate],
		tlsCertificates: [OpenSSLData.providerCertificate],
		accessToken: EventFlow.AccessToken(
			providerIdentifier: "CC",
			unomiAccessToken: "accessToken",
			eventAccessToken: "eventToken"
		),
		eventInformationAvailable: nil,
		usages: [.vaccination],
		providerAuthentication: [.manyAuthenticationExchange, .patientAuthenticationProvider]
	)
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development)
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	// MARK: Pre flight errors
	
	func test_fetchEvents_noUrl() {

		// Given
		let noEventsUrlprovider = EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl/unomi"),
			eventUrl: nil,
			cmsCertificates: [OpenSSLData.providerCertificate],
			tlsCertificates: [OpenSSLData.providerCertificate],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination],
			providerAuthentication: [.manyAuthenticationExchange, .patientAuthenticationProvider]
		)

		// When
		waitUntil { done in
			self.sut.fetchEvents(provider: noEventsUrlprovider) { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.provider(provider: "CC", statusCode: nil, response: nil, error: .invalidRequest)
				done()
			}
		}
	}
	
	func test_fetchEvents_noAccessToken() {
		
		// Given
		let noAccessTokenprovider = EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl/unomi"),
			eventUrl: URL(string: "https://coronacheck.nl/event"),
			cmsCertificates: [OpenSSLData.providerCertificate],
			tlsCertificates: [OpenSSLData.providerCertificate],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination],
			providerAuthentication: [.manyAuthenticationExchange, .patientAuthenticationProvider]
		)
		
		// When
		waitUntil { done in
			self.sut.fetchEvents(provider: noAccessTokenprovider) { result in
				
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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
							"type": "vaccination",
							"unique": "092841f0-eded-4336-923f-6f2df27bbb55",
							"isSpecimen": true,
							"vaccination": [
								"date": "2022-03-14",
								"hpkCode": "2924528",
								"type": "",
								"manufacturer": "",
								"brand": "",
								"completedByMedicalStatement": false,
								"completedByPersonalStatement": false,
								"completionReason": nil,
								"country": "NL",
								"doseNumber": nil,
								"totalDoses": nil
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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			signatureValidationFactory: signatureValidationFactorySpy
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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			signatureValidationFactory: signatureValidationFactorySpy
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
			self.sut.fetchEvents(provider: self.provider) { result in

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
			signatureValidationFactory: signatureValidationFactorySpy
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "eyJwcm90b2NvbFZlcnNpb24iOiIzLjAiLCJwcm92aWRlcklkZW50aWZpZXIiOiJaWloiLCJzdGF0dXMiOiJjb21wbGV0ZSIsImhvbGRlciI6eyJmaXJzdE5hbWUiOiJDb3JyaWUiLCJpbmZpeCI6InZhbiIsImxhc3ROYW1lIjoiR2VlciIsImJpcnRoRGF0ZSI6IjE5NjAtMDEtMDEifSwiZXZlbnRzIjpbeyJ0eXBlIjoidmFjY2luYXRpb24iLCJ1bmlxdWUiOiIwOTI4NDFmMC1lZGVkLTQzMzYtOTIzZi02ZjJkZjI3YmJiNTUiLCJpc1NwZWNpbWVuIjp0cnVlLCJ2YWNjaW5hdGlvbiI6eyJkYXRlIjoiMjAyMi0wMy0xNCIsImhwa0NvZGUiOiIyOTI0NTI4IiwidHlwZSI6IiIsIm1hbnVmYWN0dXJlciI6IiIsImJyYW5kIjoiIiwiY29tcGxldGVkQnlNZWRpY2FsU3RhdGVtZW50IjpmYWxzZSwiY29tcGxldGVkQnlQZXJzb25hbFN0YXRlbWVudCI6ZmFsc2UsImNvbXBsZXRpb25SZWFzb24iOm51bGwsImNvdW50cnkiOiJOTCIsImRvc2VOdW1iZXIiOm51bGwsInRvdGFsRG9zZXMiOm51bGx9fV19",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEvents(provider: self.provider) { result in

				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.0 is EventFlow.EventResultWrapper) == true
				expect(result.successValue?.0.protocolVersion) == "3.0"
				expect(result.successValue?.0.identity?.firstName) == "Corrie"
				expect(result.successValue?.0.events?.first?.vaccination?.hpkCode) == "2924528"
				expect(result.successValue?.0.events?.first?.unique) == "092841f0-eded-4336-923f-6f2df27bbb55"
				done()
			}
		}
	}
	
	func test_fetchEvents_validContent_verificationRequired() throws {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "eyJwcm90b2NvbFZlcnNpb24iOiIzLjAiLCJwcm92aWRlcklkZW50aWZpZXIiOiJaWloiLCJzdGF0dXMiOiJ2ZXJpZmljYXRpb25fcmVxdWlyZWQifQ==",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.fetchEvents(provider: self.provider) { result in

				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.0 is EventFlow.EventResultWrapper) == true
				expect(result.successValue?.0.protocolVersion) == "3.0"
				expect(result.successValue?.0.status) == .verificationRequired
				expect(result.successValue?.0.identity) == nil
				expect(result.successValue?.0.events) == nil
				done()
			}
		}
	}
}
