/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class RemoteConfigManagerTests: XCTestCase {
	
	// MARK: - Setup
	var sut = RemoteConfigManager()

	override func setUp() {

		sut = RemoteConfigManager()
		super.setUp()
	}
	
	override func tearDown() {
		
		super.tearDown()
	}

	// MARK: - TestDoubles

	class RemoteConfigurationApiSpy: RemoteConfigurationApiClientProtocol {

		var remoteConfig: RemoteConfiguration?

		init(_ config: RemoteConfiguration?) {

			remoteConfig = config
		}

		func getRemoteConfiguration(_ completionHandler: @escaping (RemoteConfiguration?) -> Void) {

			completionHandler(remoteConfig)
		}
	}

	class AppVersionSupplierSpy: AppVersionSupplierProtocol {

		var appVersion: String

		init(version: String) {

			appVersion = version
		}

		func getCurrentVersion() -> String {

			return appVersion
		}
	}

	// MARK: - Tests

	/// Test the remote config manager update call no result from the api
	func testRemoteConfigManagerUpdateNoResultFromApi() {

		// Given
		let expectation = self.expectation(description: "remote config no result from api")
		sut.remoteApiClient = RemoteConfigurationApiSpy(nil)

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.noActionNeeded, "State should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the remote config manager update call with equal version numbers
	func testRemoteConfigManagerUpdateVersionsEqual() {

		// Given
		let expectation = self.expectation(description: "remote config versions are equal")
		sut.remoteApiClient = RemoteConfigurationApiSpy(
			RemoteConfiguration(
				minVersion: "1.0.0",
				minVersionMessage: "testRemoteConfigManagerUpdateVersionsEqual",
				storeUrl: nil,
				deactivated: nil,
				informationURL: nil
			)
		)
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.noActionNeeded, "State should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the remote config manager update call with equal version numbers
	func testRemoteConfigManagerUpdateVersionsAlmostEqual() {

		// Given
		let expectation = self.expectation(description: "remote config versions are almost equal")
		sut.remoteApiClient = RemoteConfigurationApiSpy(
			RemoteConfiguration(
				minVersion: "1.0",
				minVersionMessage: "testRemoteConfigManagerUpdateVersionsEqual",
				storeUrl: nil,
				deactivated: nil,
				informationURL: nil
			)
		)
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.noActionNeeded, "State should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the remote config manager update call with unequal version numbers
	func testRemoteConfigManagerUpdateVersionsUnEqualBug() {

		// Given
		let expectation = self.expectation(description: "remote config update required on bug")
		let configuration = RemoteConfiguration(
			minVersion: "1.0.1",
			minVersionMessage: "testRemoteConfigManagerUpdateVersionsUnEqualBug",
			storeUrl: nil,
			deactivated: nil,
			informationURL: nil
		)
		sut.remoteApiClient = RemoteConfigurationApiSpy(configuration)
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.actionRequired(configuration))

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the remote config manager update call with unequal version numbers
	func testRemoteConfigManagerUpdateVersionsUnEqualMajor() {

		// Given
		let expectation = self.expectation(description: "remote config update required on major")
		let configuration = RemoteConfiguration(
			minVersion: "4.3.2",
			minVersionMessage: "testRemoteConfigManagerUpdateVersionsUnEqualMajor",
			storeUrl: nil,
			deactivated: nil,
			informationURL: nil
		)
		sut.remoteApiClient = RemoteConfigurationApiSpy(configuration)
		sut.versionSupplier = AppVersionSupplierSpy(version: "2.3.4")

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.actionRequired(configuration))

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the remote config manager update call with unequal version numbers
	func testRemoteConfigManagerUpdateExistingVersionHigher() {

		// Given
		let expectation = self.expectation(description: "remote config current version higher")
		let configuration = RemoteConfiguration(
			minVersion: "1.0.0",
			minVersionMessage: "testRemoteConfigManagerUpdateExistingVersionHigher",
			storeUrl: nil,
			deactivated: nil,
			informationURL: nil
		)
		sut.remoteApiClient = RemoteConfigurationApiSpy(configuration)
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.1")

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.noActionNeeded, "State should match")

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}

	/// Test the remote config manager update call with end of life
	func testRemoteConfigManagerEndOfLife() {

		// Given
		let expectation = self.expectation(description: "remote config current version higher")
		let configuration = RemoteConfiguration(
			minVersion: "1.0.0",
			minVersionMessage: "testRemoteConfigManagerUpdateExistingVersionHigher",
			storeUrl: nil,
			deactivated: true,
			informationURL: nil
		)
		sut.remoteApiClient = RemoteConfigurationApiSpy(configuration)
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")

		// When
		sut.update { state in

			// Then
			XCTAssertEqual(state, UpdateState.actionRequired(configuration))

			expectation.fulfill()
		}
		waitForExpectations(timeout: 10, handler: nil)
	}
}
