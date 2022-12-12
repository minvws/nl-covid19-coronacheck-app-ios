/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
@testable import Transport
@testable import Shared
import XCTest
import Nimble

class EventDetailsGeneratorTest: XCTestCase {

	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func testNegativeTestDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.negativeTestEvent
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testNegativeTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"

		// When
		let details = NegativeTestDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(10))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == "Sneltest (RAT)"
		expect(details[4].value) == "Antigen Test"
		expect(details[5].value) == "donderdag 1 juli 2021 15:42"
		expect(details[6].value) == "negatief (geen coronavirus vastgesteld)"
		expect(details[7].value) == "testNegativeTestGenerator"
		expect(details[8].value) == "GGD XL Factory"
		expect(details[9].value) == "1234"
	}

	func testPositiveTestDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.positiveTestEvent
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testPositiveTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"

		// When
		let details = PositiveTestDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(10))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == "Sneltest (RAT)"
		expect(details[4].value) == "Antigen Test"
		expect(details[5].value) == "donderdag 1 juli 2021 17:49"
		expect(details[6].value) == L.holderShowqrEuAboutTestPostive()
		expect(details[7].value) == "testPositiveTestGenerator"
		expect(details[8].value) == "GGD XL Factory"
		expect(details[9].value) == "1234"
	}

	func testDCCNegativeTestDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccTest = EuCredentialAttributes.TestEntry.negativeTest
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testDCCNegativeTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"

		// When
		let details = DCCTestDetailsGenerator.getDetails(identity: identity, test: dccTest)

		// Then
		expect(details).to(haveCount(13))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == L.holderDccTestPathogenvalue()
		expect(details[4].value) == "Sneltest (RAT)"
		expect(details[5].value) == "fake negativeTest"
		expect(details[6].value) == "woensdag 17 november 16:00"
		expect(details[7].value) == "negatief (geen coronavirus vastgesteld)"
		expect(details[8].value) == ""
		expect(details[9].value) == "testDCCNegativeTestGenerator"
		expect(details[10].value) == "NL"
		expect(details[11].value) == "Facility approved by the State of The Netherlands"
		expect(details[12].value) == "1234"
	}

	func testVaccinationDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationEvent
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Comirnaty (Pfizer)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"

		// When
		let details = VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: "CC")

		// Then
		expect(details).to(haveCount(12))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == L.holderEventAboutVaccinationPathogenvalue()
		expect(details[4].value) == "Comirnaty (Pfizer)"
		expect(details[5].value) == "SARS-CoV-2 mRNA vaccine"
		expect(details[6].value) == "Biontech"
		expect(details[7].value) == "1 van 2"
		expect(details[8].value) == nil
		expect(details[9].value) == "16 mei 2021"
		expect(details[10].value) == "NL"
		expect(details[11].value) == "1234"
	}
	
	func testVaccinationAssessmentDetailsGenerator() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationAssessmentEvent
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"

		// When
		let details = VaccinationAssessementDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(6))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == "woensdag 5 januari 13:42"
		expect(details[4].value) == "NL"
		expect(details[5].value) == "1234"
	}
	
	func testVaccinationAssessmentDetailsGenerator_withoutCountry() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationAssessmentEventWithoutCountry
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = ""
		
		// When
		let details = VaccinationAssessementDetailsGenerator.getDetails(identity: identity, event: event)
		
		// Then
		expect(details).to(haveCount(5))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == "woensdag 5 januari 13:42"
		expect(details[4].value) == "1234"
	}

	func testDCCVaccinationDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccVaccination = EuCredentialAttributes.Vaccination.vaccination
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Comirnaty (Pfizer)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"

		// When
		let details = DCCVaccinationDetailsGenerator.getDetails(identity: identity, vaccination: dccVaccination)

		// Then
		expect(details).to(haveCount(12))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == L.holderEventAboutVaccinationPathogenvalue()
		expect(details[4].value) == "Comirnaty (Pfizer)"
		expect(details[5].value) == "SARS-CoV-2 mRNA vaccine"
		expect(details[6].value) == "Biontech"
		expect(details[7].value) == "2 van 2"
		expect(details[8].value) == "1 juni 2021"
		expect(details[9].value) == "NL"
		expect(details[10].value) == "Facility approved by the State of The Netherlands"
		expect(details[11].value) == "1234"
	}

	func testRecoveryDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.recoveryEvent

		// When
		let details = RecoveryDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(7))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == "1 juli 2021"
		expect(details[4].value) == "12 juli 2021"
		expect(details[5].value) == "31 december 2022"
		expect(details[6].value) == "1234"
	}

	func testDCCRecoveryDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccRecovery = EuCredentialAttributes.RecoveryEntry.recovery
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"

		// When
		let details = DCCRecoveryDetailsGenerator.getDetails(identity: identity, recovery: dccRecovery)

		// Then
		expect(details).to(haveCount(9))
		expect(details[0].value) == nil
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 1980"
		expect(details[3].value) == "1 juli 2021"
		expect(details[4].value) == "NL"
		expect(details[5].value) == "Facility approved by the State of The Netherlands"
		expect(details[6].value) == "12 juli 2021"
		expect(details[7].value) == "31 december 2022"
		expect(details[8].value) == "1234"
	}
}
