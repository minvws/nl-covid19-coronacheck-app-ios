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

		sut = RemoteConfigManager()
		sut.reset()
		networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
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
			self.sut.lastFetchedTimestamp = nil
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.internetRequired
				done()
			}
		}
	}

	/// Test the remote config manager update call no result from the api
	func test_remoteConfigManagerUpdate_errorFromApi_withinTTL() {

		// Given
		waitUntil(timeout: .seconds(100)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.failure(NetworkError.invalidRequest), ())
			self.sut.lastFetchedTimestamp = Date()
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.noActionNeeded
				done()
			}
		}
	}

	/// Test the remote config manager update call with equal version numbers
	func test_remoteConfigManagerUpdate_versionsEqual() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration(
				minVersion: "1.0.0",
				minVersionMessage: "test_remoteConfigManagerUpdate_versionsEqual"
			), Data())), ())
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
			self.sut.lastFetchedTimestamp = nil

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.noActionNeeded
				done()
			}
		}
	}

	/// Test the remote config manager update call with equal version numbers
	func test_emoteConfigManagerUpdate_versionsAlmostEqual() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration(
				minVersion: "1.0",
				minVersionMessage: "test_emoteConfigManagerUpdate_versionsAlmostEqual"
			), Data())), ())
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
			self.sut.lastFetchedTimestamp = nil

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.noActionNeeded
				done()
			}
		}
	}

	/// Test the remote config manager update call with unequal version numbers
	func test_remoteConfigManagerUpdate_versionsUnEqualBug() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let configuration = RemoteConfiguration(
				minVersion: "1.0.1",
				minVersionMessage: "test_remoteConfigManagerUpdate_versionsUnEqualBug"
			)
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((configuration, Data())), ())
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
			self.sut.lastFetchedTimestamp = nil

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.actionRequired(configuration)
				done()
			}
		}
	}

	/// Test the remote config manager update call with unequal version numbers
	func test_remoteConfigManagerUpdate_versionsUnEqualMajor() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let configuration = RemoteConfiguration(
				minVersion: "4.3.2",
				minVersionMessage: "test_remoteConfigManagerUpdate_versionsUnEqualMajor"
			)
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((configuration, Data())), ())
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "2.3.4")
			self.sut.lastFetchedTimestamp = nil

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.actionRequired(configuration)
				done()
			}

		}
	}
	//
	/// Test the remote config manager update call with unequal version numbers
	func test_remoteConfigManagerUpdate_existingVersionHigher() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let configuration = RemoteConfiguration(
				minVersion: "1.0.0",
				minVersionMessage: "test_remoteConfigManagerUpdate_existingVersionHigher"
			)
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((configuration, Data())), ())
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.1")
			self.sut.lastFetchedTimestamp = nil

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.noActionNeeded
				done()
			}
		}
	}

	/// Test the remote config manager update call with end of life
	func test_remoteConfigManager_endOfLife() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let configuration = RemoteConfiguration(
				minVersion: "1.0.0",
				minVersionMessage: "test_remoteConfigManager_endOfLife",
				deactivated: true
			)
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((configuration, Data())), ())
			self.sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
			self.sut.lastFetchedTimestamp = nil

			// When
			self.sut.update { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state) == LaunchState.actionRequired(configuration)
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
			euLaunchDate: "2021-06-03T14:00:00+00:00",
			maxValidityHours: 48,
			recoveryWaitingPeriodDays: 11,
			requireUpdateBefore: nil,
			temporarilyDisabled: false,
			vaccinationValidityHours: 14600,
			recoveryValidityHours: 7300,
			testValidityHours: 40,
			domesticValidityHours: 40,
			vaccinationEventValidity: 14600,
			recoveryEventValidity: 7300,
			testEventValidity: 40,
			isGGDEnabled: true
		)

	}
}
