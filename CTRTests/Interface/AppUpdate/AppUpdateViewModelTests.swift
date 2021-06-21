/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class AppUpdateViewModelTests: XCTestCase {

	// MARK: Subject under test
	var sut: AppUpdateViewModel!
	var appCoordinatorSpy: AppCoordinatorSpy!

	// MARK: Test lifecycle
	override func setUp() {

		appCoordinatorSpy = AppCoordinatorSpy()
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: "test message",
			storeUrl: URL(string: "https://apple.com"),
			deactivated: nil,
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
		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)
		super.setUp()
	}

	// MARK: Tests

	/// Test the initializer
	func testInitializerWitMessage() {

		// Given

		// When

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.message, "test message")
	}

	/// Test the initializer without a message in the app information.
	func testInitializerWithoutMessage() {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil
		)

		// When
		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.message, .updateAppContent)
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithUrl() {

		// Given

		// When
		sut.actionButtonTapped()

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithoutUrl() {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: "test",
			storeUrl: nil,
			deactivated: nil,
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

		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// When
		sut.actionButtonTapped()

		// Then
		XCTAssertFalse(appCoordinatorSpy.invokedOpenUrl, "Method should NOT be called")
		XCTAssertTrue(sut.showCannotOpenAlert, "We should show an alert")
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeNoInformationUrl() {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil,
			storeUrl: nil,
			deactivated: true,
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

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.message, .endOfLifeDescription)
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeWithInformationUrl() {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil,
			storeUrl: nil,
			deactivated: true,
			informationURL: URL(string: "https://apple.com"),
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

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.errorMessage, .endOfLifeErrorMessage)
	}

	func test_noInternet() {

		// Given

		// When
		sut = InternetRequiredViewModel(coordinator: appCoordinatorSpy)

		// Then
		expect(self.sut.title) == .internetRequiredTitle
		expect(self.sut.message) == .internetRequiredText
		expect(self.sut.actionTitle) == .internetRequiredButton
		expect(self.sut.image) == .noInternet
	}

	func test_noInternet_actionButtonTapped() {

		// Given
		sut = InternetRequiredViewModel(coordinator: appCoordinatorSpy)

		// When
		sut.actionButtonTapped()

		// Then
		expect(self.appCoordinatorSpy.invokedRetry) == true
	}
}
