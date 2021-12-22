/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import XCTest
@testable import CTR
import Nimble

class LaunchViewModelTests: XCTestCase {

	private var sut: LaunchViewModel!
	private var appCoordinatorSpy: AppCoordinatorSpy!
	private var versionSupplierSpy: AppVersionSupplierSpy!
	private var remoteConfigSpy: RemoteConfigManagingSpy!
	private var jailBreakProtocolSpy: JailBreakProtocolSpy!
	private var deviceAuthenticationSpy: DeviceAuthenticationSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var cryptoLibUtilitySpy: CryptoLibUtilitySpy!
	private var walletSpy: WalletManagerSpy!

	override func setUp() {
		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")
		remoteConfigSpy = RemoteConfigManagingSpy()
		remoteConfigSpy.stubbedStoredConfiguration = remoteConfig
		remoteConfigSpy.stubbedAppendReloadObserverResult = UUID()
		remoteConfigSpy.stubbedAppendUpdateObserverResult = UUID()
		remoteConfigSpy.stubbedAppendReloadObserverObserverResult = (.default, Data(), URLResponse())

		jailBreakProtocolSpy = JailBreakProtocolSpy()
		deviceAuthenticationSpy = DeviceAuthenticationSpy()
		userSettingsSpy = UserSettingsSpy()
		cryptoLibUtilitySpy = CryptoLibUtilitySpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			fileStorage: FileStorage(),
			flavor: AppFlavor.flavor
		)
		walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))

		Services.use(cryptoLibUtilitySpy)
		Services.use(deviceAuthenticationSpy)
		Services.use(jailBreakProtocolSpy)
		Services.use(remoteConfigSpy)
		Services.use(walletSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	let remoteConfig = RemoteConfiguration.default

	// MARK: Tests

	func test_initializeHolder() {

		// Given

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.sut.title) == L.holderLaunchTitle()
		expect(self.sut.message) == L.holderLaunchText()
		expect(self.sut.appIcon) == I.holderAppIcon()
	}

	func test_initializeVerifier() {

		// Given

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier
		)

		// Then
		expect(self.sut.title) == L.verifierLaunchTitle()
		expect(self.sut.message) == L.verifierLaunchText()
		expect(self.sut.appIcon) == I.verifierAppIcon()
	}

	func test_noActionRequired() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((false, RemoteConfiguration.default)), ())
		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.noActionNeeded
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter).toEventually(beTrue())
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	func test_withinTTL() {

		// Given
		remoteConfigSpy.shouldInvokeUpdateImmediateCallbackIfWithinTTL = true
		cryptoLibUtilitySpy.shouldInvokeUpdateImmediateCallbackIfWithinTTL = true

		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.withinTTL
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter).toEventually(beFalse())
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	/// Test internet required for the remote config
	func test_internetRequired_forRemoteConfig() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	/// Test internet required for the issuer public keys
	func test_internetRequired_forIssuerPublicKeys() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((false, RemoteConfiguration.default)), ())
		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	/// Test internet required for the issuer public keys and the remote config
	func test_internetRequired_forBothActions() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	/// Test internet required for the remote config
	func test_internetRequired_forBothActions_butWithinTTL() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true
		userSettingsSpy.stubbedConfigFetchedTimestamp = Date().timeIntervalSince1970 - 600
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = Date().timeIntervalSince1970 - 600

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateCount).toEventually(equal(1))
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.internetRequired
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	/// Test update required
	func test_actionRequired() {

		// Given
		var remoteConfig = RemoteConfiguration.default
		remoteConfig.minimumVersion = "2.0"

		remoteConfigSpy.stubbedStoredConfiguration = remoteConfig
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((false, remoteConfig)), ())
		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	/// Test crypto library not initialized
	func test_cryptoLibNotInitialized() {

		// Given
		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((false, RemoteConfiguration.default)), ())

		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state)
			.toEventually(equal(LaunchState.cryptoLibNotInitialized))
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter).toEventually(beTrue())
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	func test_killswitchEnabled() {

		// Given
		var remoteConfig = RemoteConfiguration.default
		remoteConfig.appDeactivated = true

		remoteConfigSpy.stubbedUpdateCompletionResult = (.success((false, remoteConfig)), ())

		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	func test_killswitchEnabled_noInternet() {

		// Given
		var remoteConfig = RemoteConfiguration.default
		remoteConfig.appDeactivated = true

		remoteConfigSpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		remoteConfigSpy.stubbedStoredConfiguration = remoteConfig

		cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		cryptoLibUtilitySpy.stubbedIsInitialized = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.actionRequired(remoteConfig)
		expect(self.sut.alert).to(beNil())
		expect(self.cryptoLibUtilitySpy.invokedIsInitializedGetter) == false
		expect(self.walletSpy.invokedExpireEventGroups).toEventually(beTrue())
	}

	func test_checkForJailBreak_broken_shouldWarn() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == false
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.jailbrokenTitle()
		expect(self.sut.alert?.subTitle) == L.jailbrokenMessage()
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == true
	}

	func test_checkForJailBreak_broken_shouldnotwarn() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		userSettingsSpy.stubbedJailbreakWarningShown = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
	}

	func test_checkForJailBreak_broken_shouldWarn_butIsVerifier() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
		expect(self.deviceAuthenticationSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_userDismissedJailBreakWarning() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = true
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// When
		sut.userDismissedJailBreakWarning()

		// Then
		expect(self.userSettingsSpy.invokedJailbreakWarningShownSetter) == true
		expect(self.userSettingsSpy.invokedJailbreakWarningShown) == true
	}

	func test_checkForDeviceAuthentication_noPolicy_shouldWarn() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = false
		userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == false
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.holderDeviceAuthenticationWarningTitle()
		expect(self.sut.alert?.subTitle) == L.holderDeviceAuthenticationWarningMessage()
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == true
		expect(self.deviceAuthenticationSpy.invokedHasAuthenticationPolicy) == true
	}

	func test_checkForDeviceAuthentication_noPolicy_jailbroken_broken() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = false
		userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == false
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.jailbrokenTitle()
		expect(self.sut.alert?.subTitle) == L.jailbrokenMessage()
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == true
		expect(self.deviceAuthenticationSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_checkForDeviceAuthentication_noPolicy_shouldWarn_butVerifier() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = false
		userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
		expect(self.deviceAuthenticationSpy.invokedHasAuthenticationPolicy) == false
		expect(self.deviceAuthenticationSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_checkForDeviceAuthentication_noPolicy_shouldNotWarn() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = false
		userSettingsSpy.stubbedDeviceAuthenticationWarningShown = true
		userSettingsSpy.stubbedJailbreakWarningShown = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.remoteConfigSpy.invokedUpdate) == true
		expect(self.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.jailBreakProtocolSpy.invokedIsJailBroken) == false
		expect(self.deviceAuthenticationSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_userDismissedDeviceAuthenticationWarning() {

		// Given
		deviceAuthenticationSpy.stubbedHasAuthenticationPolicyResult = false
		userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = false
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		// When
		sut.userDismissedDeviceAuthenticationWarning()

		// Then
		expect(self.userSettingsSpy.invokedDeviceAuthenticationWarningShownSetter) == true
		expect(self.userSettingsSpy.invokedDeviceAuthenticationWarningShown) == true
	}
}
