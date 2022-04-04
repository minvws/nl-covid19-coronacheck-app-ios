/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class DifferentCredentialsTest: BaseTest {
	
	let setup = TestData.vacJ1DifferentFullNameReplaces
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		addVaccinationCertificate(for: setup)
		addRetrievedCertificateToApp()
	}
	
	func test_existingVaccinationAndNegativeTestOfDifferentPerson_IsNotReplaced() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffsetInDays: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl)
	}
	
	func test_existingVaccinationAndNegativeTestOfDifferentPerson_IsReplaced() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_existingVaccinationAndRecoveryOfDifferentPerson_IsNotReplaced() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: setup.dose, validUntilOffsetInDays: setup.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: setup.doseIntl)
	}
	
	func test_existingVaccinationAndRecoveryOfDifferentPerson_IsReplaced() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: person.recUntil)
	}
}
