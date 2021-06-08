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
	private var sut: VaccinationStartViewModel!

	private var coordinatorSpy: VaccinationCoordinatorDelegateSpy!

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
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinishParameters?.0) == .back(eventMode: .test)
	}

	func test_primaryButtonTapped() {

		// Given

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinishParameters?.0) == .continue(value: nil, eventMode: .vaccination)
	}

	func test_openUrl() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
}
