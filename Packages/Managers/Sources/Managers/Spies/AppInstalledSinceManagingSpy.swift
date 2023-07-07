/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public class AppInstalledSinceManagingSpy: AppInstalledSinceManaging {
	
	public init() {}

	public var invokedFirstUseDateGetter = false
	public var invokedFirstUseDateGetterCount = 0
	public var stubbedFirstUseDate: Date!

	public var firstUseDate: Date? {
		invokedFirstUseDateGetter = true
		invokedFirstUseDateGetterCount += 1
		return stubbedFirstUseDate
	}

	public var invokedUpdateServerHeaderDate = false
	public var invokedUpdateServerHeaderDateCount = 0
	public var invokedUpdateServerHeaderDateParameters: (serverHeaderDate: String, ageHeader: String?)?
	public var invokedUpdateServerHeaderDateParametersList = [(serverHeaderDate: String, ageHeader: String?)]()

	public func update(serverHeaderDate: String, ageHeader: String?) {
		invokedUpdateServerHeaderDate = true
		invokedUpdateServerHeaderDateCount += 1
		invokedUpdateServerHeaderDateParameters = (serverHeaderDate, ageHeader)
		invokedUpdateServerHeaderDateParametersList.append((serverHeaderDate, ageHeader))
	}

	public var invokedUpdate = false
	public var invokedUpdateCount = 0
	public var invokedUpdateParameters: (dateProvider: DocumentsDirectoryCreationDateProtocol, Void)?
	public var invokedUpdateParametersList = [(dateProvider: DocumentsDirectoryCreationDateProtocol, Void)]()

	public func update(dateProvider: DocumentsDirectoryCreationDateProtocol) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (dateProvider, ())
		invokedUpdateParametersList.append((dateProvider, ()))
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
