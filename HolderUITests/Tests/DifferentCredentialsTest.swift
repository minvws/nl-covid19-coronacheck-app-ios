/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class DifferentPersonTest: BaseTest {
	
	func test_existingVaccinationAndNegativeTestOfDifferentPerson_IsNotReplaced() {
		let person1 = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person1)
		addRetrievedCertificateToApp()
		
		let person2 = TestData.negPcr
		addTestCertificateFromGGD(for: person2)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: person1.dose, validUntilOffset: person1.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person1.doseIntl)
	}
	
	func test_existingVaccinationAndNegativeTestOfDifferentPerson_IsReplaced() {
		let person1 = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person1)
		addRetrievedCertificateToApp()
		
		let person2 = TestData.negPcr
		addTestCertificateFromGGD(for: person2)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchTestCertificate()
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_existingVaccinationAndRecoveryOfDifferentPerson_IsNotReplaced() {
		let person1 = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person1)
		addRetrievedCertificateToApp()
		
		let person2 = TestData.posPcr
		addRecoveryCertificate(for: person2)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: person1.dose, validUntilOffset: person1.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person1.doseIntl)
	}
	
	func test_existingVaccinationAndRecoveryOfDifferentPerson_IsReplaced() {
		let person1 = TestData.vacJ1DifferentFullNameReplaces
		addVaccinationCertificate(for: person1)
		addRetrievedCertificateToApp()
		
		let person2 = TestData.posPcr
		addRecoveryCertificate(for: person2)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person2.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person2.recUntil)
	}
}
