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

class NetworkManagerUnomiTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/unomi"
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
		usages: [.vaccination]
	)
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, logHandler: LogHandler())
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	// MARK: Pre flight errors
	
	func test_fetchEventInformation_noUrl() {
		
		// Given
		let noUnomiUrlprovider = EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: nil,
			eventUrl: URL(string: "https://coronacheck.nl/event"),
			cmsCertificates: [OpenSSLData.providerCertificate],
			tlsCertificates: [OpenSSLData.providerCertificate],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination]
		)
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: noUnomiUrlprovider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.provider(provider: "CC", statusCode: nil, response: nil, error: .invalidRequest)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_noAccessToken() {
		
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
			usages: [.vaccination]
		)
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: noAccessTokenprovider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.provider(provider: "CC", statusCode: nil, response: nil, error: .invalidRequest)
				done()
			}
		}
	}
	
	// MARK: Network errors
	
	func test_fetchEventInformation_noInternet() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_serverBusy() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_timeOut() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_invalidHost() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_networkConnectionLost() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_cancelled() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_unknownError() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}
	
	// MARK: Signed Response Checks
	
	func test_fetchEventInformation_unsignedResponse() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"provider_identifier": "CC",
					"protocolVersion": "3.0",
					"informationAvailable": true
				],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_signedResponse_signatureNotBase64() {
		
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
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_signedResponse_payloadNotBase64() {
		
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
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_signedResponse_invalidSignature() {
		
		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = false
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			logHandler: LogHandler()
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
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_signedResponse_invalidContent() {
		
		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			logHandler: LogHandler()
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
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_fetchEventInformation_validContent() {
		
		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			logHandler: LogHandler()
		)
		
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "eyJwcm92aWRlcklkZW50aWZpZXIiOiJDQyIsICJwcm90b2NvbFZlcnNpb24iOiIzLjAiLCAiaW5mb3JtYXRpb25BdmFpbGFibGUiOiB0cnVlfQ==",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventInformation(provider: self.provider) { result in
				
				// Then
				expect(result.isSuccess) == true
				expect(result.successValue) == EventFlow.EventInformationAvailable(providerIdentifier: "CC", protocolVersion: "3.0", informationAvailable: true)
				done()
			}
		}
	}
}
