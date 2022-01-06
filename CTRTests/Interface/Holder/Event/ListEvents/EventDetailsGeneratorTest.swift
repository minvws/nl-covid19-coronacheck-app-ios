/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
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
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == "Sneltest (RAT)"
		expect(details[4].value) == "Antigen Test"
		expect(details[5].value) == "donderdag 1 juli 02:00"
		expect(details[6].value) == L.holderShowqrEuAboutTestNegative()
		expect(details[7].value) == "GGD XL Factory"
		expect(details[8].value) == "testNegativeTestGenerator"
		expect(details[9].value) == "1234"
	}

	func testNegativeTestV2DetailsGenerator() {

		// Given

		// When
		let details = NegativeTestV2DetailsGenerator.getDetails(testResult: TestResult.negativeResult)

		// Then
		expect(details).to(haveCount(5))
		expect(details[0].value) == "T D 12 DEC"
		expect(details[1].value) == "PCR"
		expect(details[2].value) == "vrijdag 1 januari 01:00"
		expect(details[3].value) == "negatief (geen corona)"
		expect(details[4].value) == "test"
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
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == "Sneltest (RAT)"
		expect(details[4].value) == "Antigen Test"
		expect(details[5].value) == "donderdag 1 juli 2021 02:00"
		expect(details[6].value) == L.holderShowqrEuAboutTestPostive()
		expect(details[7].value) == "GGD XL Factory"
		expect(details[8].value) == "testPositiveTestGenerator"
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
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == L.holderDccTestPathogenvalue()
		expect(details[4].value) == "Sneltest (RAT)"
		expect(details[5].value) == "fake negativeTest"
		expect(details[6].value) == "woensdag 17 november 16:00"
		expect(details[7].value) == L.holderShowqrEuAboutTestNegative()
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
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Pfizer (Comirnaty)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"

		// When
		let details = VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: "CC")

		// Then
		expect(details).to(haveCount(12))
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == L.holderEventAboutVaccinationPathogenvalue()
		expect(details[4].value) == "Pfizer (Comirnaty)"
		expect(details[5].value) == "SARS-CoV-2 mRNA vaccine"
		expect(details[6].value) == "Biontech"
		expect(details[7].value) == "1 van 2"
		expect(details[8].value).to(beNil())
		expect(details[9].value) == "16 mei 2021"
		expect(details[10].value) == "NL"
		expect(details[11].value) == "1234"
	}
	
	func testVaccinationAssessmentDetailsGenerator() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationAssessmentEvent

		// When
		let details = VaccinationAssessementDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(5))
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == "woensdag 5 januari 13:42"
		expect(details[4].value) == "1234"
	}

	func testDCCVaccinationDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccVaccination = EuCredentialAttributes.Vaccination.vaccination
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Pfizer (Comirnaty)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"

		// When
		let details = DCCVaccinationDetailsGenerator.getDetails(identity: identity, vaccination: dccVaccination)

		// Then
		expect(details).to(haveCount(12))
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == L.holderEventAboutVaccinationPathogenvalue()
		expect(details[4].value) == "Pfizer (Comirnaty)"
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
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
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
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == "1 juli 2021"
		expect(details[4].value) == "NL"
		expect(details[5].value) == "Facility approved by the State of The Netherlands"
		expect(details[6].value) == "12 juli 2021"
		expect(details[7].value) == "31 december 2022"
		expect(details[8].value) == "1234"
	}
}
