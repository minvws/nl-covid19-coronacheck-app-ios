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
	
	override func setUp() {

		super.setUp()
		appCoordinatorSpy = AppCoordinatorSpy()
	}

	// MARK: Tests

	/// Test the initializer
	func test_holder_initializer() throws {

		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))

		// When
		sut = AppStatusViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .holder)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.message) == L.holder_updateApp_content()
	}
	
	/// Test the initializer
	func test_verifier_initializer() throws {

		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = AppStatusViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .verifier)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.message) == L.verifier_updateApp_content()
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithUrl() throws {

		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = AppStatusViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .holder)

		// When
		sut.actionButtonTapped()

		// Then
		expect(self.sut.showCannotOpenAlert) == false
	}

	/// Test the update button tapped method with an url
	func testUpdateButtonTappedWithoutUrl() {

		// Given
		sut = AppStatusViewModel(coordinator: appCoordinatorSpy, appStoreUrl: nil, flavor: .holder)

		// When
		sut.actionButtonTapped()

		// Then
		expect(self.appCoordinatorSpy.invokedOpenUrl) == false
		expect(self.sut.showCannotOpenAlert) == true
	}

	/// Test the initializer for end of life
	func test_holder_initializerEndOfLifeNoInformationUrl() {

		// Given

		// When
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, appStoreUrl: nil, flavor: .holder)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.message) == L.holder_endOfLife_description()
	}
	
	/// Test the initializer for end of life
	func test_verifier_initializerEndOfLifeNoInformationUrl() {

		// Given

		// When
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, appStoreUrl: nil, flavor: .verifier)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.message) == L.verifier_endOfLife_description()
	}

	/// Test the initializer for end of life
	func test_holder_initializerEndOfLifeWithInformationUrl() throws {

		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .holder)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.errorMessage) == L.holder_endOfLife_errorMessage()
	}
	
	/// Test the initializer for end of life
	func test_verifier_initializerEndOfLifeWithInformationUrl() throws {

		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .verifier)

		// Then
		expect(self.sut.showCannotOpenAlert) == false
		expect(self.sut.errorMessage) == L.verifier_endOfLife_errorMessage()
	}

	func test_noInternet() {

		// Given

		// When
		sut = InternetRequiredViewModel(coordinator: appCoordinatorSpy, flavor: .holder)

		// Then
		expect(self.sut.title) == L.internetRequiredTitle()
		expect(self.sut.message) == L.internetRequiredText()
		expect(self.sut.actionTitle) == L.internetRequiredButton()
		expect(self.sut.image) == I.noInternet()
	}

	func test_noInternet_actionButtonTapped() {

		// Given
		sut = InternetRequiredViewModel(coordinator: appCoordinatorSpy, flavor: .holder)

		// When
		sut.actionButtonTapped()

		// Then
		expect(self.appCoordinatorSpy.invokedRetry) == true
	}
}
