/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationPSRecoveryTest: BaseTest {
	
	func test_vacP2PSRecovery() {
		let person = TestData.vacP2PSRecovery
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacJ1PSRecovery() {
		let person = TestData.vacJ1PSRecovery
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM1PSRecovery() {
		let person = TestData.vacM1PSRecovery
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacM3PSRecovery() {
		let person = TestData.vacM3PSRecovery
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
