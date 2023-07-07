/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared

final public class CryptoLibUtilitySpy: CryptoLibUtilityProtocol {
	
	public init() {}

	public var invokedHasPublicKeysGetter = false
	public var invokedHasPublicKeysGetterCount = 0
	public var stubbedHasPublicKeys: Bool! = false

	public var hasPublicKeys: Bool {
		invokedHasPublicKeysGetter = true
		invokedHasPublicKeysGetterCount += 1
		return stubbedHasPublicKeys
	}

	public var invokedIsInitializedGetter = false
	public var invokedIsInitializedGetterCount = 0
	public var stubbedIsInitialized: Bool! = false

	public var isInitialized: Bool {
		invokedIsInitializedGetter = true
		invokedIsInitializedGetterCount += 1
		return stubbedIsInitialized
	}

	public var invokedInitialize = false
	public var invokedInitializeCount = 0

	public func initialize() {
		invokedInitialize = true
		invokedInitializeCount += 1
	}

	public var invokedStore = false
	public var invokedStoreCount = 0
	public var invokedStoreParameters: (data: Data, file: CryptoLibUtility.File)?
	public var invokedStoreParametersList = [(data: Data, file: CryptoLibUtility.File)]()

	public func store(_ data: Data, for file: CryptoLibUtility.File) {
		invokedStore = true
		invokedStoreCount += 1
		invokedStoreParameters = (data, file)
		invokedStoreParametersList.append((data, file))
	}

	public var invokedRead = false
	public var invokedReadCount = 0
	public var invokedReadParameters: (file: CryptoLibUtility.File, Void)?
	public var invokedReadParametersList = [(file: CryptoLibUtility.File, Void)]()
	public var stubbedReadResult: Data!

	public func read(_ file: CryptoLibUtility.File) -> Data? {
		invokedRead = true
		invokedReadCount += 1
		invokedReadParameters = (file, ())
		invokedReadParametersList.append((file, ()))
		return stubbedReadResult
	}

	public var invokedCheckFile = false
	public var invokedCheckFileCount = 0
	public var invokedCheckFileParameters: (file: CryptoLibUtility.File, Void)?
	public var invokedCheckFileParametersList = [(file: CryptoLibUtility.File, Void)]()

	public func checkFile(_ file: CryptoLibUtility.File) {
		invokedCheckFile = true
		invokedCheckFileCount += 1
		invokedCheckFileParameters = (file, ())
		invokedCheckFileParametersList.append((file, ()))
	}

	public var invokedUpdate = false
	public var invokedUpdateCount = 0
	public var invokedUpdateParameters: (isAppLaunching: Bool, Void)?
	public var invokedUpdateParametersList = [(isAppLaunching: Bool, Void)]()
	public var shouldInvokeUpdateImmediateCallbackIfWithinTTL = false
	public var stubbedUpdateCompletionResult: (Result<Bool, ServerError>, Void)?

	public func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: (() -> Void)?,
		completion: ((Result<Bool, ServerError>) -> Void)?) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (isAppLaunching, ())
		invokedUpdateParametersList.append((isAppLaunching, ()))
		if shouldInvokeUpdateImmediateCallbackIfWithinTTL {
			immediateCallbackIfWithinTTL?()
		}
		if let result = stubbedUpdateCompletionResult {
			completion?(result.0)
		}
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}

	public var invokedRegisterTriggers = false
	public var invokedRegisterTriggersCount = 0

	public func registerTriggers() {
		invokedRegisterTriggers = true
		invokedRegisterTriggersCount += 1
	}
}
