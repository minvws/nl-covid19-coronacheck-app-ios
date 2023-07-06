/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared

public class RemoteConfigManagingSpy: RemoteConfigManaging {

	public init() {}

	public var invokedStoredConfigurationGetter = false
	public var invokedStoredConfigurationGetterCount = 0
	public var stubbedStoredConfiguration: RemoteConfiguration!

	public var storedConfiguration: RemoteConfiguration {
		invokedStoredConfigurationGetter = true
		invokedStoredConfigurationGetterCount += 1
		return stubbedStoredConfiguration
	}

	public var invokedObservatoryForUpdatesGetter = false
	public var invokedObservatoryForUpdatesGetterCount = 0
	public var stubbedObservatoryForUpdates: Observatory<RemoteConfigManager.ConfigNotification>!

	public var observatoryForUpdates: Observatory<RemoteConfigManager.ConfigNotification> {
		invokedObservatoryForUpdatesGetter = true
		invokedObservatoryForUpdatesGetterCount += 1
		return stubbedObservatoryForUpdates
	}

	public var invokedObservatoryForReloadsGetter = false
	public var invokedObservatoryForReloadsGetterCount = 0
	public var stubbedObservatoryForReloads: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>>!

	public var observatoryForReloads: Observatory<Result<RemoteConfigManager.ConfigNotification, ServerError>> {
		invokedObservatoryForReloadsGetter = true
		invokedObservatoryForReloadsGetterCount += 1
		return stubbedObservatoryForReloads
	}

	public var invokedUpdate = false
	public var invokedUpdateCount = 0
	public var invokedUpdateParameters: (isAppLaunching: Bool, Void)?
	public var invokedUpdateParametersList = [(isAppLaunching: Bool, Void)]()
	public var shouldInvokeUpdateImmediateCallbackIfWithinTTL = false
	public var stubbedUpdateCompletionResult: (Result<(Bool, RemoteConfiguration), ServerError>, Void)?

	public func update(
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
