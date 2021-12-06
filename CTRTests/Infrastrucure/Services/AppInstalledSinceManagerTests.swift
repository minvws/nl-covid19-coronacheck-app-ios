/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import XCTest
import Nimble
@testable import CTR

class AppInstalledSinceManagerTests: XCTestCase {

	func testAddingServerDateWithoutAge() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: nil)

		// Then
		expect(sut.usable) == now
	}
	
	func testAddingServerDateWithZeroAge() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")
		
		expect(sut.usable) == now
	}
	
	func testAddingServerDateWithAge() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:04:39 GMT", ageHeader: "120")

		// Then
		expect(sut.usable) == now.addingTimeInterval(120 * seconds)
	}
	
	func testWithoutServer() {

		// Given
		let documentDirectoryCreationDate = now.addingTimeInterval(30 * days * ago)

		// When
		let sut = AppInstalledSinceManager(documentDirectoryCreationDate: documentDirectoryCreationDate)

		// Then
		expect(sut.usable) == documentDirectoryCreationDate
	}
	
	func testWithServerAndDirectoryCreationDate() {

		// Given
		let documentDirectoryCreationDate = now.addingTimeInterval(30 * days * ago)
		let sut = AppInstalledSinceManager(documentDirectoryCreationDate: documentDirectoryCreationDate)

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:04:39 GMT", ageHeader: "120")

		// Then
		expect(sut.usable) == now.addingTimeInterval(120 * seconds)
	}
}
