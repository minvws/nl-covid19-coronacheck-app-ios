/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class VaccinationEncodingTest: BaseTest {
	
	func test_encodingLatin() {
		let person = TestData.encodingLatin
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingArabic() {
		let person = TestData.encodingArabic
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingHebrew() {
		let person = TestData.encodingHebrew
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingChinese() {
		let person = TestData.encodingChinese
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingGreek() {
		let person = TestData.encodingGreek
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingCyrillic() {
		let person = TestData.encodingCyrillic
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingEmoji() {
		let person = TestData.encodingEmoji
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingLongStrings() {
		let person = TestData.encodingLongStrings
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
	
	func test_encodingLongNames() {
		let person = TestData.encodingLongNames
		addVaccinationCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetrievedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validUntilOffsetInDays: person.vacUntil)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
	}
}
