/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

class IncompleteDutchVaccinationViewModelTests: XCTestCase {

	var sut: IncompleteDutchVaccinationViewModel!
	var coordinatorSpy: HolderCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorSpy = HolderCoordinatorDelegateSpy()
		sut = IncompleteDutchVaccinationViewModel(coordinatorDelegate: coordinatorSpy)
	}
	
	func testDidTapURLCallsCoordinator() {
		// Arrange
		let url = URL(string: "http://example.com")!
		
		// Act
		sut.userTappedLink(url: url)
		
		// Assert
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url) == url
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.inApp) == true
	}
}
