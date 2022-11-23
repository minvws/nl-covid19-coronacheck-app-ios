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

class NetworkManagerEventAccessTokenTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v9/holder/access_tokens"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, dataTLSCertificates: { [] })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_fetchEventAccessTokens_validResponse() {
		
		// Given
		let token = "test_fetchEventAccessTokens_validResponse"
		
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"tokens": [
						["provider_identifier": "ZZZ", "unomi": "test unomi ZZZ", "event": "test event ZZZ"],
						["provider_identifier": "GGD", "unomi": "test unomi GGD", "event": "test event GGD"]
					]
				],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isSuccess) == true
				expect(result.successValue).to(haveCount(2))
				expect(result.successValue?[0].providerIdentifier) == "ZZZ"
				expect(result.successValue?[1].providerIdentifier) == "GGD"
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_invalidResponse() {
		
		// Given
		let token = "test_fetchEventAccessTokens_invalidResponse"
		
		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: ["this": "isWrong"], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_noInternet() {
		
		// Given
		let token = "test_fetchEventAccessTokens_noInternet"
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_serverBusy() {
		
		// Given
		let token = "test_fetchEventAccessTokens_serverBusy"
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_timeOut() {
		
		// Given
		let token = "test_fetchEventAccessTokens_timeOut"
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_invalidHost() {
		
		// Given
		let token = "test_fetchEventAccessTokens_invalidHost"
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_networkConnectionLost() {
		
		// Given
		let token = "test_fetchEventAccessTokens_networkConnectionLost"
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_unknownError() {
		
		// Given
		let token = "test_fetchEventAccessTokens_unknownError"
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_authenticationCancelled() {
		
		// Given
		let token = "test_fetchEventAccessTokens_authenticationCancelled"
		
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}
	
	func test_fetchEventAccessTokens_serverErrorMessage() {
		
		// Given
		let token = "test_fetchEventAccessTokens_serverErrorMessage"
		
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "error", "code": 99702], statusCode: 500, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.fetchEventAccessTokens(maxToken: token) { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError)
				done()
			}
		}
	}
}
