/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositivePcrSmoke: BaseTest {
	
	func test_posPcr() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertInternationalRecoveryQRDetails(for: person)
	}
	
	func test_posPcrP1() {
		let person = TestData.posPcrP1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForInternationalVaccinationAndRecoveryCertificate()
		
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertInternationalRecoveryQRDetails(for: person)
	}
	
	func test_posPcrP2() {
		let person = TestData.posPcrP2
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrP3() {
		let person = TestData.posPcrP3
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrJ1() {
		let person = TestData.posPcrJ1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrP1M1() {
		let person = TestData.posPcrP1M1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_posPcrP2M1() {
		let person = TestData.posPcrP2M1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
