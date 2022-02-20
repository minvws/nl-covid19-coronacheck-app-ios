/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestVaccinationEventMatching: BaseTest {
	
	let setup = TestData.vacP2DifferentSetupSituation
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		addVaccinationCertificate(for: setup)
		addRetrievedCertificateToApp()
	}
	
	func test_vacJ1DifferentFirstNameReplaces() {
		let person = TestData.vacJ1DifferentFirstNameReplaces
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentLastNameReplaces() {
		let person = TestData.vacJ1DifferentLastNameReplaces
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentFullNameReplaces() {
		let person = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentBirthDayCanReplace() {
		let person = TestData.vacJ1DifferentBirthDayCanReplace
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentBirthMonthCanReplace() {
		let person = TestData.vacJ1DifferentBirthMonthCanReplace
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentBirthYearReplaces() {
		let person = TestData.vacJ1DifferentBirthYearReplaces
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentEverythingReplaceSetup() {
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffset: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1DifferentEverythingKeepSetup() {
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffset: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl, dateOffset: setup.vacOffset)
	}
}
