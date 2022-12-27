/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import Shared

final class SharedTests: XCTestCase {
	
	// MARK: - fullStringVersion (String + Version)
	
	func test_fullStringVersion_singleDigit() {
		
		// Given
		let value = "1"
		
		// When
		let result = value.fullVersionString()
		
		// Then
		XCTAssertEqual(result, "1.0.0")
	}
	
	func test_fullStringVersion_twoDigits() {
		
		// Given
		let value = "2.1"
		
		// When
		let result = value.fullVersionString()
		
		// Then
		XCTAssertEqual(result, "2.1.0")
	}
	
	// MARK: - Collection
	
	func test_array_isNotEmpty_notEmpty() {
		
		// Given
		let values = ["🦠"]
		
		// When
		let isNotEmpty = values.isNotEmpty
		let isEmpty = values.isEmpty
		
		// Then
		XCTAssertTrue(isNotEmpty)
		XCTAssertFalse(isEmpty)
	}
	
	func test_array_isNotEmpty_isEmpty() {
		
		// Given
		let values: [String] = []
		
		// When
		let isNotEmpty = values.isNotEmpty
		let isEmpty = values.isEmpty
		
		// Then
		XCTAssertFalse(isNotEmpty)
		XCTAssertTrue(isEmpty)
	}
	
	func test_string_isNotEmpty_notEmpty() {
		
		// Given
		let value = ["🦠"]
		
		// When
		let isNotEmpty = value.isNotEmpty
		let isEmpty = value.isEmpty
		
		// Then
		XCTAssertTrue(isNotEmpty)
		XCTAssertFalse(isEmpty)
	}
	
	func test_string_isNotEmpty_isEmpty() {
		
		// Given
		let value = ""
		
		// When
		let isNotEmpty = value.isNotEmpty
		let isEmpty = value.isEmpty
		
		// Then
		XCTAssertFalse(isNotEmpty)
		XCTAssertTrue(isEmpty)
	}
	
	// MARK: - Result
	
	func test_result_isSuccess() {
		
		// Given
		let result: Result<String, Error> = .success("Test")
		
		// When
		let isSuccess = result.isSuccess
		let isFailure = result.isFailure
		let successValue = result.successValue
		let failureErrror = result.failureError
		
		// Then
		XCTAssertTrue(isSuccess)
		XCTAssertFalse(isFailure)
		XCTAssertEqual(successValue, "Test")
		XCTAssertNil(failureErrror)
	}
	
	func test_result_isFailure() {
		
		// Given
		let error = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
		let result: Result<String, Error> = .failure(error)
		
		// When
		let isSuccess = result.isSuccess
		let isFailure = result.isFailure
		let successValue = result.successValue
		let failureErrror = result.failureError
		
		// Then
		XCTAssertFalse(isSuccess)
		XCTAssertTrue(isFailure)
		XCTAssertNil(successValue)
		XCTAssertNotNil(failureErrror)
	}
}
