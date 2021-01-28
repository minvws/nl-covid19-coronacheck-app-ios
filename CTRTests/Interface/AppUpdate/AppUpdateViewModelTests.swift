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
			storeUrl: URL(string: "https://apple.com")
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
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}

		XCTAssertFalse(strongSut.showCannotOpenAppStoreAlert, "We should not show an alert")
		XCTAssertEqual(strongSut.message, "test message")

	}

	/// Test the initializer without a message in the app information.
	func testInitializerWithoutMessage() {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: nil,
			storeUrl: nil
		)

		// When
		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showCannotOpenAppStoreAlert, "We should not show an alert")
		XCTAssertEqual(strongSut.message, .updateAppContent)
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithUrl() {

		// Given

		// When
		sut?.updateButtonTapped()

		// Then
		XCTAssertTrue(appCoordinatorSpy.openUrlCalled, "Method should be called")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertFalse(strongSut.showCannotOpenAppStoreAlert, "We should not show an alert")
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithoutUrl() {

		// Given
		let appVersionInfo = RemoteConfiguration(
			minVersion: "1.0",
			minVersionMessage: "test",
			storeUrl: nil
		)

		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// When
		sut?.updateButtonTapped()

		// Then
		XCTAssertFalse(appCoordinatorSpy.openUrlCalled, "Method should NOT be called")
		guard let strongSut = sut else {
			XCTFail("Can't unwrap sut")
			return
		}
		XCTAssertTrue(strongSut.showCannotOpenAppStoreAlert, "We should show an alert")
	}
}
