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
	private var cryptoLibUtilitySpy: CryptoLibUtilitySpy!

	override func setUp() {
		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")
		remoteConfigSpy = RemoteConfigManagingSpy()
		proofManagerSpy = ProofManagingSpy()
		jailBreakProtocolSpy = JailBreakProtocolSpy()
		userSettingsSpy = UserSettingsSpy()
		cryptoLibUtilitySpy = CryptoLibUtilitySpy()
		remoteConfigSpy.stubbedGetConfigurationResult = remoteConfig
	}

	let remoteConfig = RemoteConfiguration(
		minVersion: "1.0",
		minVersionMessage: "test message",
		storeUrl: URL(string: "https://apple.com"),
		deactivated: nil,
		informationURL: nil,
		configTTL: 3600,
		euLaunchDate: "2021-06-03T14:00:00+00:00",
		maxValidityHours: 48,
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
		expect(self.proofManagerSpy.invokedMigrateExistingProof) == true
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
		expect(self.proofManagerSpy.invokedMigrateExistingProof) == false
	}

	func test_noActionRequired() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.noActionNeeded, ())
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.noActionNeeded
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == true
	}

	/// Test internet required for the remote config
	func test_internetRequiredRemoteConfig() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.internetRequired, ())
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test internet required for the issuer public keys
	func testInternetRequiredIssuerPublicKeys() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.noActionNeeded, ())
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnErrorResult = (error, ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test internet required for the issuer public keys and the remote config
	func testInternetRequiredBothActions() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.internetRequired, ())
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnErrorResult = (error, ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test update required
	func testActionRequired() {

		// Given
		remoteConfigSpy.stubbedGetConfigurationResult = RemoteConfiguration(minVersion: "1.0", minVersionMessage: "remoteConfigSpy")
		let remoteConfig = remoteConfigSpy.getConfiguration()
		remoteConfigSpy.stubbedUpdateCompletionResult = (.actionRequired(remoteConfig), ())
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}
	
	/// Test crypto library not initialized
	func test_cryptoLibNotInitialized() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.cryptoLibNotInitialized, ())
		proofManagerSpy.shouldInvokeFetchIssuerPublicKeysOnCompletion = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.cryptoLibNotInitialized
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == true
	}

	func test_checkForJailBreak_broken_shouldwarn() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == false
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.interruptForJailBreakDialog) == true
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == true
	}

	func test_checkForJailBreak_broken_shouldnotwarn() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
	}

	func test_checkForJailBreak_broken_shouldWarn_butIsVerifier() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
	}

	func test_userDismissedJailBreakWarning() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy
		)

		// When
		sut.userDismissedJailBreakWarning()

		// Then
		expect(self.userSettingsSpy.invokedJailbreakWarningShownSetter) == true
		expect(self.userSettingsSpy.invokedJailbreakWarningShown) == true
		expect(self.sut.interruptForJailBreakDialog) == false
	}
}
