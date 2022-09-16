/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationSmoke: BaseTest {
	
	func test_vacP1() {
		let person = TestData.vacP1
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertHintForOnlyInternationalCertificate()
		assertNoValidDutchCertificate(ofType: .vaccination)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacP2() {
		let person = TestData.vacP2
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
	
	func test_vacJ1() {
		let person = TestData.vacJ1
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		assertInternationalVaccinationQRDetails(for: person)
	}
}
