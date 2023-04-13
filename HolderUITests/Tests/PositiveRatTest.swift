/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveRatTest: BaseTest {
	
	func test_posRatJ2() {
		let person = TestData.posRatJ2
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatJ3() {
		let person = TestData.posRatJ3
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP1J1() {
		let person = TestData.posRatP1J1
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP2J1() {
		let person = TestData.posRatP2J1
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP1M1() {
		let person = TestData.posRatP1M1
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
	
	func test_posRatP2M1() {
		let person = TestData.posRatP2M1
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertCertificateIsNotValidInternationally(ofType: .recovery)
	}
}
