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

class NetworkManagerPrepareIssueTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v7/holder/prepare_issue"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development)
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_prepareIssue_validResponse() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_validResponse")

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
		sut.prepareIssue { result in

			// Then
			expect(result.isSuccess) == true
			expect(result.successValue?.stoken) == "test stoken"
			expect(result.successValue?.prepareIssueMessage) == "test message"

			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_invalidResponse() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_invalidResponse")

		stub(condition: isPath(path)) { _ in
			// Return status accepted
			return HTTPStubsResponse(jsonObject: ["this": "isWrong"], statusCode: 200, headers: nil)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_noInternet() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_noInternet")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_serverBusy() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_serverBusy")

		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_timeOut() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_timeOut")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_invalidHost() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_invalidHost")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_networkConnectionLost() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_networkConnectionLost")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_unknownError() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_unknownError")

		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func test_prepareIssue_serverErrorMessage() {

		// Given
		let expectation = self.expectation(description: "test_prepareIssue_serverErrorMessage")

		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(jsonObject: ["status": "error", "code": 99702], statusCode: 500, headers: nil)
		}

		// When
		sut.prepareIssue { result in

			// Then
			expect(result.isFailure) == true
			expect(result.failureError) == ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99702), error: .serverError)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}
}
