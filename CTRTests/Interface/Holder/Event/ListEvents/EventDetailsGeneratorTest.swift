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

	private var mappingManagerSpy: MappingManagerSpy!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {

		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			networkManager: NetworkSpy()
		)
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		mappingManagerSpy = MappingManagerSpy(remoteConfigManager: remoteConfigManagerSpy)
		Services.use(mappingManagerSpy)
	}

	override class func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	func testNegativeTestDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.negativeTestEvent
		mappingManagerSpy.stubbedGetTestManufacturerResult = "testNegativeTestGenerator"
		mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"

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
		mappingManagerSpy.stubbedGetTestManufacturerResult = "testPositiveTestGenerator"
		mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"

		// When
		let details = PositiveTestDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(10))
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == "Sneltest (RAT)"
		expect(details[4].value) == "Antigen Test"
		expect(details[5].value) == "donderdag 1 juli 02:00"
		expect(details[6].value) == L.holderShowqrEuAboutTestPostive()
		expect(details[7].value) == "GGD XL Factory"
		expect(details[8].value) == "testPositiveTestGenerator"
		expect(details[9].value) == "1234"
	}

	func testDCCNegativeTestDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccTest = EuCredentialAttributes.TestEntry.negativeTest
		mappingManagerSpy.stubbedGetTestManufacturerResult = "testDCCNegativeTestGenerator"
		mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"

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
		mappingManagerSpy.stubbedGetVaccinationBrandResult = "Pfizer (Comirnaty)"
		mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		mappingManagerSpy.stubbedGetVaccinationManufacturerMappingResult = "Biontech"
		mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"

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

	func testDCCVaccinationDetailsGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccVaccination = EuCredentialAttributes.Vaccination.vaccination
		mappingManagerSpy.stubbedGetVaccinationBrandResult = "Pfizer (Comirnaty)"
		mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		mappingManagerSpy.stubbedGetVaccinationManufacturerMappingResult = "Biontech"
		mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"

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
}
