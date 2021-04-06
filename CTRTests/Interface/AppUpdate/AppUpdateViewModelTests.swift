/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class AppUpdateViewModelTests: XCTestCase {

	// MARK: Subject under test
	var sut: AppUpdateViewModel?

	/// Spies
	var appCoordinatorSpy = AppCoordinatorSpy()

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
			maxValidityHours: 48
		)
		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)
		super.setUp()
	}

	// MARK: Tests

	/// Test the initializer
	func testInitializerWitMessage() throws {

		// Given

		// When

		// Then
		let strongSut = try XCTUnwrap(sut)

		XCTAssertFalse(strongSut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(strongSut.message, "test message")
	}

	/// Test the initializer without a message in the app information.
	func testInitializerWithoutMessage() throws {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil,
			storeUrl: nil,
			deactivated: nil,
			informationURL: nil,
			configTTL: 3600,
			maxValidityHours: 48
		)

		// When
		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(strongSut.message, .updateAppContent)
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithUrl() throws {

		// Given

		// When
		sut?.actionButtonTapped()

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.showCannotOpenAlert, "We should not show an alert")
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithoutUrl() throws {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: "test",
			storeUrl: nil,
			deactivated: nil,
			informationURL: nil,
			configTTL: 3600,
			maxValidityHours: 48
		)

		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// When
		sut?.actionButtonTapped()

		// Then
		XCTAssertFalse(appCoordinatorSpy.openUrlCalled, "Method should NOT be called")
		let strongSut = try XCTUnwrap(sut)
		XCTAssertTrue(strongSut.showCannotOpenAlert, "We should show an alert")
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeNoUrl() throws {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil,
			storeUrl: nil,
			deactivated: true,
			informationURL: nil,
			configTTL: 3600,
			maxValidityHours: 48
		)

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(strongSut.message, .endOfLifeDescription)
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeWithUrl() throws {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil,
			storeUrl: nil,
			deactivated: true,
			informationURL: URL(string: "https://apple.com"),
			configTTL: 3600,
			maxValidityHours: 48
		)

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertFalse(strongSut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(strongSut.errorMessage, .endOfLifeErrorMessage)
	}
}
