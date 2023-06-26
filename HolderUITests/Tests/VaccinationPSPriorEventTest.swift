/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationPSPriorEventTest: BaseTest {
	
	func test_vacP1PSPriorEvent() {
		let person = TestData.vacP1PSPriorEvent
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2PSPriorEventBoth() {
		let person = TestData.vacP2PSPriorEventBoth
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_vacP2PSPriorEventFirst() {
		let person = TestData.vacP2PSPriorEventFirst
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
