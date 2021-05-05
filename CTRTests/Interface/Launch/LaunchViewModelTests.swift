/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class LaunchViewModelTests: XCTestCase {

	private var sut: LaunchViewModel!
	private var appCoordinatorSpy: AppCoordinatorSpy!
	private var versionSupplierSpy: AppVersionSupplierSpy!
	private var remoteConfigSpy: RemoteConfigManagingSpy!
	private var proofManagerSpy: ProofManagingSpy!
	private var jailBreakProtocolSpy: JailBreakProtocolSpy!
	private var userSettingsSpy: UserSettingsSpy!

	override func setUp() {
		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")

		remoteConfigSpy = RemoteConfigManagingSpy()
		proofManagerSpy = ProofManagingSpy()
		jailBreakProtocolSpy = JailBreakProtocolSpy()
		userSettingsSpy = UserSettingsSpy()

		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy
		)
	}

	// MARK: Tests

	func test_initializeHolder() {

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
		expect(self.sut.title) == .holderLaunchTitle
		expect(self.sut.message) == .holderLaunchText
		expect(self.sut.appIcon) == .holderAppIcon
	}

	func test_initializeVerifier() {

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
		expect(self.sut.title) == .verifierLaunchTitle
		expect(self.sut.message) == .verifierLaunchText
		expect(self.sut.appIcon) == .verifierAppIcon
	}

	func test_noActionRequired() {

		// Given
		remoteConfigSpy.launchState = .noActionNeeded
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut?.checkRequirements()

		// Then
		expect(self.remoteConfigSpy.updateCalled) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.noActionNeeded
	}

	/// Test internet required for the remote config
	func test_internetRequiredRemoteConfig() {

		// Given
		remoteConfigSpy.launchState = .internetRequired
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut?.checkRequirements()

		// Then
		expect(self.remoteConfigSpy.updateCalled) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
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
		expect(self.remoteConfigSpy.updateCalled) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
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
		expect(self.remoteConfigSpy.updateCalled) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
	}

	/// Test update required
	func testActionRequired() {

		// Given
		let remoteConfig = remoteConfigSpy.getConfiguration()
		remoteConfigSpy.launchState = .actionRequired(remoteConfig)
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true

		// When
		sut?.checkRequirements()

		// Then
		expect(self.remoteConfigSpy.updateCalled) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
	}

	func test_checkForJailBreak_notbroken_shouldwarn() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false

		// When
		let shouldShowJailBreakAlert = sut?.shouldShowJailBreakAlert()

		// Then
		expect(shouldShowJailBreakAlert) == false
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == true
	}

	func test_checkForJailBreak_broken_shouldwarn() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		let shouldShowJailBreakAlert = sut?.shouldShowJailBreakAlert()

		// Then
		expect(shouldShowJailBreakAlert) == true
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == true
	}

	func test_checkForJailBreak_notbroken_shouldnotwarn() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false

		// When
		let shouldShowJailBreakAlert = sut?.shouldShowJailBreakAlert()

		// Then
		expect(shouldShowJailBreakAlert) == false
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
	}

	func test_checkForJailBreak_broken_shouldnotwarn() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		let shouldShowJailBreakAlert = sut?.shouldShowJailBreakAlert()

		// Then
		expect(shouldShowJailBreakAlert) == false
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
	}

	func test_checkForJailBreak_broken_shouldWarn_butIsVerifier() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy
		)

		// When
		let shouldShowJailBreakAlert = sut?.shouldShowJailBreakAlert()

		// Then
		expect(shouldShowJailBreakAlert) == false
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
	}

	func test_dismissJailBreakWarning() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false

		// When
		sut.dismissJailBreakWarning()

		// Then
		expect(self.userSettingsSpy.invokedJailbreakWarningShownSetter) == true
		expect(self.userSettingsSpy.invokedJailbreakWarningShown) == true
	}
}
