/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class AppInstalledSinceManagingSpy: AppInstalledSinceManaging {

	required init() {}

	var invokedFirstUseDateGetter = false
	var invokedFirstUseDateGetterCount = 0
	var stubbedFirstUseDate: Date!

	var firstUseDate: Date? {
		invokedFirstUseDateGetter = true
		invokedFirstUseDateGetterCount += 1
		return stubbedFirstUseDate
	}

	var invokedUpdateServerHeaderDate = false
	var invokedUpdateServerHeaderDateCount = 0
	var invokedUpdateServerHeaderDateParameters: (serverHeaderDate: String, ageHeader: String?)?
	var invokedUpdateServerHeaderDateParametersList = [(serverHeaderDate: String, ageHeader: String?)]()

	func update(serverHeaderDate: String, ageHeader: String?) {
		invokedUpdateServerHeaderDate = true
		invokedUpdateServerHeaderDateCount += 1
		invokedUpdateServerHeaderDateParameters = (serverHeaderDate, ageHeader)
		invokedUpdateServerHeaderDateParametersList.append((serverHeaderDate, ageHeader))
	}

	var invokedUpdate = false
	var invokedUpdateCount = 0
	var invokedUpdateParameters: (dateProvider: DocumentsDirectoryCreationDateProtocol, Void)?
	var invokedUpdateParametersList = [(dateProvider: DocumentsDirectoryCreationDateProtocol, Void)]()

	func update(dateProvider: DocumentsDirectoryCreationDateProtocol) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (dateProvider, ())
		invokedUpdateParametersList.append((dateProvider, ()))
	}

	var invokedReset = false
	var invokedResetCount = 0

	func reset() {
		invokedReset = true
		invokedResetCount += 1
	}
}
