/*
 * Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
@testable import DataMigration

class DataImportSpy: DataImportProtocol {

	var invokedDelegateSetter = false
	var invokedDelegateSetterCount = 0
	var invokedDelegate: DataImportDelegate?
	var invokedDelegateList = [DataImportDelegate?]()
	var invokedDelegateGetter = false
	var invokedDelegateGetterCount = 0
	var stubbedDelegate: DataImportDelegate!

	var delegate: DataImportDelegate? {
		set {
			invokedDelegateSetter = true
			invokedDelegateSetterCount += 1
			invokedDelegate = newValue
			invokedDelegateList.append(newValue)
		}
		get {
			invokedDelegateGetter = true
			invokedDelegateGetterCount += 1
			return stubbedDelegate
		}
	}

	var invokedImportString = false
	var invokedImportStringCount = 0
	var invokedImportStringParameters: (string: String, Void)?
	var invokedImportStringParametersList = [(string: String, Void)]()
	var stubbedImportStringError: Error?

	func importString(_ string: String) throws {
		invokedImportString = true
		invokedImportStringCount += 1
		invokedImportStringParameters = (string, ())
		invokedImportStringParametersList.append((string, ()))
		if let error = stubbedImportStringError {
			throw error
		}
	}
}
