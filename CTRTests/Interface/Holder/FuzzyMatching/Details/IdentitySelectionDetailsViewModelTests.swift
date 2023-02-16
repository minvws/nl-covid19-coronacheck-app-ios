/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
@testable import Resources
import Shared

final class IdentitySelectionDetailsViewModelTests: XCTestCase {

	var sut: IdentitySelectionDetailsViewModel!

	func test_init() {
		
		// Given
		let details = IdentitySelectionDetails(
			name: "Test",
			details: [["Vaccination", "Today"], ["Negative Test", "Yesterday"]]
		)
		
		// When
		sut = IdentitySelectionDetailsViewModel(identitySelectionDetails: details)
		
		// Then
		expect(self.sut.title.value) == L.general_details()
		expect(self.sut.message.value) == L.holder_identitySelection_details_body("Test")
		expect(self.sut.details.value).to(haveCount(2))
		expect(self.sut.details.value.first).to(haveCount(2))
		expect(self.sut.details.value.last).to(haveCount(2))
	}
}
