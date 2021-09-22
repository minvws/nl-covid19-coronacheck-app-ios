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
		var appVersionInfo = RemoteConfiguration.default
		appVersionInfo.appStoreURL = URL(string: "https://apple.com")

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
		XCTAssertEqual(sut.message, "Je hebt de laatste versie van de app nodig om verder te gaan.")
	}

	/// Test the initializer without a message in the app information.
	func testInitializerWithoutMessage() {

		// Given
		let appVersionInfo = RemoteConfiguration.default

		// When
		sut = AppUpdateViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.message, L.updateAppContent())
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
		let appVersionInfo = RemoteConfiguration.default

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
		let appVersionInfo = RemoteConfiguration.default

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.message, L.endOfLifeDescription())
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeWithInformationUrl() {

		// Given
		let appVersionInfo = RemoteConfiguration.default

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, versionInformation: appVersionInfo)

		// Then
		XCTAssertFalse(sut.showCannotOpenAlert, "We should not show an alert")
		XCTAssertEqual(sut.errorMessage, L.endOfLifeErrorMessage())
	}

	func test_noInternet() {

		// Given

		// When
		sut = InternetRequiredViewModel(coordinator: appCoordinatorSpy)

		// Then
		expect(self.sut.title) == L.internetRequiredTitle()
		expect(self.sut.message) == L.internetRequiredText()
		expect(self.sut.actionTitle) == L.internetRequiredButton()
		expect(self.sut.image) == I.noInternet()
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
