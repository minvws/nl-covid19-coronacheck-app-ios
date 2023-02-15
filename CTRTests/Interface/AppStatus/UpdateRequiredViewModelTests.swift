/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Shared
@testable import Resources

class UpdateRequiredViewModelTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: UpdateRequiredViewModel!
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
		sut = UpdateRequiredViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .holder)
		
		// Then
		expect(self.sut.alert.value) == nil
		expect(self.sut.title.value) == L.holder_updateApp_title()
		expect(self.sut.message.value) == L.holder_updateApp_content()
		expect(self.sut.actionTitle.value) == L.holder_updateApp_button()
		expect(self.sut.image.value) == I.updateRequired()
	}
	
	/// Test the initializer
	func test_verifier_initializer() throws {
		
		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = UpdateRequiredViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .verifier)
		
		// Then
		expect(self.sut.alert.value) == nil
		expect(self.sut.title.value) == L.verifier_updateApp_title()
		expect(self.sut.message.value) == L.verifier_updateApp_content()
		expect(self.sut.actionTitle.value) == L.verifier_updateApp_button()
		expect(self.sut.image.value) == I.updateRequired()
	}
	
	/// Test the update button tapped method with an url
	func test_actionButtonTapped() throws {
		
		// Given
		let appStoreURL = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = UpdateRequiredViewModel(coordinator: appCoordinatorSpy, appStoreUrl: appStoreURL, flavor: .holder)
		
		// When
		sut.actionButtonTapped()
		
		// Then
		expect(self.appCoordinatorSpy.invokedOpenUrl) == true
		expect(self.sut.alert.value) == nil
	}
	
	/// Test the update button tapped method with an url
	func test_actionButtonTapped_noAppStoreUrl() {
		
		// Given
		sut = UpdateRequiredViewModel(coordinator: appCoordinatorSpy, appStoreUrl: nil, flavor: .holder)
		
		// When
		sut.actionButtonTapped()
		
		// Then
		expect(self.appCoordinatorSpy.invokedOpenUrl) == false
		expect(self.sut.alert.value) != nil
	}
}
