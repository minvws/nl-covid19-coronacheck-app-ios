/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class RemoteConfigManagingSpy: RemoteConfigManaging {

	var invokedStoredConfigurationGetter = false
	var invokedStoredConfigurationGetterCount = 0
	var stubbedStoredConfiguration: RemoteConfiguration!

	var storedConfiguration: RemoteConfiguration {
		invokedStoredConfigurationGetter = true
		invokedStoredConfigurationGetterCount += 1
		return stubbedStoredConfiguration
	}

	var invokedAppendUpdateObserver = false
	var invokedAppendUpdateObserverCount = 0
	var stubbedAppendUpdateObserverObserverResult: (RemoteConfiguration, Data, URLResponse)?
	var stubbedAppendUpdateObserverResult: ObserverToken!

	func appendUpdateObserver(_ observer: @escaping (RemoteConfiguration, Data, URLResponse) -> Void) -> ObserverToken {
		invokedAppendUpdateObserver = true
		invokedAppendUpdateObserverCount += 1
		if let result = stubbedAppendUpdateObserverObserverResult {
			observer(result.0, result.1, result.2)
		}
		return stubbedAppendUpdateObserverResult
	}

	var invokedAppendReloadObserver = false
	var invokedAppendReloadObserverCount = 0
	var stubbedAppendReloadObserverObserverResult: (RemoteConfiguration, Data, URLResponse)?
	var stubbedAppendReloadObserverResult: ObserverToken!

	func appendReloadObserver(_ observer: @escaping (RemoteConfiguration, Data, URLResponse) -> Void) -> ObserverToken {
		invokedAppendReloadObserver = true
		invokedAppendReloadObserverCount += 1
		if let result = stubbedAppendReloadObserverObserverResult {
			observer(result.0, result.1, result.2)
		}
		return stubbedAppendReloadObserverResult
	}

	var invokedRemoveObserver = false
	var invokedRemoveObserverCount = 0
	var invokedRemoveObserverParameters: (token: ObserverToken, Void)?
	var invokedRemoveObserverParametersList = [(token: ObserverToken, Void)]()

	func removeObserver(token: ObserverToken) {
		invokedRemoveObserver = true
		invokedRemoveObserverCount += 1
		invokedRemoveObserverParameters = (token, ())
		invokedRemoveObserverParametersList.append((token, ()))
	}

	var invokedUpdate = false
	var invokedUpdateCount = 0
	var invokedUpdateParameters: (isAppLaunching: Bool, Void)?
	var invokedUpdateParametersList = [(isAppLaunching: Bool, Void)]()
	var shouldInvokeUpdateImmediateCallbackIfWithinTTL = false
	var stubbedUpdateCompletionResult: (Result<(Bool, RemoteConfiguration), ServerError>, Void)?

	func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: @escaping () -> Void,
		completion: @escaping (Result<(Bool, RemoteConfiguration), ServerError>) -> Void) {
		invokedUpdate = true
		invokedUpdateCount += 1
		invokedUpdateParameters = (isAppLaunching, ())
		invokedUpdateParametersList.append((isAppLaunching, ()))
		if shouldInvokeUpdateImmediateCallbackIfWithinTTL {
			immediateCallbackIfWithinTTL()
		}
		if let result = stubbedUpdateCompletionResult {
			completion(result.0)
		}
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}

	var invokedRegisterTriggers = false
	var invokedRegisterTriggersCount = 0

	func registerTriggers() {
		invokedRegisterTriggers = true
		invokedRegisterTriggersCount += 1
	}
}
