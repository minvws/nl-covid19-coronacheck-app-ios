/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class RemoteConfigManagingSpy: RemoteConfigManaging {

	var appVersion: String = "1.0.0"
	var updateCalled = false
	var getConfigurationCalled = false
	var launchState: LaunchState?
	var configuration: RemoteConfiguration

	required init() {
		configuration = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: "RemoteConfigManagingSpy",
			storeUrl: nil,
			deactivated: false,
			informationURL: nil,
			configTTL: 3600,
			maxValidityHours: 48
		)
	}

	func update(completion: @escaping (LaunchState) -> Void) {

		updateCalled = true
		if let state = launchState {
			completion(state)
		}
	}

	func getConfiguration() -> RemoteConfiguration {

		getConfigurationCalled = true
		return configuration
	}

	func reset() {
		configuration = .default
	}
}
