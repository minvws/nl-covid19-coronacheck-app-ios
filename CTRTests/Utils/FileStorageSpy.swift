/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

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
}
