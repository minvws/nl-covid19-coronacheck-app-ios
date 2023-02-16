/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
import Shared
@testable import Resources

final class VisitorPassStartViewModelTests: XCTestCase {
	
	var sut: VisitorPassStartViewModel!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		
		sut = VisitorPassStartViewModel(coordinator: holderCoordinatorDelegateSpy)
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
