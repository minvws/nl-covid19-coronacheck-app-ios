import XCTest
@testable import Shared

final class SharedTests: XCTestCase {

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
}
