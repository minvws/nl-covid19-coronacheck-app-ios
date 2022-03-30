/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		sut = NetworkManager(configuration: NetworkConfiguration.development)
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}

	// MARK: Pre flight errors
	
	func test_fetchEventInformation_noUrl() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_noInternet")
		let noUnomitUrlprovider = EventFlow.EventProvider(
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
		sut.fetchEventInformation(provider: noUnomitUrlprovider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.provider(provider: "CC", statusCode: nil, response: nil, error: .invalidRequest)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchEventInformation_noAccessToken() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_noAccessToken")
		let noUnomitUrlprovider = EventFlow.EventProvider(
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
		sut.fetchEventInformation(provider: noUnomitUrlprovider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.provider(provider: "CC", statusCode: nil, response: nil, error: .invalidRequest)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	// MARK: Network errors
	
	func test_fetchEventInformation_noInternet() {

		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_noInternet")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.fetchEventInformation(provider: provider) { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_serverBusy() {

		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_serverBusy")

		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}

		// When
		sut.fetchEventInformation(provider: provider) { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_timeOut() {

		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_timeOut")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.fetchEventInformation(provider: provider) { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_invalidHost() {

		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_invalidHost")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.fetchEventInformation(provider: provider) { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_networkConnectionLost() {

		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_networkConnectionLost")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.fetchEventInformation(provider: provider) { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_unknownError() {

		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_unknownError")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.fetchEventInformation(provider: provider) { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}
	
	// MARK: Signed Response Checks
	
	func test_fetchEventInformation_unsignedResponse() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_unsignedResponse")
		
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
		sut.fetchEventInformation(provider: provider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_signedResponse_signatureNotBase64() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_signedResponse_signatureNotBase64")
		
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
		sut.fetchEventInformation(provider: provider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchEventInformation_signedResponse_payloadNotBase64() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_signedResponse_payloadNotBase64")
		
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
		sut.fetchEventInformation(provider: provider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchEventInformation_signedResponse_invalidSignature() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_signedResponse_invalidSignature")
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = false
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(configuration: NetworkConfiguration.development, signatureValidationFactory: signatureValidationFactorySpy)
		
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
		sut.fetchEventInformation(provider: provider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchEventInformation_signedResponse_invalidContent() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_signedResponse_invalidContent")
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(configuration: NetworkConfiguration.development, signatureValidationFactory: signatureValidationFactorySpy)
		
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
		sut.fetchEventInformation(provider: provider) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_fetchEventInformation_validContent() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchEventInformation_validContent")
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(configuration: NetworkConfiguration.development, signatureValidationFactory: signatureValidationFactorySpy)
		
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
		sut.fetchEventInformation(provider: provider) { result in
			
			// Then
			expect(result.isSuccess) == true
			expect(result.successValue) == EventFlow.EventInformationAvailable(providerIdentifier: "CC", protocolVersion: "3.0", informationAvailable: true)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
}
