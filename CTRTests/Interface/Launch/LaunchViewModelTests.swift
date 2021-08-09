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
	private var walletSpy: WalletManagerSpy!

	override func setUp() {
		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")
		remoteConfigSpy = RemoteConfigManagingSpy(networkManager: NetworkSpy())
		proofManagerSpy = ProofManagingSpy()
		jailBreakProtocolSpy = JailBreakProtocolSpy()
		userSettingsSpy = UserSettingsSpy()
		cryptoLibUtilitySpy = CryptoLibUtilitySpy()
		remoteConfigSpy.stubbedGetConfigurationResult = remoteConfig
		walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))
	}

	let remoteConfig = RemoteConfiguration(
		minVersion: "1.0",
		minVersionMessage: "test message",
		storeUrl: URL(string: "https://apple.com"),
		deactivated: nil,
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
		credentialRenewalDays: 5,
		domesticQRRefreshSeconds: 60
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
			proofManager: proofManagerSpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.sut.title) == L.holderLaunchTitle()
		expect(self.sut.message) == L.holderLaunchText()
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
			proofManager: proofManagerSpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.sut.title) == L.verifierLaunchTitle()
		expect(self.sut.message) == L.verifierLaunchText()
		expect(self.sut.appIcon) == .verifierAppIcon
	}

	func test_noActionRequired() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((RemoteConfiguration.default, Data(), URLResponse())), ())

		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.success(Data()), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.noActionNeeded
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == true
	}

	/// Test internet required for the remote config
	func test_internetRequired_forRemoteConfig() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.noInternetConnection), ())
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.success(Data()), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test internet required for the issuer public keys
	func test_internetRequired_forIssuerPublicKeys() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.failure(.noInternetConnection), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test internet required for the issuer public keys and the remote config
	func test_internetRequired_forBothActions() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.noInternetConnection), ())
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.failure(.noInternetConnection), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test internet required for the remote config
	func test_internetRequired_forBothActions_butWithinTTL() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.noInternetConnection), ())
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.failure(.noInternetConnection), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		cryptoLibUtilitySpy.stubbedIsInitialized = true
		userSettingsSpy.stubbedConfigFetchedTimestamp = Date().timeIntervalSince1970 - 600
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = Date().timeIntervalSince1970 - 600

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateCount).toEventually(equal(1))
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test update required
	func test_actionRequired() {

		// Given
		var remoteConfig = RemoteConfiguration.default
		remoteConfig.minimumVersion = "2.0"

		remoteConfigSpy.stubbedGetConfigurationResult = remoteConfig
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((remoteConfig, Data(), URLResponse())), ())
		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.success(Data()), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
	}

	/// Test crypto library not initialized
	func test_cryptoLibNotInitialized() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((RemoteConfiguration.default, Data(), URLResponse())), ())

		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.success(Data()), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.cryptoLibNotInitialized
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == true
	}

	func test_killswitchEnabled() {

		// Given
		var remoteConfig = RemoteConfiguration.default
//		remoteConfig.minimumVersion = "1.0.0"
		remoteConfig.appDeactivated = true

		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((remoteConfig, Data(), URLResponse())), ())

		proofManagerSpy.stubbedFetchIssuerPublicKeysOnCompletionResult = (.success(Data()), ())
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
			cryptoLibUtility: cryptoLibUtilitySpy,
			walletManager: walletSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.proofManagerSpy.invokedFetchIssuerPublicKeys) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
		expect(self.sut.interruptForJailBreakDialog) == false
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
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
			userSettings: userSettingsSpy,
			walletManager: walletSpy
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
			userSettings: userSettingsSpy,
			walletManager: walletSpy
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
			userSettings: userSettingsSpy,
			walletManager: walletSpy
		)

		// When
		sut.userDismissedJailBreakWarning()

		// Then
		expect(self.userSettingsSpy.invokedJailbreakWarningShownSetter) == true
		expect(self.userSettingsSpy.invokedJailbreakWarningShown) == true
		expect(self.sut.interruptForJailBreakDialog) == false
	}
}
