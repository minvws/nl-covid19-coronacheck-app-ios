/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class RemoteConfigManagingSpy: RemoteConfigManaging {

	required init(networkManager: NetworkManaging?) {}

	var invokedUpdate = false
	var invokedUpdateCount = 0
	var stubbedUpdateCompletionResult: (Result<(RemoteConfiguration, Data, URLResponse), ServerError>, Void)?

	func update(completion: @escaping (Result<(RemoteConfiguration, Data, URLResponse), ServerError>) -> Void) {
		invokedUpdate = true
		invokedUpdateCount += 1
		if let result = stubbedUpdateCompletionResult {
			completion(result.0)
		}
	}

	var invokedGetConfiguration = false
	var invokedGetConfigurationCount = 0
	var stubbedGetConfigurationResult: RemoteConfiguration!

	func getConfiguration() -> RemoteConfiguration {
		invokedGetConfiguration = true
		invokedGetConfigurationCount += 1
		return stubbedGetConfigurationResult
	}

	var invokedReset = false
	var invokedResetCount = 0

	func reset() {
		invokedReset = true
		invokedResetCount += 1
	}
}
