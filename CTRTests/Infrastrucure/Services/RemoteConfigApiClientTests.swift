/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import OHHTTPStubs
@testable import CTR

class RemoteConfigApiClientTests: XCTestCase {
	
//	// MARK: - Setup
//	
//	override func tearDown() {
//		
//		super.tearDown()
//		HTTPStubs.removeAllStubs()
//	}
//	
//	let configEndpoint = RemoteConfigurationRouter.configEndpoint
//	
//	// MARK: - Tests
//	
//	/// Test the get agent call with success
//	func testGetRemoteConfigurationSuccess() {
//
//		// Given
//		let expectation = self.expectation(description: "get remote configuration success")
//		stub(condition: isPath(configEndpoint)) { _ in
//
//			let object: [String: Any] = [
//				"iosMinimumVersion": "1.0.0",
//				"iosMinimumVersionMessage": "update message",
//				"iosAppStoreURL": "https://apple.com"
//			]
//
//			return HTTPStubsResponse(
//				jsonObject: object,
//				statusCode: 200,
//				headers: nil
//			)
//		}
//
//		// When
//		RemoteConfigurationApiClient().getRemoteConfiguration { configuration in
//
//			// Then
//			XCTAssertNotNil(configuration, "Configuration should not be nil")
//			XCTAssertNotNil(configuration?.minimumVersion, "There should be a minimum version")
//			XCTAssertEqual(configuration?.minimumVersion, "1.0.0", "The version should be the same")
//			XCTAssertNotNil(configuration?.minimumVersionMessage, "There should be a message")
//			XCTAssertEqual(configuration?.minimumVersionMessage, "update message", "The messages should be the same")
//			XCTAssertNotNil(configuration?.appStoreURL, "There should be a url")
//			XCTAssertEqual(configuration?.appStoreURL, URL(string: "https://apple.com"), "The url should be the same")
//
//			expectation.fulfill()
//		}
//		waitForExpectations(timeout: 10, handler: nil)
//	}
//	
//	/// test the get remote configurationwithout internet
//	func testGetRemoteConfigurationNoInternet() {
//		
//		// Given
//		let expectation = self.expectation(description: "get remote configuration no internet")
//		stub(condition: isPath(configEndpoint)) { _ in
//			
//			let notConnectedError = NSError(
//				domain: NSURLErrorDomain,
//				code: URLError.notConnectedToInternet.rawValue
//			)
//			return HTTPStubsResponse(error: notConnectedError)
//		}
//		
//		// When
//		RemoteConfigurationApiClient().getRemoteConfiguration { configuration in
//			
//			// Then
//			XCTAssertNil(configuration, "Configutation should be nil")
//			expectation.fulfill()
//		}
//		waitForExpectations(timeout: 10, handler: nil)
//	}
}
