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

class NetworkManagerCredentialsTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v9/holder/credentials"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, dataTLSCertificates: { [] })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_fetchGreencards_invalidInput() throws {
		
		// Given
		// This will not serialize into a valid JSONObject
		let bogusStr = try XCTUnwrap(String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian))
		let testDictionary: [String: AnyObject] = ["test": bogusStr as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "accepted"], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)
				done()
			}
		}
	}
	
	func test_fetchGreencards_validResponse() {
		
		// Given
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
							 "doseNumber": 1,
							 "hints": [
								"test_fetchGreencards_validResponse"
							 ]
							] as [String: Any]
						],
						"createCredentialMessages": "test domestic credentials"
					] as [String: Any],
					"euGreencards": [
						[
							"origins": [
								["type": "vaccination",
								 "eventTime": "2021-11-30T00:00:00+00:00",
								 "expirationTime": "2025-11-30T00:00:00+00:00",
								 "validFrom": "2021-12-28T00:00:00+00:00",
								 "doseNumber": 1,
								 "hints": [] as [Any]
								] as [String: Any]
							],
							"credential": "test eu credentials"
						] as [String: Any]
					]
				] as [String: Any],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.domesticGreenCard) != nil
				expect(result.successValue?.domesticGreenCard?.origins.first?.type) == "vaccination"
				expect(result.successValue?.euGreenCards).toNot(beEmpty())
				expect(result.successValue?.euGreenCards?.first?.origins.first?.type) == "vaccination"
				done()
			}
		}
	}
	
	func test_fetchGreencards_invalidResponse() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: [] as [Any], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_fetchGreencards_noInternet() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}
	
	func test_fetchGreencards_serverBusy() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_fetchGreencards_timeOut() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}
	
	func test_fetchGreencards_invalidHost() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}
	
	func test_fetchGreencards_networkConnectionLost() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}
	
	func test_fetchGreencards_unknownError() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}
	
	func test_fetchGreencards_authenticationCancelled() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}
	
	func test_fetchGreencards_serverErrorMessage() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "error", "code": 99702] as [String: Any], statusCode: 500, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchGreencards(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError)
				done()
			}
		}
	}
}
