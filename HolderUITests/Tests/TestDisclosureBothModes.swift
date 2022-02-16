/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestDisclosureBothModes: BaseTest {
	
	override func setUpWithError() throws {
		self.disclosureMode = DisclosureMode.bothModes
		
		try super.setUpWithError()
	}
	
	func test_bothModes_messages() {
		assertDisclosureMessages()
	}
	
	func test_bothModes_negPcr() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchTestCertificate()
	}
	
	func test_bothModes_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffset: person.vacFrom)
	}
	
	func test_bothModes_posPcr() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
	}
}
