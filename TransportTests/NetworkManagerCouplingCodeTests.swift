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

class NetworkManagerCouplingCodeTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v8/holder/coupling"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, remoteConfig: { .default })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_checkCouplingStatus_invalidInput() throws {
		
		// Given
		// This will not serialize into a valid JSONObject
		let bogusStr = try XCTUnwrap(String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian))
		let testDictionary: [String: AnyObject] = ["test": bogusStr as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "accepted"], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotSerialize)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_validResponse() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: ["status": "accepted"], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.status) == DccCoupling.CouplingState.accepted
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_invalidResponse() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: ["this": "isWrong"], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_noInternet() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_serverBusy() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_timeOut() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_invalidHost() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_networkConnectionLost() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_unknownError() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_authenticationCancelled() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}
	
	func test_checkCouplingStatus_serverErrorMessage() {
		
		// Given
		let testDictionary: [String: AnyObject] = ["test": "test" as AnyObject]
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "error", "code": 99702], statusCode: 500, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.checkCouplingStatus(dictionary: testDictionary) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError)
				done()
			}
		}
	}
}
