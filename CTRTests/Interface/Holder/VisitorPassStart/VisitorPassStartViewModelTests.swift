/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

final class VisitorPassStartViewModelTests: XCTestCase {
	
	var sut: VisitorPassStartViewModel!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var remoteConfigSpy: RemoteConfigManagingSpy!
	
	override func setUp() {
		super.setUp()

		remoteConfigSpy = RemoteConfigManagingSpy()
		remoteConfigSpy.stubbedStoredConfiguration = .default
		Services.use(remoteConfigSpy)
		
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = VisitorPassStartViewModel(coordinator: holderCoordinatorDelegateSpy)
	}
	
	override func tearDown() {
		
		super.tearDown()
		Services.revertToDefaults()
	}
	
	func test_content() {
		
		// Given
		
		// When
		
		// Then
		expect(self.sut.title) == L.visitorpass_start_title()
		expect(self.sut.message) == L.visitorpass_start_message()
		expect(self.sut.buttonTitle) == L.visitorpass_start_action()
	}
	
	func test_openURL_shouldCallCoordinator() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))
		
		// When
		sut.openUrl(url)
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_tapOnNavigateToTokenEntry_shouldCallCoordinator() {
		
		// Given

		// When
		sut.navigateToTokenEntry()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAVisitorPass) == true
	}
}
