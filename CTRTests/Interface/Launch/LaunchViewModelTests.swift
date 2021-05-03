/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class LaunchViewModelTests: XCTestCase {

	var sut: LaunchViewModel?

	var appCoordinatorSpy = AppCoordinatorSpy()
	var versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")

	var remoteConfigSpy = RemoteConfigManagingSpy()
	var proofManagerSpy = ProofManagingSpy()

	override func setUp() {
		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")

		remoteConfigSpy = RemoteConfigManagingSpy()
		proofManagerSpy = ProofManagingSpy()

		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy
		)
	}

	// MARK: Tests

	/// Test the initializer for the holder
	func testInitHolder() {

		// Given

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy
		)

		// Then
		XCTAssertEqual(sut?.title, .holderLaunchTitle, "Title should match")
		XCTAssertEqual(sut?.message, .holderLaunchText, "Message should match")
		XCTAssertEqual(sut?.appIcon, .holderAppIcon, "Icon should match")
	}

	/// Test the initializer for the verifier
	func testInitVerifier() {

		// Given

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy
		)

		// Then
		XCTAssertEqual(sut?.title, .verifierLaunchTitle, "Title should match")
		XCTAssertEqual(sut?.message, .verifierLaunchText, "Message should match")
		XCTAssertEqual(sut?.appIcon, .verifierAppIcon, "Icon should match")
	}

	/// Test all good
	func testNoActionRequired() {

		// Given
		remoteConfigSpy.launchState = .noActionNeeded
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut?.checkRequirements()

		// Then
		XCTAssertTrue(remoteConfigSpy.updateCalled, "Method should be called")
		XCTAssertTrue(proofManagerSpy.invokedFetchIssuerPublicKeys, "Method should be called")
		XCTAssertTrue(appCoordinatorSpy.invokedHandleLaunchState, "Delegate method should be called")
		XCTAssertEqual(appCoordinatorSpy.invokedHandleLaunchStateParameters?.state, LaunchState.noActionNeeded, "State should match")
	}

	/// Test internet required for the remote config
	func testInternetRequiredRemoteConfig() {

		// Given
		remoteConfigSpy.launchState = .internetRequired
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut?.checkRequirements()

		// Then
		XCTAssertTrue(remoteConfigSpy.updateCalled, "Method should be called")
		XCTAssertTrue(proofManagerSpy.invokedFetchIssuerPublicKeys, "Method should be called")
		XCTAssertTrue(appCoordinatorSpy.invokedHandleLaunchState, "Delegate method should be called")
		XCTAssertEqual(appCoordinatorSpy.invokedHandleLaunchStateParameters?.state, LaunchState.internetRequired, "State should match")
	}

	/// Test internet required for the issuer public keys
	func testInternetRequiredIssuerPublicKeys() {

		// Given
		remoteConfigSpy.launchState = .noActionNeeded
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnErrorResult = (error, ())

		// When
		sut?.checkRequirements()

		// Then
		XCTAssertTrue(remoteConfigSpy.updateCalled, "Method should be called")
		XCTAssertTrue(proofManagerSpy.invokedFetchIssuerPublicKeys, "Method should be called")
		XCTAssertTrue(appCoordinatorSpy.invokedHandleLaunchState, "Delegate method should be called")
		XCTAssertEqual(appCoordinatorSpy.invokedHandleLaunchStateParameters?.state, LaunchState.internetRequired, "State should match")
	}

	/// Test internet required for the issuer public keys and the remote config
	func testInternetRequiredBothActions() {

		// Given
		remoteConfigSpy.launchState = .internetRequired
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnErrorResult = (error, ())

		// When
		sut?.checkRequirements()

		// Then
		XCTAssertTrue(remoteConfigSpy.updateCalled, "Method should be called")
		XCTAssertTrue(proofManagerSpy.invokedFetchIssuerPublicKeys, "Method should be called")
		XCTAssertTrue(appCoordinatorSpy.invokedHandleLaunchState, "Delegate method should be called")
		XCTAssertEqual(appCoordinatorSpy.invokedHandleLaunchStateParameters?.state, LaunchState.internetRequired, "State should match")
	}

	/// Test update required
	func testActionRequire() {

		// Given
		let remoteConfig = remoteConfigSpy.getConfiguration()
		remoteConfigSpy.launchState = .actionRequired(remoteConfig)
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut?.checkRequirements()

		// Then
		XCTAssertTrue(remoteConfigSpy.updateCalled, "Method should be called")
		XCTAssertTrue(proofManagerSpy.invokedFetchIssuerPublicKeys, "Method should be called")
		XCTAssertTrue(appCoordinatorSpy.invokedHandleLaunchState, "Delegate method should be called")
		XCTAssertEqual(appCoordinatorSpy.invokedHandleLaunchStateParameters?.state, LaunchState.actionRequired(remoteConfig), "State should match")
	}
}
