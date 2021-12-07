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

	func test_addingServerDate_withoutAge() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: nil)

		// Then
		expect(sut.firstUseDate) == now
	}

	func test_addingServerDate_withZeroAge() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")

		expect(sut.firstUseDate) == now
	}

	func test_addingServerDate_withAge() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(sut.firstUseDate) == now.addingTimeInterval(120 * seconds)
	}

	func test_addingDocumentsDirectoryDate() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.update(documentsDirectoryCreationDate: now)

		// Then
		expect(sut.firstUseDate) == now
	}

	func test_reset() {

		// Given
		let sut = AppInstalledSinceManager()

		// When
		sut.reset()

		// Then
		expect(sut.firstUseDate).to(beNil())
	}
}
