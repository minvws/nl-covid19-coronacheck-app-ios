/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class MiscTest: BaseTest {
	
	func test_miscP1Positive() {
		let person = TestData.miscP1Positive
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
	
	func test_miscP2PosPcrNegPcr() {
		let person = TestData.miscP2PosPcrNegPcr
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: person.vacOffset)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalTestCertificate(testType: .pcr)
	}
}
