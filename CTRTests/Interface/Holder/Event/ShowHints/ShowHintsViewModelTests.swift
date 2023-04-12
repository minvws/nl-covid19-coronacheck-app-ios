/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Nimble
import XCTest
import SnapshotTesting
import Shared
import TestingShared
import Persistence
@testable import Resources

@testable import CTR

class ShowHintsViewModelTests: XCTestCase {
	
	var sut: ShowHintsViewModel!
	var coordinatorStub: EventCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		coordinatorStub = EventCoordinatorDelegateSpy()
	}
	
	func test_singlehint_withNonalphanumericCharacters_failsToInitViewModel() throws {

		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["🍕"]))

		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccination, coordinator: coordinatorStub)

		// Assert
		expect(self.sut) == nil
	}

	func test_multipleHints_withANonalphanumericCharacterHint_failsToInitViewModel() throws {

		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["🍕", "domestic_vaccination_created"]))

		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccination, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}

	func test_openURL() throws {
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Created"]))
		
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccination, coordinator: coordinatorStub)
		let url = URL(fileURLWithPath: "/")

		// Act
		sut.openUrl(url)

		// Assert
		expect(self.coordinatorStub.invokedOpenUrlCount) == 1
		expect(self.coordinatorStub.invokedOpenUrlParameters?.url) == url

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	// Vaccinations with/without positive tests
	
	func testEndstate000() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Created", "International_Vaccination_Created"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccination, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate001() throws { // matches: .internationalQROnly
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Created"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccination, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateInternationalQROnly_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateInternationalQROnly_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate002() throws { // matches: .weCouldntMakeACertificate
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Rejected"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccination, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateCantCreateCertificate_message("vaccinatie", "i 280 000 059")
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate003() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Created", "International_Vaccination_Created", "Vaccination_dose_correction_applied", "Domestic_Recovery_Rejected", "International_Recovery_Rejected"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate004() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap( NonemptyArray(["Domestic_Vaccination_Created", "International_Vaccination_Created", "Vaccination_dose_correction_not_applied", "Domestic_Recovery_Rejected", "International_Recovery_Rejected"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate005() throws { // matches: .vaccinationsAndRecovery
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Created", "International_Vaccination_Created", "Vaccination_dose_correction_applied", "Domestic_Recovery_Created", "International_Recovery_Created"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate006() throws { // matches: .vaccinationsAndRecovery
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Created", "International_Vaccination_Created", "Vaccination_dose_correction_not_applied", "Domestic_Recovery_Created", "International_Recovery_Created"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate007() throws { // matches: .internationalVaccinationAndRecovery
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Created", "Vaccination_dose_correction_not_applied", "Domestic_Recovery_Created", "International_Recovery_Created"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateInternationalVaccinationAndRecovery_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateInternationalVaccinationAndRecovery_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate008() throws { // matches: .internationalQROnly
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Created", "Vaccination_dose_correction_not_applied", "Domestic_Recovery_Rejected", "International_Recovery_Rejected"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateInternationalQROnly_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateInternationalQROnly_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate009() throws { // matches: .recoveryOnly
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Rejected", "Vaccination_dose_correction_not_applied", "Domestic_Recovery_Created", "International_Recovery_Created"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateRecoveryOnly_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateRecoveryOnly_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate010() throws { // matches: .weCouldntMakeACertificate
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Vaccination_Rejected", "International_Vaccination_Rejected", "Vaccination_dose_correction_not_applied", "Domestic_Recovery_Rejected", "International_Recovery_Rejected"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationAndPositiveTest, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateCantCreateCertificate_message("opgehaalde gegevens", "i 880 000 0510")
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}

	// Positive tests only
	func testEndstate011() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Created", "International_Recovery_Created"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate012() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Created", "International_Recovery_Rejected"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate013() throws { // matches: .weCouldntMakeACertificate
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Rejected", "International_Recovery_Rejected"])!)
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateCantCreateCertificate_message("positieve testuitslag", "i 380 000 0511")
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate014() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Created", "International_Recovery_Created", "Vaccination_dose_correction_not_applied"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate015() throws { // matches: .recoveryAndDosisCorrection
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Created", "International_Recovery_Created", "Vaccination_dose_correction_applied"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateRecoveryAndDosisCorrection_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateRecoveryAndDosisCorrection_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate016() throws { // matches: .noRecoveryButDosisCorrection
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Rejected", "International_Recovery_Rejected", "Vaccination_dose_correction_applied"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateNoRecoveryButDosisCorrection_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateNoRecoveryButDosisCorrection_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate017() throws { // matches: .recoveryTooOld
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_Recovery_Rejected", "International_Recovery_Rejected", "International_recovery_too_old"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.recovery, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateRecoveryTooOld_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateRecoveryTooOld_message()
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}

	// Negative tests
	func testEndstate018() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_negativetest_created", "International_negativetest_created"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.test(.ggd), coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate019() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_negativetest_rejected", "International_negativetest_created"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.test(.ggd), coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate021() throws { // matches: .weCouldntMakeACertificate
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_negativetest_rejected", "International_negativetest_rejected"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.test(.ggd), coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateCantCreateCertificate_message("negatieve testuitslag", "i 480 000 0512")
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate021_commercialTest() throws { // matches: .weCouldntMakeACertificate
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_negativetest_rejected", "International_negativetest_rejected"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.test(.commercial), coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateCantCreateCertificate_message("negatieve testuitslag", "i 180 000 0512")
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}
	
	func testEndstate023() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Vaccinationassessment_missing_supporting_negative_test"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationassessment, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate024() throws { // matches: .noEndState
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_vaccinationassessment_created"]))
		
		// Act
		sut = ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationassessment, coordinator: coordinatorStub)
		
		// Assert
		expect(self.sut) == nil
	}
	
	func testEndstate025() throws { // matches: .weCouldntMakeACertificate
		// Arrange
		let hints = try XCTUnwrap(NonemptyArray(["Domestic_vaccinationassessment_rejected"]))
		
		// Act
		sut = try XCTUnwrap(ShowHintsViewModel(hints: hints, eventMode: EventMode.vaccinationassessment, coordinator: coordinatorStub))
		sut.userTappedCallToActionButton()
		
		// Assert
		expect(self.sut.title) == L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
		expect(self.sut.message) == L.holder_listRemoteEvents_endStateCantCreateCertificate_message("vaccinatiebeoordeling", "i 980 000 0513")
		expect(self.sut.buttonTitle) == L.general_toMyOverview()
		
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishCount) == 1
		expect(self.coordinatorStub.invokedShowHintsScreenDidFinishParameters?.result) == .stop

		assertSnapshot(matching: ShowHintsViewController(viewModel: sut), as: .image)
	}

}
