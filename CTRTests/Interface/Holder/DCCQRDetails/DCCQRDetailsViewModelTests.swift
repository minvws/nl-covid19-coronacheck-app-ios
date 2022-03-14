/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class DCCQRDetailsViewModelTests: XCTestCase {

	private var sut: DCCQRDetailsViewModel!
	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = HolderCoordinatorDelegateSpy()
	}
	
	func test_negativeTest() {
		
		// Given
		environmentSpies.mappingManagerSpy.stubbedGetBiLingualDisplayCountryResult = "Nederland / The Netherlands"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Test"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayFacilityResult = "Test Centrum XXL"
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "CoronaCheck Manufacturer"
		let details = NegativeTestQRDetailsGenerator.getDetails(
			euCredentialAttributes: EuCredentialAttributes.fake(
				dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithTest()
			),
			test: EuCredentialAttributes.TestEntry.negativeTest
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
		expect(self.sut.details[3].field) == "Type test / Type of test:"
		expect(self.sut.details[3].value) == "LP217198-3"
		expect(self.sut.details[4].field) == "Testnaam / Test name:"
		expect(self.sut.details[4].value) == "fake negativeTest"
		expect(self.sut.details[5].field) == "Testdatum / Test date:"
		expect(self.sut.details[5].value) == "woensdag 17 november 16:00"
		expect(self.sut.details[6].field) == "Testuitslag / Test result:"
		expect(self.sut.details[6].value) == "negatief (geen corona)"
		expect(self.sut.details[7].field) == "Testlocatie / Testing centre:"
		expect(self.sut.details[7].value) == "Test Centrum XXL"
		expect(self.sut.details[8].field) == "Producent / Test manufacturer:"
		expect(self.sut.details[8].value) == "CoronaCheck Manufacturer"
		expect(self.sut.details[9].field) == "Getest in / Member state of test:"
		expect(self.sut.details[9].value) == "Nederland / The Netherlands"
		expect(self.sut.details[10].field) == "Afgever certificaat / Certificate issuer:"
		expect(self.sut.details[10].value) == "Test"
		expect(self.sut.details[11].field) == "Uniek certificaatnummer / Unique certificate identifier:"
		expect(self.sut.details[11].value) == "1234"
	}
	
	func test_recovery() {
		
		// Given
		environmentSpies.mappingManagerSpy.stubbedGetBiLingualDisplayCountryResult = "Nederland / The Netherlands"
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
		expect(self.sut.details[3].field) == "Testdatum / Test date:"
		expect(self.sut.details[3].value) == "01-07-2021"
		expect(self.sut.details[4].field) == "Getest in / Member state of test:"
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
		environmentSpies.mappingManagerSpy.stubbedGetBiLingualDisplayCountryResult = "Nederland / The Netherlands"
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
		expect(self.sut.details).to(haveCount(11))
		expect(self.sut.details[0].field) == "Naam / Name:"
		expect(self.sut.details[0].value) == "Corona, Check"
		expect(self.sut.details[1].field) == "Geboortedatum / Date of birth*:"
		expect(self.sut.details[1].value) == "01-06-2021"
		expect(self.sut.details[2].field) == "Ziekteverwekker / Disease targeted:"
		expect(self.sut.details[2].value) == "COVID-19"
		expect(self.sut.details[3].field) == "Vaccin / Vaccine:"
		expect(self.sut.details[3].value) == "Test"
		expect(self.sut.details[4].field) == "Type vaccin / Vaccine medicinal product:"
		expect(self.sut.details[4].value) == "test"
		expect(self.sut.details[5].field) == "Producent / Vaccine manufacturer:"
		expect(self.sut.details[5].value) == "Test"
		expect(self.sut.details[6].field) == "Dosis / Number in series of doses:"
		expect(self.sut.details[6].value) == "2 / 2"
		expect(self.sut.details[7].field) == "Vaccinatiedatum / Date of vaccination*:"
		expect(self.sut.details[7].value) == "01-06-2021"
		expect(self.sut.details[8].field) == "Gevaccineerd in / Member state of vaccination:"
		expect(self.sut.details[8].value) == "Nederland / The Netherlands"
		expect(self.sut.details[9].field) == "Afgever certificaat / Certificate issuer:"
		expect(self.sut.details[9].value) == "Test"
		expect(self.sut.details[10].field) == "Uniek certificaatnummer / Unique certificate identifier:"
		expect(self.sut.details[10].value) == "1234"
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
}
