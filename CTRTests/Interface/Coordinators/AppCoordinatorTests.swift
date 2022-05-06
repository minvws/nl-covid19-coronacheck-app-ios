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
import ViewControllerPresentationSpy

class AppCoordinatorTests: XCTestCase {

	var sut: AppCoordinator!

	var navigationSpy: NavigationControllerSpy!

	var window = UIWindow()
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = true
		navigationSpy = NavigationControllerSpy()
		sut = AppCoordinator(
			navigationController: navigationSpy
		)
	}

	// MARK: - Tests
	
	func test_start() {
		
		// Given
		sut.flavor = .holder
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.invokedSetViewController) == true
	}

	func test_holder_handleLaunchState_finished() {

		// Given
		let state = LaunchState.finished
		sut.flavor = .holder

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}

	func test_verifier_handleLaunchState_finished() {

		// Given
		let state = LaunchState.finished
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is VerifierCoordinator) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}

	func test_holder_handleLaunchState_withinTTL() {

		// Given
		let state = LaunchState.withinTTL
		sut.flavor = .holder

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}

	func test_verifier_handleLaunchState_withinTTL() {

		// Given
		let state = LaunchState.withinTTL
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is VerifierCoordinator) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}

	func test_handleLaunchState_serverError() {

		// Given
		let state = LaunchState.serverError([ServerError.error(statusCode: 500, response: nil, error: .serverError)])
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == false
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == false
	}

	func test_handleLaunchState_withinTTL_cryptoLibNotInitialized() {

		// Given
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = false
		let alertVerifier = AlertVerifier()
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		alertVerifier.verify(
			title: L.generalErrorCryptolibTitle(),
			message: L.generalErrorCryptolibMessage("i 020 000 057"),
			animated: true,
			actions: [
				.cancel(L.generalErrorCryptolibRetry())
			]
		)
	}
	
	func test_handleLaunchState_finished_cryptoLibNotInitialized() {
		
		// Given
		environmentSpies.cryptoLibUtilitySpy.stubbedIsInitialized = false
		let alertVerifier = AlertVerifier()
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		
		// When
		sut.handleLaunchState(.finished)
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		alertVerifier.verify(
			title: L.generalErrorCryptolibTitle(),
			message: L.generalErrorCryptolibMessage("i 020 000 057"),
			animated: true,
			actions: [
				.cancel(L.generalErrorCryptolibRetry())
			]
		)
	}

	func test_handleLaunchState_withinTTL_endOfLife() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = true
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}
	
	func test_handleLaunchState_finished_endOfLife() {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = true
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		
		// When
		sut.handleLaunchState(.finished)
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}
	
	func test_handleLaunchState_withinTTL_updateRequired() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}
	
	func test_handleLaunchState_withinTTL_updateRequired_endOfLife() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = true
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		
		// When
		sut.handleLaunchState(.withinTTL)
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}
	
	func test_handleLaunchState_finished_updateRequired() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(.finished)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}
	
	func test_handleLaunchState_finished_updateRequired_endOfLife() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = true
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		
		// When
		sut.handleLaunchState(.finished)
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppStatusViewController) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
	}

	func test_handleLaunchState_finished_holder_updateRecommended() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))

		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastSeenRecommendedUpdate = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .holder

		// When
		sut.handleLaunchState(.finished)

		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
		expect(self.environmentSpies.userSettingsSpy.invokedLastSeenRecommendedUpdateSetter) == true
	}
	
	func test_handleLaunchState_withinTTL_holder_updateRecommended() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastSeenRecommendedUpdate = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .holder
		
		// When
		sut.handleLaunchState(.withinTTL)
		
		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
		expect(self.environmentSpies.userSettingsSpy.invokedLastSeenRecommendedUpdateSetter) == true
	}

	func test_handleLaunchState_verifier_updateRecommended() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "2.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastRecommendUpdateDismissalTimestamp = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
		expect(self.environmentSpies.userSettingsSpy.invokedLastRecommendUpdateDismissalTimestampSetter) == true
	}
	
	func test_handleLaunchState_holder_updateRecommended_alreadySeen() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.1.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastSeenRecommendedUpdate = "1.1.0"
		sut.flavor = .holder
		
		// When
		sut.handleLaunchState(.withinTTL)
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
	}
	
	func test_handleLaunchState_holder_updateRecommended_minor_version() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.1.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastSeenRecommendedUpdate = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .holder
		
		// When
		sut.handleLaunchState(.withinTTL)
		
		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
	}

	func test_handleLaunchState_verifier_updateRecommended_minor_version() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.1.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.lastRecommendUpdateDismissalTimestamp = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
	}

	func test_handleLaunchState_holder_updateRecommended_bug_version() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.1"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastSeenRecommendedUpdate = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .holder

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
	}

	func test_handleLaunchState_verifier_updateRecommended_bug_version() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.1"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.lastRecommendUpdateDismissalTimestamp = nil
		let alertVerifier = AlertVerifier()
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		alertVerifier.verify(
			title: L.recommendedUpdateAppTitle(),
			message: L.recommendedUpdateAppSubtitle(),
			animated: true,
			actions: [
				.cancel(L.recommendedUpdateAppActionCancel()),
				.default(L.recommendedUpdateAppActionOk())
			]
		)
	}

	func test_handleLaunchState_holder_updateRecommended_currentVersionEqualToRecommendedVersion() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.1"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.1")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.stubbedLastSeenRecommendedUpdate = nil
		sut.flavor = .holder

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
	}

	func test_handleLaunchState_verifier_updateRecommended_currentVersionEqualToRecommendedVersion() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.1"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.1")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.lastRecommendUpdateDismissalTimestamp = nil
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is VerifierCoordinator) == true
	}

	func test_handleLaunchState_holder_updateRecommended_currentVersionHigherToRecommendedVersion() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.1"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.2")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.lastRecommendUpdateDismissalTimestamp = nil
		sut.flavor = .holder

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
	}

	func test_handleLaunchState_verifier_updateRecommended_currentVersionHigherToRecommendedVersion() throws {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appDeactivated = false
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.minimumVersion = "1.0.0"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.1"
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.2")
		sut.launchStateManager.versionSupplier = sut.versionSupplier
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		environmentSpies.userSettingsSpy.lastRecommendUpdateDismissalTimestamp = nil
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(.withinTTL)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is VerifierCoordinator) == true
	}
	
	func test_startAsHolder() {
		
		// Given
		sut.flavor = .holder
		
		// When
		sut.applicationShouldStart()
		
		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.last is HolderCoordinator) == true
	}
	
	func test_startAsHolder_withExistingChildCoordinator() {
		
		// Given
		sut.flavor = .holder
		sut.childCoordinators = [HolderCoordinator(navigationController: sut.navigationController, window: sut.window)]
		
		// When
		sut.applicationShouldStart()
		
		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.last is HolderCoordinator) == true
	}
	
	func test_startAsVerifier() {
		
		// Given
		sut.flavor = .verifier
		
		// When
		sut.applicationShouldStart()
		
		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.last is VerifierCoordinator) == true
	}
	
	func test_startAsVerifier_withExistingChildCoordinator() {
		
		// Given
		sut.flavor = .verifier
		sut.childCoordinators = [VerifierCoordinator(navigationController: sut.navigationController, window: sut.window)]
		
		// When
		sut.applicationShouldStart()
		
		// Then
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedRegisterTriggers) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedRegisterTriggers) == true
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.last is VerifierCoordinator) == true
	}
	
	func test_retry() {
		
		// Given
		let launchStateManagerSpy = LaunchStateManagerSpy()
		sut.launchStateManager = launchStateManagerSpy
		
		// When
		sut.retry()
		
		// Then
		expect(launchStateManagerSpy.invokedEnableRestart) == true
		expect(self.navigationSpy.viewControllers.last is LaunchViewController) == true
	}
	
	func test_reset() {
		
		// Given
		let launchStateManagerSpy = LaunchStateManagerSpy()
		sut.launchStateManager = launchStateManagerSpy
		
		// When
		sut.reset()
		
		// Then
		expect(launchStateManagerSpy.invokedEnableRestart) == true
		expect(self.navigationSpy.viewControllers.last is LaunchViewController) == true
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_redeemVaccinationAssessment() {
		
		// Given
		let universalLink = UniversalLink.redeemVaccinationAssessment(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_thirdPartyTicketApp() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyTicketApp(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_tvsAuth() {
		
		// Given
		let universalLink = UniversalLink.tvsAuth(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
	
	func test_consume_thirdPartyScannerApp() {
		
		// Given
		let universalLink = UniversalLink.thirdPartyScannerApp(returnURL: URL(string: "https://coronacheck.nl"))
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == true
		expect(self.sut.unhandledUniversalLink) == universalLink
	}
}
