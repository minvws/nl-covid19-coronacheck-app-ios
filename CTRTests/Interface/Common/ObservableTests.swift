/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

class ObservableTests: XCTestCase {
	
	func test_providesValueToObserver() {
		// Arrange
		let observable = Observable(value: true)
 
		// Act
		var result = false
		observable.observe { val in
			result = val
		}

		// Assert
		expect(result) == true
	}
	
	func test_providesUpdateToObserver() {
		// Arrange
		let observable = Observable(value: 1)

		var result = 0
		observable.observe { val in
			result = val
		}
 
		// Act & Assert
		observable.value = 1
		expect(result) == 1
		
		observable.value = 2
		expect(result) == 2
	}
	
	func test_providesUpdateToMultipleObservers() {
		// Arrange
		let observable = Observable(value: 1)

		var resultA = 0
		observable.observe { val in
			resultA = val
		}
		var resultB = 0
		observable.observe { val in
			resultB = val
		}
 
		// Act & Assert
		observable.value = 1
		expect(resultA) == 1
		expect(resultB) == 1
		
		observable.value = 2
		expect(resultA) == 2
		expect(resultB) == 2
	}
	
	func test_disposable_providesUpdateToMultipleObservers_deallocatingStopsUpdates() {
		// Arrange
		let observable = Observable(value: 1)
		
		var resultA = 0
		var disposableA: Optional = observable.observeReturningDisposable { val in
			resultA = val
		}

		var resultB = 0
		var disposableB: Optional = observable.observeReturningDisposable { val in
			resultB = val
		}
 
		// Act & Assert
		observable.value = 1
 
		expect(resultA) == 1
		expect(resultB) == 1

		disposableA = nil // dispose of first Observation
		
		observable.value = 2
		expect(resultA) == 1 // not updated
		expect(resultB) == 2
	}
}
