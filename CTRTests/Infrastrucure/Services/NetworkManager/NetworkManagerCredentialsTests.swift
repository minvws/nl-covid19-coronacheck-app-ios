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

class NetworkManagerCredentialsTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v7/holder/credentials"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development)
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_fetchGreencards_invalidInput() throws {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_invalidInput")
		// This will not serialize into a valid JSONObject
		let bogusStr = try XCTUnwrap(String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian))
		let testDictionary: [String: AnyObject] = ["test": bogusStr as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "accepted"], statusCode: 200, headers: nil)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			
			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_validResponse() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_validResponse")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			// Return valid greencards
			return HTTPStubsResponse(
				jsonObject: [
					"domesticGreencard": [
						"origins": [
							["type": "vaccination",
							 "eventTime": "2021-11-30T00:00:00+00:00",
							 "expirationTime": "2025-11-30T00:00:00+00:00",
							 "validFrom": "2021-12-28T00:00:00+00:00",
							 "doseNumber": 1]
						],
						"createCredentialMessages": "test domestic credentials"
					],
					"euGreencards": [
						[
							"origins": [
								["type": "vaccination",
								 "eventTime": "2021-11-30T00:00:00+00:00",
								 "expirationTime": "2025-11-30T00:00:00+00:00",
								 "validFrom": "2021-12-28T00:00:00+00:00",
								 "doseNumber": 1]
							],
							"credential": "test eu credentials"
						]
					]
				],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			
			// Then
			expect(result.isSuccess) == true
			expect(result.successValue?.domesticGreenCard).toNot(beNil())
			expect(result.successValue?.domesticGreenCard?.origins.first?.type) == "vaccination"
			expect(result.successValue?.euGreenCards).toNot(beEmpty())
			expect(result.successValue?.euGreenCards?.first?.origins.first?.type) == "vaccination"
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_invalidResponse() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_invalidResponse")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_noInternet() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_noInternet")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_serverBusy() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_serverBusy")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_timeOut() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_timeOut")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_invalidHost() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_invalidHost")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_networkConnectionLost() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_networkConnectionLost")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_unknownError() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_unknownError")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func test_fetchGreencards_serverErrorMessage() {
		
		// Given
		let expectation = self.expectation(description: "test_fetchGreencards_serverErrorMessage")
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "error", "code": 99702], statusCode: 500, headers: nil)
		}
		
		// When
		sut.fetchGreencards(dictionary: testDictionary) { result in
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError)
			expectation.fulfill()
		}
		
		// Then
		waitForExpectations(timeout: 10, handler: nil)
	}
}
