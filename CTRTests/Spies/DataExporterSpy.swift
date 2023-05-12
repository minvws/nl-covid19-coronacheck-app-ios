/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import DataMigration

class DataExporterSpy: DataExporterProtocol {

	var invokedExport = false
	var invokedExportCount = 0
	var invokedExportParameters: (rawData: Data, Void)?
	var invokedExportParametersList = [(rawData: Data, Void)]()
	var stubbedExportError: Error?
	var stubbedExportResult: [String]! = []

	func export(_ rawData: Data) throws -> [String] {
		invokedExport = true
		invokedExportCount += 1
		invokedExportParameters = (rawData, ())
		invokedExportParametersList.append((rawData, ()))
		if let error = stubbedExportError {
			throw error
		}
		return stubbedExportResult
	}
}
