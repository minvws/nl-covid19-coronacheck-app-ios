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
import TestingShared

final class MakeTestAppointmentViewControllerTests: XCTestCase {
	
	var sut: MakeTestAppointmentViewController!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = MakeTestAppointmentViewController(
			viewModel: MakeTestAppointmentViewModel(
				coordinator: coordinatorDelegateSpy,
				title: "Here is a title",
				message: "Here is a message",
				buttonTitle: "Make an appointment"
			)
		)
		sut.view.frame = CGRect(
			origin: .zero,
			size: CGSize(
				width: UIScreen.main.bounds.width,
				height: 250
			)
		)
	}
	
	func test_snapshot() {
		
		sut.assertImage()
	}
}
