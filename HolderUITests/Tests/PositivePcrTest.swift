/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositivePcrTest: BaseTest {
	
	func test_posPcrJ2() {
		let person = TestData.posPcrJ2
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrJ3() {
		let person = TestData.posPcrJ3
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrP1J1() {
		let person = TestData.posPcrP1J1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrP2J1() {
		let person = TestData.posPcrP2J1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
