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

	let nonceEndpoint = ApiRouter.nonceEndpoint
	let publicKeyEndpoint = ApiRouter.publicKeysEndpoint
	let ismEndpoint = ApiRouter.ismEndpoint
	
	// MARK: - Tests
	
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
		stub(condition: pathStartsWith(ismEndpoint)) { _ in

			let object: [String: Any] = [
				"test_proofs": [[
					"test_proof": [
						"ism": "test ism",
						"attributes": [
							"test 1",
							"test 2"
						]
					],
					"signature": "test signature",
					"test_type": [
						"uuid": "type 1",
						"name": "PCR"
					]
				]]
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
			XCTAssertEqual(response?.testProofs?.count, 1, "There should be one proof")
			XCTAssertEqual(response?.testProofs?.first?.issuerSignedMessage?.base64Ism, "test ism", "The ism should match")
			XCTAssertEqual(response?.testProofs?.first?.signature, "test signature", "Signature should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/// Test the get test results call without internet
	func testGetTestResultsNoInternet() {
		
		// Given
		let expectation = self.expectation(description: "get test results no internet")
		let identifier = "testGetTestResultsNoInternet"
		stub(condition: pathStartsWith(ismEndpoint)) { _ in

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

	/// Test the get noncewith success
	func testgetNonceSuccess() {

		// Given
		let expectation = self.expectation(description: "get nonce success")
		stub(condition: isPath(nonceEndpoint)) { _ in

			return HTTPStubsResponse(
				jsonObject: ["nonce": "test nonce", "stoken": "test stoken"],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		ApiClient().getNonce { response in

			// Then
			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertEqual(response?.nonce, "test nonce", "Nonce should match")
			XCTAssertEqual(response?.stoken, "test stoken", "Stoken should match")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the get noncewithout internet
	func testGetNonceNoInternet() {

		// Given
		let expectation = self.expectation(description: "get nonce no internet")

		stub(condition: isPath(nonceEndpoint)) { _ in

			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		ApiClient().getNonce { response in

			// Then
			XCTAssertNil(response, "Result should be nil")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the get test results call with success
	func testFetchTestResultsWithIsmSuccess() {

		// Given
		let expectation = self.expectation(description: "get test results success")
		stub(condition: pathStartsWith(ismEndpoint)) { _ in

			let object: [String: Any] = [
				"test_proofs": [[
					"test_proof": [
						"ism": "test ism",
						"attributes": [
							"test 1",
							"test 2"
						]
					],
					"signature": "test signature",
					"test_type": [
						"uuid": "type 1",
						"name": "PCR"
					]
				]]
			]

			return HTTPStubsResponse(
				jsonObject: object,
				statusCode: 200,
				headers: nil
			)
		}
		let dictionary: [String: AnyObject] = [
			"access_token": "testFetchTestResultsWithIsmSuccess" as AnyObject,
			"stoken": "stoken" as AnyObject,
			"icm": "test" as AnyObject
		]

		// When
		ApiClient().fetchTestResultsWithISM(dictionary: dictionary) { response in

			// Then
			XCTAssertNotNil(response, "Response should not be nil")
			XCTAssertEqual(response?.testProofs?.count, 1, "There should be one proof")
			XCTAssertEqual(response?.testProofs?.first?.issuerSignedMessage?.base64Ism, "test ism", "The ism should match")
			XCTAssertEqual(response?.testProofs?.first?.signature, "test signature", "Signature should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the  call without internet
	func testFetchTestResultWithISMNoInternet() {

		// Given
		let expectation = self.expectation(description: "fetch test results with icm no internet")
		stub(condition: pathStartsWith(ismEndpoint)) { _ in

			let notConnectedError = NSError(
				domain: NSURLErrorDomain,
				code: URLError.notConnectedToInternet.rawValue
			)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		ApiClient().fetchTestResultsWithISM(dictionary: [:]) { response in

			// Then
			XCTAssertNil(response, "Result should be nil")
			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
}
