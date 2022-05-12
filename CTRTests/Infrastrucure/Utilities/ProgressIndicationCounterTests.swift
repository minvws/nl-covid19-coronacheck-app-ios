/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR
import Nimble

class ProgressIndicationCounterTests: XCTestCase {

	func test_doesNotCallCallbackOnInit() {
		// Arrange
		var isActive: Bool?

		// Act
		let sut = ProgressIndicationCounter { isActive = $0 }

		// Assert
		expect(isActive).to(beNil())
		expect(sut.isActive) == false
	}

	func test_incrementingCallsCallback() {
		// Arrange
		var isActive: Bool?
		let sut = ProgressIndicationCounter { isActive = $0 }

		// Act
		sut.increment()

		// Assert
		expect(isActive) == true
		expect(sut.isActive) == true
	}

	func test_decrementingDoesNotCallCallbackIfAlreadyInactive() {
		// Arrange
		var isActive: Bool?
		let sut = ProgressIndicationCounter { isActive = $0 }

		// Act
		sut.decrement()

		// Assert
		expect(isActive).to(beNil())
		expect(sut.isActive) == false
	}

	func test_incrementingTwiceCallsCallbackOnce() {
		// Arrange
		var isActive: Bool?
		let sut = ProgressIndicationCounter { val in
			if isActive == nil {
				isActive = val
			} else {
				XCTFail("Shouldn't be called a second time")
			}
		}

		// Act
		sut.increment()
		sut.increment()

		// Assert
		expect(isActive) == true
		expect(sut.isActive) == true
	}

	func test_incrementingThenDecrementingTwiceCallsCallbackTwice() {
		// Arrange
		var isActiveA: Bool?
		var isActiveB: Bool?
		let sut = ProgressIndicationCounter { val in
			if isActiveA == nil {
				isActiveA = val
			} else if isActiveB == nil {
				isActiveB = val
			} else {
				XCTFail("Shouldn't be called a third time")
			}
		}

		// Act
		sut.increment()
		sut.decrement()
		sut.decrement()

		// Assert
		expect(isActiveA) == true
		expect(isActiveB) == false
		expect(sut.isActive) == false
	}
}
