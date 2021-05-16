/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class VaccinationStartViewModelTests: XCTestCase {

	/// Subject under test
	var sut: VaccinationStartViewModel!

	var coordinatorSpy: VaccinationCoordinatorDelegateSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = VaccinationCoordinatorDelegateSpy()
		sut = VaccinationStartViewModel(coordinator: coordinatorSpy)
	}

	func test_backButtonTapped() {

		// Given

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinishParameters?.0) == .stop
	}

	func test_primaryButtonTapped() {

		// Given

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinishParameters?.0) == .continue
	}
}
