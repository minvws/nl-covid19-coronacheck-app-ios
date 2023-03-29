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

class NetworkManagerPrepareIssueTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v9/holder/prepare_issue"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, dataTLSCertificates: { [] })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_prepareIssue_validResponse() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid PrepareIssueEnvelope
			return HTTPStubsResponse(
				jsonObject: [
					"stoken": "test stoken",
					"prepareIssueMessage": "test message"
				],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.stoken) == "test stoken"
				expect(result.successValue?.prepareIssueMessage) == "test message"
				
				done()
			}
		}
	}
	
	func test_prepareIssue_invalidResponse() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: ["this": "isWrong"], statusCode: 200, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}
	
	func test_prepareIssue_noInternet() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}
	
	func test_prepareIssue_serverBusy() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_prepareIssue_timeOut() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}
	
	func test_prepareIssue_invalidHost() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}
	
	func test_prepareIssue_networkConnectionLost() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}
	
	func test_prepareIssue_unknownError() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}
	
	func test_prepareIssue_authenticationCancelled() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}
	
	func test_prepareIssue_serverErrorMessage() {
		
		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "error", "code": 99702] as [String: Any], statusCode: 500, headers: nil)
		}
		
		// When
		waitUntil { done in
			self.sut.prepareIssue { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError)
				done()
			}
		}
	}
}
