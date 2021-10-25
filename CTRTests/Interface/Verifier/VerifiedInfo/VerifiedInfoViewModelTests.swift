/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

final class VerifiedInfoViewModelTests: XCTestCase {
	
	var sut: VerifiedInfoViewModel!
	var coordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		sut = VerifiedInfoViewModel(
			coordinator: coordinatorDelegateSpy,
			isDeepLinkEnabled: true
		)
	}
	
	func test_onTap_shouldInvokeAppointmentUrl() {
		// When
		sut.onTap()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedDismiss) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToLaunchThirdPartyScannerApp) == true
	}
}
