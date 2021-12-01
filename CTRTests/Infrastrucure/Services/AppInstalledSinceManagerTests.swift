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
		
		let sut = AppInstalledSinceManager()
		
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: nil)
		
		expect(sut.usable) == now
	}
	
	func testAddingServerDateWithZeroAge() {
		
		let sut = AppInstalledSinceManager()
		
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")
		
		expect(sut.usable) == now
	}
	
	func testAddingServerDateWithAge() {
		
		let sut = AppInstalledSinceManager()
		
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:04:39 GMT", ageHeader: "120")
		
		expect(sut.usable) == now.addingTimeInterval(120 * seconds)
	}
	
	func testWithoutServer() {
		let documentDirectoryCreationDate = now.addingTimeInterval(30 * days * ago)
		let sut = AppInstalledSinceManager(documentDirectoryCreationDate: documentDirectoryCreationDate)
		
		expect(sut.usable) == documentDirectoryCreationDate
	}
	
	func testWithServerAndDirectoryCreationDate() {
		let documentDirectoryCreationDate = now.addingTimeInterval(30 * days * ago)
		let sut = AppInstalledSinceManager(documentDirectoryCreationDate: documentDirectoryCreationDate)
		
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:04:39 GMT", ageHeader: "120")
		
		expect(sut.usable) == now.addingTimeInterval(120 * seconds)
	}
}
