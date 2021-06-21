/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class EventStartViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: EventStartViewModel!

	private var coordinatorSpy: EventCoordinatorDelegateSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		sut = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .vaccination)
	}

	func test_backButtonTapped() {

		// Given

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .back(eventMode: .test)
	}

	func test_primaryButtonTapped() {

		// Given

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(value: nil, eventMode: .vaccination)
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
