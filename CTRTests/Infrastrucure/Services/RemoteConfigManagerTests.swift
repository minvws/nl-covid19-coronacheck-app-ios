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

		networkSpy = NetworkSpy(configuration: .test)
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
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.failure(NetworkError.invalidRequest), ())

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
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration(
				minVersion: "1.0.0",
				minVersionMessage: "test_remoteConfigManagerUpdate_versionsEqual"
			), Data())), ())
			
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

extension RemoteConfiguration {

	init(minVersion: String, minVersionMessage: String?, deactivated: Bool? = nil) {

		self.init(
			minVersion: minVersion,
			minVersionMessage: minVersionMessage,
			storeUrl: nil,
			deactivated: deactivated,
			informationURL: nil,
			configTTL: 3600,
			recoveryWaitingPeriodDays: 11,
			requireUpdateBefore: nil,
			temporarilyDisabled: false,
			domesticValidityHours: 40,
			vaccinationEventValidity: 14600,
			recoveryEventValidity: 7300,
			testEventValidity: 40,
			isGGDEnabled: true,
			recoveryExpirationDays: 180,
			credentialRenewalDays: 5
		)
	}
}
