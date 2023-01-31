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
import TestingShared
import Persistence

class AppInstalledSinceManagerTests: XCTestCase {

	var sut: AppInstalledSinceManager!
	var secureUserSettingsSpy: SecureUserSettingsSpy!
	
	override func setUp() {

		super.setUp()
		secureUserSettingsSpy = SecureUserSettingsSpy()
		sut = AppInstalledSinceManager(secureUserSettings: secureUserSettingsSpy)
	}

	func test_addingServerDate_withoutAge() {

		// Given

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: nil)

		// Then
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	func test_addingServerDate_withZeroAge() {

		// Given

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")

		// Then
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	func test_addingServerDate_withAge() {

		// Given

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == now.addingTimeInterval(120 * seconds)
	}

	func test_addingDocumentsDirectoryDate() {

		// Given
		let provider = DateProvider()
		provider.stubbedGetDocumentsDirectoryCreationDateResult = now

		// When
		sut.update(dateProvider: provider)

		// Then
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	func test_reset() {

		// Given

		// When
		sut.wipePersistedData()

		// Then
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == nil
	}

	func test_canOnlyBeSetOnce_serverUpdates() {

		// Given
		secureUserSettingsSpy.stubbedAppInstalledDate = now

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(self.sut.firstUseDate) == now
	}

	func test_canOnlyBeSetOnce_providerAndServer() {

		// Given
		let provider = DateProvider()
		provider.stubbedGetDocumentsDirectoryCreationDateResult = now
		sut.update(dateProvider: provider)
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == now
		
		secureUserSettingsSpy.stubbedAppInstalledDate = now

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(self.secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	class DateProvider: DocumentsDirectoryCreationDateProtocol {

		var invokedGetDocumentsDirectoryCreationDate = false
		var invokedGetDocumentsDirectoryCreationDateCount = 0
		var stubbedGetDocumentsDirectoryCreationDateResult: Date!

		func getDocumentsDirectoryCreationDate() -> Date? {
			invokedGetDocumentsDirectoryCreationDate = true
			invokedGetDocumentsDirectoryCreationDateCount += 1
			return stubbedGetDocumentsDirectoryCreationDateResult
		}
	}
}
