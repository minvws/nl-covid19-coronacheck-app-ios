/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared

class RemoteConfigManagingSpy: RemoteConfigManaging {

	var invokedStoredConfigurationGetter = false
	var invokedStoredConfigurationGetterCount = 0
	var stubbedStoredConfiguration: RemoteConfiguration!

	var storedConfiguration: RemoteConfiguration {
		invokedStoredConfigurationGetter = true
		invokedStoredConfigurationGetterCount += 1
		return stubbedStoredConfiguration
	}

	var invokedObservatoryForUpdatesGetter = false
	var invokedObservatoryForUpdatesGetterCount = 0
	var stubbedObservatoryForUpdates: Observatory<RemoteConfigManager.ConfigNotification>!

	var observatoryForUpdates: Observatory<RemoteConfigManager.ConfigNotification> {
		invokedObservatoryForUpdatesGetter = true
		invokedObservatoryForUpdatesGetterCount += 1
		return stubbedObservatoryForUpdates
	}

	var invokedObservatoryForReloadsGetter = false
	var invokedObservatoryForReloadsGetterCount = 0
	var stubbedObservatoryForReloads: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>!

	var observatoryForReloads: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>> {
		invokedObservatoryForReloadsGetter = true
		invokedObservatoryForReloadsGetterCount += 1
		return stubbedObservatoryForReloads
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
