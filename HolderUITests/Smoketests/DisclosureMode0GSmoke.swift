/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class DisclosureMode0GSmoke: BaseTest {
	
	func test_mode0G_negPcr() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_mode0G_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_mode0G_posPcr() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
