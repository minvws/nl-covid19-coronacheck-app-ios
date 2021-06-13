//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

final class CryptoLibUtilitySpy: CryptoLibUtilityProtocol {

	var invokedIsInitializedGetter = false
	var invokedIsInitializedGetterCount = 0
	var stubbedIsInitialized: Bool! = false

	var isInitialized: Bool {
		invokedIsInitializedGetter = true
		invokedIsInitializedGetterCount += 1
		return stubbedIsInitialized
	}

	var invokedInitialize = false
	var invokedInitializeCount = 0

	func initialize() {
		invokedInitialize = true
		invokedInitializeCount += 1
	}

	var invokedStore = false
	var invokedStoreCount = 0
	var invokedStoreParameters: (data: Data, file: CryptoLibUtility.File)?
	var invokedStoreParametersList = [(data: Data, file: CryptoLibUtility.File)]()

	func store(_ data: Data, for file: CryptoLibUtility.File) {
		invokedStore = true
		invokedStoreCount += 1
		invokedStoreParameters = (data, file)
		invokedStoreParametersList.append((data, file))
	}
}
