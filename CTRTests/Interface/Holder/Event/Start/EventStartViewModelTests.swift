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
	private var remoteConfigManagingSpy: RemoteConfigManagingSpy!
	private let remoteConfig = RemoteConfiguration.default

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		sut = EventStartViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			validAfterDays: 11
		)
	}

	func test_content_vaccinationMode() {

		// Given

		// When

		// Then
		expect(self.sut.title) == L.holderVaccinationStartTitle()
		expect(self.sut.message) == L.holderVaccinationStartMessage()
	}

	func test_content_recoveryMode() {

		// Given
		sut = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery, validAfterDays: 11)
		// When

		// Then
		expect(self.sut.title) == L.holderRecoveryStartTitle()
		expect(self.sut.message) == L.holderRecoveryStartMessage("11")
	}

	func test_backButtonTapped() {

		// Given

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .back(eventMode: .test)
	}

	func test_primaryButtonTapped_vaccinationMode() {

		// Given

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(value: nil, eventMode: .vaccination)
	}

	func test_primaryButtonTapped_recoveryMode() {

		// Given
		sut = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery, validAfterDays: 11)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(value: nil, eventMode: .recovery)
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
