/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
import Nimble
@testable import Managers
import TestingShared

class JailBreakTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> JailBreakDetector {
			
		let sut = JailBreakDetector()
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return sut
	}

	func test_isJailBroken() {

		// Given
		// Can't simulate a jailbroken device.
		let sut = makeSUT()

		// When
		let result = sut.isJailBroken()

		// Then
		expect(result) == false
	}
}
