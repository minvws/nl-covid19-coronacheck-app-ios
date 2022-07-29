/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble

class AppDeactivatedViewModelTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: AppStatusViewModel!
	var appCoordinatorSpy: AppCoordinatorSpy!
	
	// MARK: Test lifecycle
	
	override func setUp() {
		
		super.setUp()
		appCoordinatorSpy = AppCoordinatorSpy()
	}
	
	// MARK: Tests
	
	/// Test the initializer for end of life
	func test_holder_initializer() throws {
		
		// Given
		let informationUrl = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, informationUrl: informationUrl, flavor: .holder)
		
		// Then
		expect(self.sut.alert.value) == nil
		expect(self.sut.title.value) == L.holder_endOfLife_title()
		expect(self.sut.message.value) == L.holder_endOfLife_description()
		expect(self.sut.actionTitle.value) == L.holder_endOfLife_button()
		expect(self.sut.image.value) == I.endOfLife()
	}
	
	/// Test the initializer for end of life
	func test_verifier_initializer() throws {
		
		// Given
		let informationUrl = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, informationUrl: informationUrl, flavor: .verifier)
		
		// Then
		expect(self.sut.alert.value) == nil
		expect(self.sut.title.value) == L.verifier_endOfLife_title()
		expect(self.sut.message.value) == L.verifier_endOfLife_description()
		expect(self.sut.actionTitle.value) == L.verifier_endOfLife_button()
		expect(self.sut.image.value) == I.endOfLife()
	}
	
	/// Test the initializer for end of life
	func test_actionButtonTapped() throws {
		
		// Given
		let informationUrl = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, informationUrl: informationUrl, flavor: .holder)
		
		// When
		sut.actionButtonTapped()
		
		// Then
		expect(self.appCoordinatorSpy.invokedOpenUrl) == true
		expect(self.sut.alert.value) == nil
	}
	
	func test_actionButtonTapped_noInformationUrl() throws {
		
		// Given
		sut = AppDeactivatedViewModel(coordinator: appCoordinatorSpy, informationUrl: nil, flavor: .holder)
		
		// When
		sut.actionButtonTapped()
		
		// Then
		expect(self.appCoordinatorSpy.invokedOpenUrl) == false
		expect(self.sut.alert.value) != nil
	}
}
