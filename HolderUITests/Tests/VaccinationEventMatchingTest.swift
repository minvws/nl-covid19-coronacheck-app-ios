/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class VaccinationEventMatchingTest: BaseTest {
	
	let setup = TestData.vacP2DifferentSetupSituation
	let setupPerson = Person(bsn: "999993562", name: "van Geer, Corrie", birthDate: Date("1960-01-01"))
	let setupVac1of2 = Vaccination(eventDate: Date(-90), vaccine: .pfizer)
	let setupVac2of2 = Vaccination(eventDate: Date(-60), vaccine: .pfizer)
	let newVac = Vaccination(eventDate: Date(-30), vaccine: .janssen)
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		addVaccinationCertificate(for: setupPerson.bsn!)
		assertRetrievedVaccinationDetails(for: setupPerson, vaccination: setupVac2of2, position: 0)
		assertRetrievedVaccinationDetails(for: setupPerson, vaccination: setupVac1of2, position: 1)
		addRetrievedCertificateToApp()
	}
	
	func test_vacJ1DifferentFirstName_Merges() {
		let differentFirstName = Person(bsn: "999991255", name: "van Geer, Pieter", birthDate: Date("1960-01-01"))
		addVaccinationCertificate(for: differentFirstName.bsn!)
		assertRetrievedVaccinationDetails(for: differentFirstName, vaccination: newVac)
		addRetrievedCertificateToApp()

		assertValidDutchVaccinationCertificate(doses: 3, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "3/3")
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")

		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "3/3", for: differentFirstName)
		viewPreviousQR()
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentLastName_Merges() {
		let differentLastName = Person(bsn: "999991267", name: "de Heuvel, Corrie", birthDate: Date("1960-01-01"))
		addVaccinationCertificate(for: differentLastName.bsn!)
		assertRetrievedVaccinationDetails(for: differentLastName, vaccination: newVac)
		addRetrievedCertificateToApp()

		assertValidDutchVaccinationCertificate(doses: 3, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "3/3")
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "3/3", for: differentLastName)
		viewPreviousQR()
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentFullName_ReplaceSetup() {
		let person = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentFullName_KeepSetup() {
		let person = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffsetInDays: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, vaccinationDateOffsetInDays: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup, vaccinationDateOffsetInDays: setup.vacOffset)
	}
	
	func test_vacJ1DifferentBirthDay_ReplaceSetup() {
		let person = TestData.vacJ1DifferentBirthDayCanReplace
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentBirthDay_KeepSetup() {
		let person = TestData.vacJ1DifferentBirthDayCanReplace
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffsetInDays: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, vaccinationDateOffsetInDays: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup, vaccinationDateOffsetInDays: setup.vacOffset)
	}
	
	func test_vacJ1DifferentBirthMonth_ReplaceSetup() {
		let person = TestData.vacJ1DifferentBirthMonthCanReplace
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentBirthMonth_KeepSetup() {
		let person = TestData.vacJ1DifferentBirthMonthCanReplace
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffsetInDays: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, vaccinationDateOffsetInDays: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup, vaccinationDateOffsetInDays: setup.vacOffset)
	}
	
	func test_vacJ1DifferentBirthYear_Replaces() {
		let person = TestData.vacJ1DifferentBirthYearReplaces
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentEverything_ReplaceSetup() {
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentEverything_KeepSetup() {
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person.bsn)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffsetInDays: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, vaccinationDateOffsetInDays: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup, vaccinationDateOffsetInDays: setup.vacOffset)
	}
}
