/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

final class CryptoLibUtilitySpy: CryptoLibUtilityProtocol {

	required init(now: @escaping () -> Date, userSettings: UserSettingsProtocol, fileStorage: FileStorage, flavor: AppFlavor) {}

	var invokedHasPublicKeysGetter = false
	var invokedHasPublicKeysGetterCount = 0
	var stubbedHasPublicKeys: Bool! = false

	var hasPublicKeys: Bool {
		invokedHasPublicKeysGetter = true
		invokedHasPublicKeysGetterCount += 1
		return stubbedHasPublicKeys
	}

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

	var invokedCheckFile = false
	var invokedCheckFileCount = 0
	var invokedCheckFileParameters: (file: CryptoLibUtility.File, Void)?
	var invokedCheckFileParametersList = [(file: CryptoLibUtility.File, Void)]()

	func checkFile(_ file: CryptoLibUtility.File) {
		invokedCheckFile = true
		invokedCheckFileCount += 1
		invokedCheckFileParameters = (file, ())
		invokedCheckFileParametersList.append((file, ()))
	}

	var invokedUpdate = false
	var invokedUpdateCount = 0
	var invokedUpdateParameters: (isAppFirstLaunch: Bool, Void)?
	var invokedUpdateParametersList = [(isAppFirstLaunch: Bool, Void)]()
	var shouldInvokeUpdateImmediateCallbackIfWithinTTL = false
	var stubbedUpdateCompletionResult: (Result<Bool, ServerError>, Void)?

	func update(
		isAppFirstLaunch: Bool,
		immediateCallbackIfWithinTTL: (() -> Void)?,
		completion: ((Result<Bool, ServerError>) -> Void)?) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (isAppFirstLaunch, ())
		invokedUpdateParametersList.append((isAppFirstLaunch, ()))
		if shouldInvokeUpdateImmediateCallbackIfWithinTTL {
			immediateCallbackIfWithinTTL?()
		}
		if let result = stubbedUpdateCompletionResult {
			completion?(result.0)
		}
	}

	var invokedReset = false
	var invokedResetCount = 0

	func reset() {
		invokedReset = true
		invokedResetCount += 1
	}
}
