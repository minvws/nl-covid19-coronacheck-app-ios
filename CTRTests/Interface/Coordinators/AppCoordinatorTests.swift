/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class AppCoordinatorTests: XCTestCase {

	var sut: AppCoordinator!

	var navigationSpy: NavigationControllerSpy!
	
	var fileManagerSpy: FileStorageSpy!

	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		navigationSpy = NavigationControllerSpy()
		fileManagerSpy = FileStorageSpy()
		sut = AppCoordinator(
			navigationController: navigationSpy
		)
		sut.fileManager = fileManagerSpy
	}

	// MARK: - Tests
	
	func test_start_asHolder() {

		// Given
		sut.flavor = .holder
		
		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(self.sut.window.rootViewController is AppStatusViewController) == true
		expect((self.sut.window.rootViewController as? AppStatusViewController)?.viewModel is AppDeactivatedViewModel) == true
		
		expect(self.fileManagerSpy.invokedRemoveDatabase) == true
		expect(self.fileManagerSpy.invokedFileExists) == true
		expect(self.fileManagerSpy.invokedFileExistsCount) == 2
	}
	
	func test_start_asVerifier() {

		// Given
		sut.flavor = .verifier
		
		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(self.sut.window.rootViewController is AppStatusViewController) == true
		expect((self.sut.window.rootViewController as? AppStatusViewController)?.viewModel is AppDeactivatedViewModel) == true

		expect(self.fileManagerSpy.invokedRemoveDatabase) == true
		expect(self.fileManagerSpy.invokedFileExists) == true
		expect(self.fileManagerSpy.invokedFileExistsCount) == 2
	}
}

class FileStorageSpy: FileStorageProtocol {

	var invokedDocumentsURLGetter = false
	var invokedDocumentsURLGetterCount = 0
	var stubbedDocumentsURL: URL!

	var documentsURL: URL? {
		invokedDocumentsURLGetter = true
		invokedDocumentsURLGetterCount += 1
		return stubbedDocumentsURL
	}

	var invokedStore = false
	var invokedStoreCount = 0
	var invokedStoreParameters: (data: Data, fileName: String)?
	var invokedStoreParametersList = [(data: Data, fileName: String)]()
	var stubbedStoreError: Error?

	func store(_ data: Data, as fileName: String) throws {
		invokedStore = true
		invokedStoreCount += 1
		invokedStoreParameters = (data, fileName)
		invokedStoreParametersList.append((data, fileName))
		if let error = stubbedStoreError {
			throw error
		}
	}

	var invokedRead = false
	var invokedReadCount = 0
	var invokedReadParameters: (fileName: String, Void)?
	var invokedReadParametersList = [(fileName: String, Void)]()
	var stubbedReadResult: Data!

	func read(fileName: String) -> Data? {
		invokedRead = true
		invokedReadCount += 1
		invokedReadParameters = (fileName, ())
		invokedReadParametersList.append((fileName, ()))
		return stubbedReadResult
	}

	var invokedFileExists = false
	var invokedFileExistsCount = 0
	var invokedFileExistsParameters: (fileName: String, Void)?
	var invokedFileExistsParametersList = [(fileName: String, Void)]()
	var stubbedFileExistsResult: Bool! = false

	func fileExists(_ fileName: String) -> Bool {
		invokedFileExists = true
		invokedFileExistsCount += 1
		invokedFileExistsParameters = (fileName, ())
		invokedFileExistsParametersList.append((fileName, ()))
		return stubbedFileExistsResult
	}

	var invokedRemove = false
	var invokedRemoveCount = 0
	var invokedRemoveParameters: (fileName: String, Void)?
	var invokedRemoveParametersList = [(fileName: String, Void)]()

	func remove(_ fileName: String) {
		invokedRemove = true
		invokedRemoveCount += 1
		invokedRemoveParameters = (fileName, ())
		invokedRemoveParametersList.append((fileName, ()))
	}

	var invokedRemoveDatabase = false
	var invokedRemoveDatabaseCount = 0

	func removeDatabase() {
		invokedRemoveDatabase = true
		invokedRemoveDatabaseCount += 1
	}
}
