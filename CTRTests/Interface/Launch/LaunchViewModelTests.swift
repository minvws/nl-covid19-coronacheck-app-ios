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
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")
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

	func test_launchState_finished() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedUpdateCompletionResult = (.success((false, RemoteConfiguration.default)), ())
		environmentSpies.cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.finished
		expect(self.sut.alert).to(beNil())
	}

	func test_launchState_withinTTL() {

		// Given
		environmentSpies.remoteConfigManagerSpy.shouldInvokeUpdateImmediateCallbackIfWithinTTL = true
		environmentSpies.cryptoLibUtilitySpy.shouldInvokeUpdateImmediateCallbackIfWithinTTL = true

		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.withinTTL
		expect(self.sut.alert).to(beNil())
	}

	/// Test internet required for the remote config
	func test_internetRequired_forRemoteConfig() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.success(true), ())
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.serverError(
			[ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)]
		)
		expect(self.sut.alert).to(beNil())
	}

	/// Test internet required for the issuer public keys
	func test_internetRequired_forIssuerPublicKeys() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedUpdateCompletionResult = (.success((false, RemoteConfiguration.default)), ())
		environmentSpies.cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.serverError(
			[ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)]
		)
		expect(self.sut.alert).to(beNil())
	}

	/// Test internet required for the issuer public keys and the remote config
	func test_internetRequired_forBothActions() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.cryptoLibUtilitySpy.stubbedUpdateCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.userSettingsSpy.invokedConfigFetchedTimestampSetter) == false
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState).toEventually(beTrue())
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state) == LaunchState.serverError(
			[ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection),
			 ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)]
		)
		expect(self.sut.alert).to(beNil())
	}

	func test_checkForJailBreak_broken_shouldWarn() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == false
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.jailbrokenTitle()
		expect(self.sut.alert?.subTitle) == L.jailbrokenMessage()
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == true
	}

	func test_checkForJailBreak_broken_shouldnotwarn() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = true
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == false
	}

	func test_checkForJailBreak_broken_shouldWarn_butIsVerifier() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == false
		expect(self.environmentSpies.deviceAuthenticationDetectorSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_userDismissedJailBreakWarning() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// When
		sut.userDismissedJailBreakWarning()

		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedJailbreakWarningShownSetter) == true
		expect(self.environmentSpies.userSettingsSpy.invokedJailbreakWarningShown) == true
	}

	func test_checkForDeviceAuthentication_noPolicy_shouldWarn() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == false
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.holderDeviceAuthenticationWarningTitle()
		expect(self.sut.alert?.subTitle) == L.holderDeviceAuthenticationWarningMessage()
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == true
		expect(self.environmentSpies.deviceAuthenticationDetectorSpy.invokedHasAuthenticationPolicy) == true
	}

	func test_checkForDeviceAuthentication_noPolicy_jailbroken_broken() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == false
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.jailbrokenTitle()
		expect(self.sut.alert?.subTitle) == L.jailbrokenMessage()
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == true
		expect(self.environmentSpies.deviceAuthenticationDetectorSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_checkForDeviceAuthentication_noPolicy_shouldWarn_butVerifier() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == false
		expect(self.environmentSpies.deviceAuthenticationDetectorSpy.invokedHasAuthenticationPolicy) == false
		expect(self.environmentSpies.deviceAuthenticationDetectorSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_checkForDeviceAuthentication_noPolicy_shouldNotWarn() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = true
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = true
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false

		// When
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedUpdate) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedUpdate) == true
		expect(self.appCoordinatorSpy.invokedHandleLaunchState) == false
		expect(self.appCoordinatorSpy.invokedHandleLaunchStateParameters?.state).to(beNil())
		expect(self.sut.alert).to(beNil())
		expect(self.environmentSpies.jailBreakDetectorSpy.invokedIsJailBroken) == false
		expect(self.environmentSpies.deviceAuthenticationDetectorSpy.invokedHasAuthenticationPolicy) == false
	}

	func test_userDismissedDeviceAuthenticationWarning() {

		// Given
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		sut = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// When
		sut.userDismissedDeviceAuthenticationWarning()

		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedDeviceAuthenticationWarningShownSetter) == true
		expect(self.environmentSpies.userSettingsSpy.invokedDeviceAuthenticationWarningShown) == true
	}
}
