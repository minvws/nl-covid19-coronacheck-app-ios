/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import OHHTTPStubs
@testable import CTR

class APIClientTests: XCTestCase {
	
	// MARK: - Setup
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	let agentEndpoint = ApiRouter.agentEndpoint
	let eventEndpoint = ApiRouter.eventEndpoint
	let publicKeyEndpoint = ApiRouter.publicKeysEndpoint
	let testResultEndpoint = ApiRouter.testResultsEndpoint
	let authorizationEndpoint = ApiRouter.authorizationTokenEndpoint
	
	// MARK: - Tests
	
	/// Test the get agent call with success
	func testGetAgentSuccess() {
		
		// Given
		let expectation = self.expectation(description: "get agent success")
		let identifier = "testGetAgentSuccess"
		stub(condition: isPath(agentEndpoint + "/\(identifier)")) { _ in
			
			let object: [String: Any] = [
				"agent": [
					"event": [
						"name": "Test Event",
						"private_key": "Test Private Key",
						"valid_from": 1611008598,
						"valid_to": 1611584139,
						"type": [
							"uuid": "Test type uuid",
							"name": "Test type name"
						],
						"valid_tests": [
							[
								"name": "PCR",
								"uuid": "PCR UUID",
								"max_validity": 604800
							]
						]
					]
				],
				"agent_signature": "test signature"
			]
			
			return HTTPStubsResponse(
				jsonObject: object,
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		ApiClient().getAgentEnvelope(identifier: identifier) { response in
			
			// Then
			XCTAssertNotNil(response, "Agent Envelope should not be nil")
			XCTAssertNotNil(response?.agent, "There should be an agent")
			XCTAssertNotNil(response?.agent.event, "There should be an event")
			XCTAssertEqual(response?.agent.event.validTestsTypes.count, 1, "There should be one valid test")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// test the get agent call without internet
	func testGetAgentNoInternet() {
		
		// Given
		let expectation = self.expectation(description: "get agent no internet")
		let identifier = "testGetAgentNoInternet"
		stub(condition: isPath(agentEndpoint + "/\(identifier)")) { _ in
			
			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		ApiClient().getAgentEnvelope(identifier: identifier) { response in
			
			// Then
			XCTAssertNil(response, "Result should be nil")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// test the get event call with success
	func testGetEventSuccess() {
		
		// Given
		let expectation = self.expectation(description: "get event success")
		let identifier = "testGetEventSuccess"
		stub(condition: isPath(eventEndpoint + "/\(identifier)")) { _ in
			
			let object: [String: Any] = [
				"event": [
					"name": "Test Event",
					"uuid": "Test Event uuid",
					"public_key": "Test Public Key",
					"valid_from": 1611008598,
					"valid_to": 1611584139,
					"type": [
						"uuid": "Test type uuid",
						"name": "Test type name"
					],
					"valid_tests": [
						[
							"name": "PCR",
							"uuid": "PCR UUID",
							"max_validity": 604800
						], [
							"name": "Breathalyzer",
							"uuid": "Breathalyzer UUID",
							"max_validity": 10800
						]
					]
				],
				"event_signature": "test signature"
			]
			
			return HTTPStubsResponse(
				jsonObject: object,
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		ApiClient().getEvent(identifier: identifier) { response in
			
			// Then
			XCTAssertNotNil(response, "Event Envelope should not be nil")
			XCTAssertNotNil(response?.event, "There should be an event")
			XCTAssertEqual(response?.event.validTestsTypes.count, 2, "There should be two valid test types")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// test the get event call without internet
	func testGetEventNoInternet() {
		
		// Given
		let expectation = self.expectation(description: "get event no internet")
		let identifier = "testGetEventNoInternet"
		stub(condition: isPath(eventEndpoint + "/\(identifier)")) { _ in
			
			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		ApiClient().getEvent(identifier: identifier) { response in
			
			// Then
			XCTAssertNil(response, "Result should be nil")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// test the get public keys call with success
	func testGetPublicKeysSuccess() {
		
		// Given
		let expectation = self.expectation(description: "get public keys success")
		stub(condition: isPath(publicKeyEndpoint)) { _ in
			return HTTPStubsResponse(
				jsonObject: ["issuers": [["uuid": "TestUUID", "name": "TestName", "public_key": "TestPublicKey"]]],
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		ApiClient().getPublicKeys { response in
			
			// Then
			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertEqual(response.count, 1, "There should be one issuer")
			XCTAssertEqual(response.first?.identifier, "TestUUID", "The identifier should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// test the get public keys call without internet
	func testGetPublicKeysNoInternet() {
		
		// Given
		let expectation = self.expectation(description: "get public keys no internet")
		stub(condition: isPath(publicKeyEndpoint)) { _ in
			
			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		ApiClient().getPublicKeys { response in
			
			// Then
			XCTAssertNotNil(response, "Result should be nil")
			XCTAssertTrue(response.isEmpty, "There should be no issuers")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// Test the get test results call with success
	func testGetTestResultsSuccess() {
		
		// Given
		let expectation = self.expectation(description: "get test results success")
		let identifier = "testGetTestResultsSuccess"
		stub(condition: isPath(testResultEndpoint)) { _ in
			
			let object: [String: Any] = [
				"test_signatures":
					[
						["uuid": "TestUUID", "signature": "TestSignature"]
					],
				"test_results":
					[
						["uuid": "result uuid", "test_type": "type 1", "date_taken": 1611008913, "result": 0]
					],
				"test_types":
					[
						["uuid": "type 1", "name": "PCR"]
					]
			]
			
			return HTTPStubsResponse(
				jsonObject: object,
				statusCode: 200,
				headers: nil
			)
		}
		
		// When
		ApiClient().getTestResults(identifier: identifier) { response in
			
			// Then
			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertEqual(response?.testResults.count, 1, "There should be one result")
			XCTAssertEqual(response?.signatures.count, 1, "There should be one signature")
			XCTAssertEqual(response?.types?.count, 1, "There should be one type")
			
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// Test the get test results call without internet
	func testGetTestResultsNoInternet() {
		
		// Given
		let expectation = self.expectation(description: "get test results no internet")
		let identifier = "testGetTestResultsNoInternet"
		stub(condition: isPath(testResultEndpoint + "/?userUUID=\(identifier)")) { _ in
			
			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}
		
		// When
		ApiClient().getTestResults(identifier: identifier) { response in
			
			// Then
			XCTAssertNil(response, "Result should be nil")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the post authorization token with success
	func testPostAuthenticationTokenSuccess() {

		// Given
		let expectation = self.expectation(description: "post authorization token success")
		let token = "testPostAuthenticationTokenSuccess"
		stub(condition: isPath(authorizationEndpoint)) { _ in

			return HTTPStubsResponse(
				jsonObject: [],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		ApiClient().postAuthorizationToken(token) { response in

			// Then
			XCTAssertTrue(response, "Result should be be false")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the post authorization token without internet
	func testPostAuthorizationTokenNoInternet() {

		// Given
		let expectation = self.expectation(description: "post authorization token no internet")
		let token = "testPostAuthorizationTokenNoInternet"

		stub(condition: isPath(authorizationEndpoint)) { _ in

			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		ApiClient().postAuthorizationToken(token) { response in

			// Then
			XCTAssertFalse(response, "Result should be be false")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
}
