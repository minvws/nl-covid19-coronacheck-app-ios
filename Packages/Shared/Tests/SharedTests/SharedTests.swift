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
	
	func test_fullStringVersion_noDigits() {
		
		// Given
		let value = "🦠"
		
		// When
		let result = value.fullVersionString()
		
		// Then
		XCTAssertEqual(result, "🦠.0.0")
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
	
	// MARK: - String + Data
	
	func test_string_sha256() {
		
		// Given
		let string = "test_string_sha256"
		
		// When
		let sha256 = string.sha256
		
		// Then
		XCTAssertEqual(sha256, "b39dc4c3d9eedc35b66703dd90bb1cdb9b73eb563ba25ab55e6f0714f8a4f849")
	}
	
	func test_string_base64Decoded() {
	
		// Given
		let string = "dGVzdF9zdHJpbmdfYmFzZTY0RGVjb2RlZA=="
		
		// When
		let decoded = string.base64Decoded()
		
		// Then
		XCTAssertEqual(decoded, "test_string_base64Decoded")
	}
	
	func test_data_sha256() {
		
		// Given
		let string = "test_data_sha256"
		let data = Data(string.utf8)
		
		// When
		let sha256 = data.sha256
		let sha256String = sha256.compactMap { String(format: "%02x", $0) }.joined()
		
		// Then
		XCTAssertEqual(sha256String, "a2aee26c63bb88e0c3cab3fc0d20f01f634c814b7757f2dccb1090a796aba1a7")
	}
	
	func test_string_bytes() {
		
		// Given
		let string = "test_string_bytes"
		
		// When
		let bytes = string.bytes
		
		// Then
		XCTAssertEqual(bytes, [116, 101, 115, 116, 95, 115, 116, 114, 105, 110, 103, 95, 98, 121, 116, 101, 115])
	}
	
	func test_string_bytes_empty() {
		
		// Given
		let string = ""
		
		// When
		let bytes = string.bytes
		
		// Then
		XCTAssertEqual(bytes, [])
	}
}
