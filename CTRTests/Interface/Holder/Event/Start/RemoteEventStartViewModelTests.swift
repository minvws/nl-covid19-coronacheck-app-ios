/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
@testable import Transport
@testable import Shared
import XCTest
import Nimble
@testable import Managers
@testable import Resources

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
		expect(self.sut.title) == L.holder_addVaccination_title()
		expect(self.sut.message) == L.holder_addVaccination_message()
		expect(self.sut.combineVaccinationAndPositiveTest) == L.holder_addVaccination_alsoCollectPositiveTestResults_message()
		expect(self.sut.primaryButtonIcon) == I.digid()
	}

	func test_content_recoveryMode() {

		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)

		// Then
		expect(self.sut.title) == L.holderRecoveryStartTitle()
		expect(self.sut.message) == L.holderRecoveryStartMessage()
		expect(self.sut.combineVaccinationAndPositiveTest) == nil
		expect(self.sut.primaryButtonIcon) == I.digid()
	}
	
	func test_content_vaccinationAndPositiveTestMode() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .vaccinationAndPositiveTest)
		
		// Then
		expect(self.sut.title) == nil
		expect(self.sut.message) == nil
		expect(self.sut.combineVaccinationAndPositiveTest) == nil
		expect(self.sut.primaryButtonIcon) == nil
	}
	
	func test_content_paperflowMode() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .paperflow)
		
		// Then
		expect(self.sut.title) == nil
		expect(self.sut.message) == nil
		expect(self.sut.combineVaccinationAndPositiveTest) == nil
		expect(self.sut.primaryButtonIcon) == nil
	}
	
	func test_content_negativeTestMode() {
		
		// When
		sut = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .test(.ggd))

		// Then
		expect(self.sut.title) == L.holder_negativetest_ggd_title()
		expect(self.sut.message) == L.holder_negativetest_ggd_message()
		expect(self.sut.combineVaccinationAndPositiveTest) == nil
		expect(self.sut.primaryButtonIcon) == I.digid()
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
	
	func test_secondaryButtonTappedcheckBoxToggled_false() {

		// Given
		sut.checkboxToggled(value: false)

		// When
		sut.secondaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .alternativeRoute(eventMode: .vaccination)
	}
	
	func test_secondaryButtonTappedcheckBoxToggled_true() {

		// Given
		sut.checkboxToggled(value: true)

		// When
		sut.secondaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .alternativeRoute(eventMode: .vaccinationAndPositiveTest)
	}
	
}
