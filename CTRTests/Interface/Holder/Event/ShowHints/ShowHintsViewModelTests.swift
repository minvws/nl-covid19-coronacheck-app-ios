/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Nimble
import XCTest
import SnapshotTesting

@testable import CTR

class ShowHintsViewModelTests: XCTestCase {
	
	var sut: ShowHintsViewModel!
	var coordinatorStub: EventCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		coordinatorStub = EventCoordinatorDelegateSpy()
	}
	
	func test_singlehint_withNonalphanumericCharacters_failsToInitViewModel() {
		
		// Arrange
		let hints = NonemptyArray(["🍕"])!
		
		// Act
		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut).to(beNil())
	}
	
	func test_multipleHints_withANonalphanumericCharacterHint_failsToInitViewModel() {
		
		// Arrange
		let hints = NonemptyArray(["🍕", "domestic_recovery_created"])!
		
		// Act
		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut.message) == "<p>\(L.domestic_recovery_created())</p>"
	}
	
	func test_singlehint_isConvertedToHTMLMessage() {
		
		// Arrange
		let hints = NonemptyArray(["domestic_recovery_created"])!
		
		// Act
		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut.message) == "<p>\(L.domestic_recovery_created())</p>"
		
		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func test_multiplehints_areConvertedToHTMLMessage() {
		
		// Arrange
		let hints = NonemptyArray(["domestic_recovery_created", "domestic_vaccination_created"])!
		
		// Act
		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)

		// Assert
		expect(self.sut.message) == "<p>\(L.domestic_recovery_created())</p>\n<p>\(L.domestic_vaccination_created())</p>"
		
		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func test_standardMode() {
		
		// Arrange
		let hints = NonemptyArray(["domestic_recovery_created"])!
		
		// Act
		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)

		// Assert
		expect(self.sut.title) == L.holder_eventHints_title()
		expect(self.sut.message) == "<p>\(L.domestic_recovery_created())</p>"
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func test_mode_standard() {
		
		// Arrange
		let hints = NonemptyArray(["domestic_recovery_created"])!
		
		// Act
		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_eventHints_title()
		expect(self.sut.message) == "<p>\(L.domestic_recovery_created())</p>"
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop
		
		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	// Disabled until the `negativetest_without_vaccinationasssesment` copy key is added
//	func test_mode_shouldCompleteVaccinationAssessment() {
//
//		// Arrange
//		let hints = NonemptyArray(["negativetest_without_vaccinationasssesment"])!
//
//		// Act
//		sut = ShowHintsViewModel(hints: hints, coordinator: coordinatorStub)
//		sut.userTappedCallToActionButton()
//
//		// Assert
//		expect(self.sut.title) == L.holder_eventHints_title()
//		expect(self.sut.message) == "<p>negativetest_without_vaccinationasssesment</p>"
//		expect(self.sut.buttonTitle) == L.holder_event_negativeTestEndstate_addVaccinationAssessment_button_complete()
//
//		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
//		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .shouldCompleteVaccinationAssessment
//
//		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
//	}
	
	func test_openURL() {
		// Arrange
		sut = ShowHintsViewModel(hints: NonemptyArray(["domestic_recovery_created"])!, coordinator: coordinatorStub)
		let url = URL(fileURLWithPath: "/")
		
		// Act
		sut.openUrl(url)
		
		// Assert
		expect(self.coordinatorStub.invokedOpenUrlCount) == 1
		expect(self.coordinatorStub.invokedOpenUrlParameters?.url) == url
		
		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
}
