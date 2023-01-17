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

final class MakeTestAppointmentViewModelTests: XCTestCase {
	
	var sut: MakeTestAppointmentViewModel!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = MakeTestAppointmentViewModel(
			coordinator: coordinatorDelegateSpy,
			title: "Here is a title",
			message: "Here is a message",
			buttonTitle: "Make an appointment"
		)
	}
	
	func test_onTap_shouldInvokeAppointmentUrl() {
		// Given
		let expectedUrl = URL(string: L.holderUrlAppointment())
		
		// When
		sut.onTap()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedOpenUrl) == true
		expect(self.coordinatorDelegateSpy.invokedOpenUrlParameters?.url) == expectedUrl
	}
}
