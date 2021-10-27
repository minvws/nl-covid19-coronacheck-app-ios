/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import ViewControllerPresentationSpy

class AppCoordinatorTests: XCTestCase {

	var sut: AppCoordinator!

	var navigationSpy: NavigationControllerSpy!

	var window = UIWindow()

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		sut = AppCoordinator(
			navigationController: navigationSpy
		)
	}

	// MARK: - Tests

	func test_holder_handleLaunchState_noActionNeeded() {

		// Given
		let state = LaunchState.noActionNeeded
		sut.flavor = .holder

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
	}

	func test_verifier_handleLaunchState_noActionNeeded() {

		// Given
		let state = LaunchState.noActionNeeded
		sut.flavor = .verifier

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is VerifierCoordinator) == true
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
	}

	func test_handleLaunchState_internetRequired() {

		// Given
		let state = LaunchState.internetRequired

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
	}

	func test_handleLaunchState_cryptoLibNotInitialized() {

		// Given
		let state = LaunchState.cryptoLibNotInitialized
		let alertVerifier = AlertVerifier()
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(state)

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

	func test_handleLaunchState_endOfLife() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = true
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(state)

		// Then
		expect(config.isDeactivated) == true
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppUpdateViewController) == true
	}

	func test_handleLaunchState_updateRequired() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = false
		config.minimumVersion = "2.0.0"
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(viewControllerSpy.presentCalled) == true
		expect(viewControllerSpy.thePresentedViewController is AppUpdateViewController) == true
	}

	func test_handleLaunchState_updateRecommended() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = false
		config.minimumVersion = "1.0.0"
		config.recommendedVersion = "2.0.0"
		config.appStoreURL = URL(string: "https://coronacheck.nl")
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		let userSettingSpy = UserSettingsSpy()
		sut.userSettings = userSettingSpy
		userSettingSpy.lastRecommendUpdateDismissalTimestamp = nil
		let alertVerifier = AlertVerifier()

		// When
		sut.handleLaunchState(state)

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

	func test_handleLaunchState_updateRecommended_minor_version() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = false
		config.minimumVersion = "1.0.0"
		config.recommendedVersion = "1.1.0"
		config.appStoreURL = URL(string: "https://coronacheck.nl")
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		let userSettingSpy = UserSettingsSpy()
		sut.userSettings = userSettingSpy
		userSettingSpy.lastRecommendUpdateDismissalTimestamp = nil
		let alertVerifier = AlertVerifier()

		// When
		sut.handleLaunchState(state)

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

	func test_handleLaunchState_updateRecommended_bug_version() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = false
		config.minimumVersion = "1.0.0"
		config.recommendedVersion = "1.0.1"
		config.appStoreURL = URL(string: "https://coronacheck.nl")
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.0")
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		let userSettingSpy = UserSettingsSpy()
		sut.userSettings = userSettingSpy
		userSettingSpy.lastRecommendUpdateDismissalTimestamp = nil
		let alertVerifier = AlertVerifier()

		// When
		sut.handleLaunchState(state)

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

	func test_handleLaunchState_updateRecommended_currentVersionEqualToRecommendedVersion() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = false
		config.minimumVersion = "1.0.0"
		config.recommendedVersion = "1.0.1"
		config.appStoreURL = URL(string: "https://coronacheck.nl")
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.1")
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		let userSettingSpy = UserSettingsSpy()
		sut.userSettings = userSettingSpy
		userSettingSpy.lastRecommendUpdateDismissalTimestamp = nil
		sut.flavor = .holder

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
	}

	func test_handleLaunchState_updateRecommended_currentVersionHigherToRecommendedVersion() {

		// Given
		var config = RemoteConfiguration.default
		config.appDeactivated = false
		config.minimumVersion = "1.0.0"
		config.recommendedVersion = "1.0.1"
		config.appStoreURL = URL(string: "https://coronacheck.nl")
		sut.versionSupplier = AppVersionSupplierSpy(version: "1.0.2")
		let state = LaunchState.actionRequired(config)
		let viewControllerSpy = ViewControllerSpy()
		sut.window.rootViewController = viewControllerSpy
		let userSettingSpy = UserSettingsSpy()
		sut.userSettings = userSettingSpy
		userSettingSpy.lastRecommendUpdateDismissalTimestamp = nil
		sut.flavor = .holder

		// When
		sut.handleLaunchState(state)

		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first is HolderCoordinator) == true
	}
}
