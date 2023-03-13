/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class DisclosureMode1GWith3GSmoke: BaseTest {
	
	override func setUpWithError() throws {
		disclosureMode = DisclosureMode.mode1GWith3G
		
		try super.setUpWithError()
	}
	
	func test_mode1GWith3G_messages() {
		assertDisclosureMessages()
	}
	
	func test_mode1GWith3G_negPcr() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_mode1GWith3G_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_mode1GWith3G_posPcr() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
