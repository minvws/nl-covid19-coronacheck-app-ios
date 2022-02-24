/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class RemoteEventStartViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: RemoteEventStartViewModel!

	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var remoteConfigManagingSpy: RemoteConfigManagingSpy!
	private let remoteConfig = RemoteConfiguration.default

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		sut = RemoteEventStartViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
	}

	func test_content_vaccinationMode() {

		// Then
		expect(self.sut.title) == L.holderVaccinationStartTitle()
		expect(self.sut.message) == L.holderVaccinationStartMessage()
		expect(self.sut.primaryButtonIcon) == I.digid()
	}

	func test_content_recoveryMode() {

		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)

		// Then
		expect(self.sut.title) == L.holderRecoveryStartTitle()
		expect(self.sut.message) == L.holderRecoveryStartMessage()
		expect(self.sut.primaryButtonIcon) == I.digid()
	}
	
	func test_content_vaccinationAndPositiveTestMode() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .vaccinationAndPositiveTest)
		
		// Then
		expect(self.sut.title) == ""
		expect(self.sut.message) == ""
		expect(self.sut.primaryButtonIcon).to(beNil())
	}
	
	func test_content_paperflowMode() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .paperflow)
		
		// Then
		expect(self.sut.title) == ""
		expect(self.sut.message) == ""
		expect(self.sut.primaryButtonIcon).to(beNil())
	}
	
	func test_content_vaccinationAssessment() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .vaccinationassessment)
		
		// Then
		expect(self.sut.title) == ""
		expect(self.sut.message) == ""
		expect(self.sut.primaryButtonIcon).to(beNil())
	}
	
	func test_content_negativeTestMode() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .test)

		// Then
		expect(self.sut.title) == L.holder_negativetest_ggd_title()
		expect(self.sut.message) == L.holder_negativetest_ggd_message()
		expect(self.sut.primaryButtonIcon) == I.digid()
	}

	func test_backButtonTapped() {

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .back(eventMode: .test)
	}

	func test_backSwipe() {

		// When
		sut.backSwipe()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .backSwipe
	}

	func test_primaryButtonTapped_vaccinationMode() {

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .vaccination)
	}

	func test_primaryButtonTapped_vaccinationMode_checkBoxToggled_true() {
		
		// Given
		sut.checkboxToggled(value: true)
		
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .vaccinationAndPositiveTest)
	}
	
	func test_primaryButtonTapped_vaccinationMode_checkBoxToggled_false() {
		
		// Given
		sut.checkboxToggled(value: false)
		
		// When
		sut.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .vaccination)
	}
	
	func test_primaryButtonTapped_recoveryMode() {

		// Given
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .recovery)
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
