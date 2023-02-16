/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
@testable import Models
import Shared
@testable import Managers
@testable import Resources

class DCCQRDetailsViewModelTests: XCTestCase {

	private var sut: DCCQRDetailsViewModel!
	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = HolderCoordinatorDelegateSpy()
	}
	
	func test_negativeTest() throws {
		
		// Given
		environmentSpies.mappingManagerSpy.stubbedGetBilingualDisplayCountryResult = "Nederland / The Netherlands"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Test"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayFacilityResult = "Test Centrum XXL"
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "CoronaCheck Manufacturer"
		let timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		let details = NegativeTestQRDetailsGenerator.getDetails(
			euCredentialAttributes: EuCredentialAttributes.fake(
				dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithTest()
			),
			test: EuCredentialAttributes.TestEntry.negativeTest,
			timeZone: timeZone
		)
		
		// When
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: details,
			dateInformation: "information"
		)
		
		// Then
		expect(self.sut.title) == "title"
		expect(self.sut.description) == "body"
		expect(self.sut.dateInformation) == "information"
		expect(self.sut.details).to(haveCount(12))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
		expect(self.sut.details[1].field) == "Geboortedatum / Date of birth*:"
		expect(self.sut.details[1].value) == "01-06-2021"
		expect(self.sut.details[2].field) == "Ziekteverwekker / Disease targeted:"
		expect(self.sut.details[2].value) == "COVID-19"
		expect(self.sut.details[3].field) == "Type test / Test type:"
		expect(self.sut.details[3].value) == "LP217198-3"
		expect(self.sut.details[4].field) == "Testnaam / Test name:"
		expect(self.sut.details[4].value) == "fake negativeTest"
		expect(self.sut.details[5].field) == "Testdatum / Test date:"
		expect(self.sut.details[5].value).to(beginWith("woensdag 17 november 2021 16:00"))
		expect(self.sut.details[6].field) == "Testuitslag / Test result:"
		expect(self.sut.details[6].value) == "negatief (geen coronavirus vastgesteld) / negative (no coronavirus detected)"
		expect(self.sut.details[7].field) == "Testlocatie / Test location:"
		expect(self.sut.details[7].value) == "Test Centrum XXL"
		expect(self.sut.details[8].field) == "Testproducent / Test manufacturer:"
		expect(self.sut.details[8].value) == "CoronaCheck Manufacturer"
		expect(self.sut.details[9].field) == "Getest in / Tested in:"
		expect(self.sut.details[9].value) == "Nederland / The Netherlands"
		expect(self.sut.details[10].field) == "Afgever certificaat / Certificate issuer:"
		expect(self.sut.details[10].value) == "Test"
		expect(self.sut.details[11].field) == "Uniek certificaatnummer / Unique certificate identifier:"
		expect(self.sut.details[11].value) == "1234"
	}
	
	func test_recovery() {
		
		// Given
		environmentSpies.mappingManagerSpy.stubbedGetBilingualDisplayCountryResult = "Nederland / The Netherlands"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Test"
		let details = RecoveryQRDetailsGenerator.getDetails(
			euCredentialAttributes: EuCredentialAttributes.fake(
				dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithRecovery()
			),
			recovery: EuCredentialAttributes.RecoveryEntry.recovery
		)
		
		// When
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: details,
			dateInformation: "information"
		)
		
		// Then
		expect(self.sut.title) == "title"
		expect(self.sut.description) == "body"
		expect(self.sut.dateInformation) == "information"
		expect(self.sut.details).to(haveCount(9))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
		expect(self.sut.details[1].field) == "Geboortedatum / Date of birth*:"
		expect(self.sut.details[1].value) == "01-06-2021"
		expect(self.sut.details[2].field) == "Ziekte waarvan hersteld / Disease recovered from:"
		expect(self.sut.details[2].value) == "COVID-19"
		expect(self.sut.details[3].field) == "Testdatum / Test date*:"
		expect(self.sut.details[3].value) == "01-07-2021"
		expect(self.sut.details[4].field) == "Getest in / Tested in:"
		expect(self.sut.details[4].value) == "Nederland / The Netherlands"
		expect(self.sut.details[5].field) == "Afgever certificaat / Certificate issuer:"
		expect(self.sut.details[5].value) == "Test"
		expect(self.sut.details[6].field) == "Geldig vanaf / Valid from*:"
		expect(self.sut.details[6].value) == "12-07-2021"
		expect(self.sut.details[7].field) == "Geldig tot / Valid to*:"
		expect(self.sut.details[7].value) == "31-12-2022"
		expect(self.sut.details[8].field) == "Uniek certificaatnummer / Unique certificate identifier:"
		expect(self.sut.details[8].value) == "1234"
	}
	
	func test_vaccination() {
		
		// Given
		environmentSpies.mappingManagerSpy.stubbedGetBilingualDisplayCountryResult = "Nederland / The Netherlands"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Test"
		let details = VaccinationQRDetailsGenerator.getDetails(
			euCredentialAttributes: EuCredentialAttributes.fakeVaccination(),
			vaccination: EuCredentialAttributes.Vaccination.vaccination
		)
		
		// When
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: details,
			dateInformation: "information"
		)
		
		// Then
		expect(self.sut.title) == "title"
		expect(self.sut.description) == "body"
		expect(self.sut.dateInformation) == "information"
		expect(self.sut.details).to(haveCount(12))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
		expect(self.sut.details[1].field) == "Geboortedatum / Date of birth*:"
		expect(self.sut.details[1].value) == "01-06-2021"
		expect(self.sut.details[2].field) == "Ziekteverwekker / Disease targeted:"
		expect(self.sut.details[2].value) == "COVID-19"
		expect(self.sut.details[3].field) == "Vaccin / Vaccine:"
		expect(self.sut.details[3].value) == "Test"
		expect(self.sut.details[4].field) == "Type vaccin / Vaccine type:"
		expect(self.sut.details[4].value) == "test"
		expect(self.sut.details[5].field) == "Vaccinproducent / Vaccine manufacturer:"
		expect(self.sut.details[5].value) == "Test"
		expect(self.sut.details[6].field) == "Dosis / Number in series of doses:"
		expect(self.sut.details[6].value) == "2 / 2"
		expect(self.sut.details[6].dosageMessage) == nil
		expect(self.sut.details[7].field) == "Vaccinatiedatum / Vaccination date*:"
		expect(self.sut.details[7].value) == "01-06-2021"
		expect(self.sut.details[8].field) == "Dagen sinds vaccinatie / Days since vaccination:"
		expect(self.sut.details[8].value) == "44 dagen"
		expect(self.sut.details[9].field) == "Gevaccineerd in / Vaccinated in:"
		expect(self.sut.details[9].value) == "Nederland / The Netherlands"
		expect(self.sut.details[10].field) == "Afgever certificaat / Certificate issuer:"
		expect(self.sut.details[10].value) == "Test"
		expect(self.sut.details[11].field) == "Uniek certificaatnummer / Unique certificate identifier:"
		expect(self.sut.details[11].value) == "1234"
	}
	
	func test_vaccination_whenDosageNumberIsHigherThanTotalDosage() {
		
		// Given
		let doseNumber = 3
		let totalDose = 2
		let vaccination = EuCredentialAttributes.Vaccination(
			certificateIdentifier: "1234",
			country: "NLD",
			diseaseAgentTargeted: "840539006",
			doseNumber: doseNumber,
			dateOfVaccination: "2021-06-01",
			issuer: "Test",
			marketingAuthorizationHolder: "Test",
			medicalProduct: "Test",
			totalDose: totalDose,
			vaccineOrProphylaxis: "test"
		)
		environmentSpies.mappingManagerSpy.stubbedGetBilingualDisplayCountryResult = "Nederland / The Netherlands"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Test"
		let details = VaccinationQRDetailsGenerator.getDetails(
			euCredentialAttributes: EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: doseNumber, totalDose: totalDose)),
			vaccination: vaccination
		)
		
		// When
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: details,
			dateInformation: "information"
		)
		
		// Then
		expect(self.sut.title) == "title"
		expect(self.sut.description) == "body"
		expect(self.sut.dateInformation) == "information"
		expect(self.sut.details).to(haveCount(12))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
		expect(self.sut.details[1].field) == "Geboortedatum / Date of birth*:"
		expect(self.sut.details[1].value) == "01-06-2021"
		expect(self.sut.details[2].field) == "Ziekteverwekker / Disease targeted:"
		expect(self.sut.details[2].value) == "COVID-19"
		expect(self.sut.details[3].field) == "Vaccin / Vaccine:"
		expect(self.sut.details[3].value) == "Test"
		expect(self.sut.details[4].field) == "Type vaccin / Vaccine type:"
		expect(self.sut.details[4].value) == "test"
		expect(self.sut.details[5].field) == "Vaccinproducent / Vaccine manufacturer:"
		expect(self.sut.details[5].value) == "Test"
		expect(self.sut.details[6].field) == "Dosis / Number in series of doses:"
		expect(self.sut.details[6].value) == "3 / 2"
		expect(self.sut.details[6].dosageMessage) == L.holder_showqr_eu_about_vaccination_dosage_message()
		expect(self.sut.details[7].field) == "Vaccinatiedatum / Vaccination date*:"
		expect(self.sut.details[7].value) == "01-06-2021"
		expect(self.sut.details[8].field) == "Dagen sinds vaccinatie / Days since vaccination:"
		expect(self.sut.details[8].value) == "44 dagen"
		expect(self.sut.details[9].field) == "Gevaccineerd in / Vaccinated in:"
		expect(self.sut.details[9].value) == "Nederland / The Netherlands"
		expect(self.sut.details[10].field) == "Afgever certificaat / Certificate issuer:"
		expect(self.sut.details[10].value) == "Test"
		expect(self.sut.details[11].field) == "Uniek certificaatnummer / Unique certificate identifier:"
		expect(self.sut.details[11].value) == "1234"
	}
	
	func test_nilValue_shouldBeFiltered() {
		
		// Given
		
		// When
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: [
				DCCQRDetails(field: DCCQRDetailsTest.name, value: "Corona, Check"),
				DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: nil)
			],
			dateInformation: "information"
		)
		
		// THen
		expect(self.sut.details).to(haveCount(1))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
	}
	
	func test_emptyValue_shouldBeFiltered() {
		
		// Given
		
		// When
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: [
				DCCQRDetails(field: DCCQRDetailsTest.name, value: "Corona, Check"),
				DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: "")
			],
			dateInformation: "information"
		)
		
		// THen
		expect(self.sut.details).to(haveCount(1))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
	}
	
	func test_openUrl_shouldOpenUrl() throws {

		// Given
		sut = DCCQRDetailsViewModel(
			coordinator: coordinatorSpy,
			title: "title",
			description: "body",
			details: [
				DCCQRDetails(field: DCCQRDetailsTest.name, value: "Corona, Check"),
				DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: nil)
			],
			dateInformation: "information"
		)
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
}
