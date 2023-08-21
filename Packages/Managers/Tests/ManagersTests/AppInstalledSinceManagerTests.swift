/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import XCTest
import Nimble
import TestingShared
@testable import Managers
@testable import Persistence

class AppInstalledSinceManagerTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (AppInstalledSinceManager, SecureUserSettingsSpy) {

		let secureUserSettingsSpy = SecureUserSettingsSpy()
		let sut = AppInstalledSinceManager(secureUserSettings: secureUserSettingsSpy)
		
		trackForMemoryLeak(instance: secureUserSettingsSpy, file: file, line: line)
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, secureUserSettingsSpy)
	}

	func test_addingServerDate_withoutAge() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: nil)

		// Then
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	func test_addingServerDate_withZeroAge() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()
		
		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "0")

		// Then
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	func test_addingServerDate_withAge() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == now.addingTimeInterval(120 * seconds)
	}

	func test_addingDocumentsDirectoryDate() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()
		let provider = DateProvider()
		provider.stubbedGetDocumentsDirectoryCreationDateResult = now

		// When
		sut.update(dateProvider: provider)

		// Then
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == now
	}

	func test_reset() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()
		
		// When
		sut.wipePersistedData()

		// Then
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == nil
	}

	func test_canOnlyBeSetOnce_serverUpdates() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()
		secureUserSettingsSpy.stubbedAppInstalledDate = now

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(sut.firstUseDate) == now
	}

	func test_canOnlyBeSetOnce_providerAndServer() {

		// Given
		let (sut, secureUserSettingsSpy) = makeSUT()
		let provider = DateProvider()
		provider.stubbedGetDocumentsDirectoryCreationDateResult = now
		sut.update(dateProvider: provider)
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == now
		
		secureUserSettingsSpy.stubbedAppInstalledDate = now

		// When
		sut.update(serverHeaderDate: "Thu, 15 Jul 2021 15:02:39 GMT", ageHeader: "120")

		// Then
		expect(secureUserSettingsSpy.invokedAppInstalledDate) == now
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
