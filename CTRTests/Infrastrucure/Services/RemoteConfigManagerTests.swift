/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class RemoteConfigManagerTests: XCTestCase {
	
	// MARK: - Setup
	private var sut: RemoteConfigManager!
	private var networkSpy: NetworkSpy!

	override func setUp() {

		networkSpy = NetworkSpy(configuration: .development)
		sut = RemoteConfigManager(networkManager: networkSpy)
		sut.reset()
		super.setUp()
	}
	
	override func tearDown() {
		
		super.tearDown()
	}

	// MARK: - Tests

	/// Test the remote config manager update call no result from the api
	func test_remoteConfigManagerUpdate_errorFromApi() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .invalidRequest)), ())

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state.isFailure) == true
				done()
			}
		}
	}

	/// Test the remote config manager update call with succss
	func test_remoteConfigManagerUpdate_succes() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration.default, Data(), URLResponse())), ())
			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state.isSuccess) == true
				done()
			}
		}
	}
}
