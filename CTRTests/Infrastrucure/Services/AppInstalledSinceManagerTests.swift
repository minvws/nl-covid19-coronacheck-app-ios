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

	var sut: AppInstalledSinceManager!

	override func setUp() {

		super.setUp()
		sut = AppInstalledSinceManager()
		sut.reset()
	}

	func test_addingServerDate_withoutAge() {

		// Given

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: nil)

		// Then
		expect(self.sut.firstUseDate) == now
	}

	func test_addingServerDate_withZeroAge() {

		// Given

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")

		// Then
		expect(self.sut.firstUseDate) == now
	}

	func test_addingServerDate_withAge() {

		// Given

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(self.sut.firstUseDate) == now.addingTimeInterval(120 * seconds)
	}

	func test_addingDocumentsDirectoryDate() {

		// Given

		// When
		sut.update(documentsDirectoryCreationDate: now)

		// Then
		expect(self.sut.firstUseDate) == now
	}

	func test_reset() {

		// Given

		// When
		sut.reset()

		// Then
		expect(self.sut.firstUseDate).to(beNil())
	}

	func test_canOnlyBeSetOnce() {

		// Given
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(self.sut.firstUseDate) == now
	}
}
