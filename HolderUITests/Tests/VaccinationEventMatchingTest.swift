/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationEventMatchingTest: BaseTest {
	
	let setup = TestData.vacP2DifferentSetupSituation
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		addVaccinationCertificate(for: setup)
		assertRetrievedCertificate(for: setup)
		assertRetrievedCertificateDetails(for: setup)
		addRetrievedCertificateToApp()
	}
	
	func test_vacJ1DifferentFirstName_Replaces() {
		let person = TestData.vacJ1DifferentFirstNameReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentLastName_Replaces() {
		let person = TestData.vacJ1DifferentLastNameReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentFullName_ReplaceSetup() {
		let person = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentFullName_KeepSetup() {
		let person = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffset: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, dateOffset: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup)
	}
	
	func test_vacJ1DifferentBirthDay_ReplaceSetup() {
		let person = TestData.vacJ1DifferentBirthDayCanReplace
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentBirthDay_KeepSetup() {
		let person = TestData.vacJ1DifferentBirthDayCanReplace
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffset: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, dateOffset: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup)
	}
	
	func test_vacJ1DifferentBirthMonth_ReplaceSetup() {
		let person = TestData.vacJ1DifferentBirthMonthCanReplace
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentBirthMonth_KeepSetup() {
		let person = TestData.vacJ1DifferentBirthMonthCanReplace
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffset: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, dateOffset: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup)
	}
	
	func test_vacJ1DifferentBirthYear_Replaces() {
		let person = TestData.vacJ1DifferentBirthYearReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentEverything_ReplaceSetup() {
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1DifferentEverything_KeepSetup() {
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffset: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, dateOffset: setup.vacOffset)
		assertInternationalVaccinationQRDetails(for: setup)
	}
}
