/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

// swiftlint:disable type_name
final class IdentitySelectionDetailsViewControllerTests: XCTestCase {
	
	var sut: IdentitySelectionDetailsViewController!
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		sut = IdentitySelectionDetailsViewController(
			viewModel: IdentitySelectionDetailsViewModel(
				identitySelectionDetails:
					IdentitySelectionDetails(
						name: "Test",
						details: [
							["Vaccination", "Fetched from GGD", "Today"],
							["Negative Test", "Fetched from TEST BOER BV", "Yesterday"]
						]
					)
			)
		)
		window = UIWindow()
	}
	
	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_snapshot() {
		
		loadView()
		sut.assertImage()
	}
}
