/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class AppStatusViewModelTests: XCTestCase {

	// MARK: Subject under test
	var sut: AppStatusViewModel!
	var appCoordinatorSpy: AppCoordinatorSpy!

	// MARK: Test lifecycle
	
	override func setUpWithError() throws {

		appCoordinatorSpy = AppCoordinatorSpy()
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = AppStatusViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL)
		try super.setUpWithError()
	}

	// MARK: Tests

	/// Test the initializer
	func testInitializer() {

		// Given

		// When

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.message) == L.updateAppContent()
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithUrl() {

		// Given

		// When
		sut.actionButtonTapped()

		// Then
		expect(self.sut.showCannotOpenAlert) == false
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithoutUrl() {

		// Given
		sut = AppStatusViewModel(coordinator: appCoordinatorSpy, appStoreUrl: nil)

		// When
		sut.actionButtonTapped()

		// Then
		expect(self.appCoordinatorSpy.invokedOpenUrl) == false
		expect(self.sut.showCannotOpenAlert) == true
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeNoInformationUrl() {

		// Given

		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, appStoreUrl: nil)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.message) == L.endOfLifeDescription()
	}

	/// Test the initializer for end of life
	func testInitializerEndOfLifeWithInformationUrl() throws {

		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = EndOfLifeViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.errorMessage) == L.endOfLifeErrorMessage()
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
