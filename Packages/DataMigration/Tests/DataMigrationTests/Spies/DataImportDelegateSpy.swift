/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import DataMigration
import Foundation

class DataImportDelegateSpy: DataImportDelegate {

	var invokedCompleted = false
	var invokedCompletedCount = 0
	var invokedCompletedParameters: (value: Data, Void)?
	var invokedCompletedParametersList = [(value: Data, Void)]()

	func completed(_ value: Data) {
		invokedCompleted = true
		invokedCompletedCount += 1
		invokedCompletedParameters = (value, ())
		invokedCompletedParametersList.append((value, ()))
	}

	var invokedProgress = false
	var invokedProgressCount = 0
	var invokedProgressParameters: (percentage: Float, Void)?
	var invokedProgressParametersList = [(percentage: Float, Void)]()

	func progress(_ percentage: Float) {
		invokedProgress = true
		invokedProgressCount += 1
		invokedProgressParameters = (percentage, ())
		invokedProgressParametersList.append((percentage, ()))
	}
}
