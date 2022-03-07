/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class PositiveEncodingTest: BaseTest {
	
	func test_encodingLatin() {
		let person = TestData.encodingLatin
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingLatinDiacritic() {
		let person = TestData.encodingLatinDiacritic
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingArabic() {
		let person = TestData.encodingArabic
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingHebrew() {
		let person = TestData.encodingHebrew
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingChinese() {
		let person = TestData.encodingChinese
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingGreek() {
		let person = TestData.encodingGreek
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingCyrillic() {
		let person = TestData.encodingCyrillic
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingEmoji() {
		let person = TestData.encodingEmoji
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingLongStrings() {
		let person = TestData.encodingLongStrings
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
	
	func test_encodingLongNames() {
		let person = TestData.encodingLongNames
		addRecoveryCertificate(for: person)
		assertRetrievedCertificate(for: person)
		assertRetriedCertificateDetails(for: person)
		addRetrievedCertificateToApp()
		
		assertValidDutchRecoveryCertificate(validUntilOffset: person.recUntil)
		assertValidInternationalRecoveryCertificate(validUntilOffset: person.recUntil)
	}
}
