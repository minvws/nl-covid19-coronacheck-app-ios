/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class DisclosureMode0GSmoke: BaseTest {
	
	override func setUpWithError() throws {
		self.disclosureMode = DisclosureMode.mode0G
		
		try super.setUpWithError()
	}
	
	func test_mode0G_messages() {
		assertDisclosureMessages()
	}
	
	func test_mode0G_negPcr() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_mode0G_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_mode0G_posPcr() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
