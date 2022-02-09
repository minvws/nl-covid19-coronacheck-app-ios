/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class TestEncoding: BaseTest {
	
	func test_encodingLatin() {
		addVaccinationCertificate(for: TestData.encodingLatin)
		addRetrievedCertificateToApp(for: TestData.encodingLatin)
	}
	
	func test_encodingArabic() {
		addVaccinationCertificate(for: TestData.encodingArabic)
		addRetrievedCertificateToApp(for: TestData.encodingArabic)
	}
	
	func test_encodingHebrew() {
		addVaccinationCertificate(for: TestData.encodingHebrew)
		addRetrievedCertificateToApp(for: TestData.encodingHebrew)
	}
	
	func test_encodingChinese() {
		addVaccinationCertificate(for: TestData.encodingChinese)
		addRetrievedCertificateToApp(for: TestData.encodingChinese)
	}
	
	func test_encodingGreek() {
		addVaccinationCertificate(for: TestData.encodingGreek)
		addRetrievedCertificateToApp(for: TestData.encodingGreek)
	}
	
	func test_encodingCyrillic() {
		addVaccinationCertificate(for: TestData.encodingCyrillic)
		addRetrievedCertificateToApp(for: TestData.encodingCyrillic)
	}
	
	func test_encodingEmoji() {
		addVaccinationCertificate(for: TestData.encodingEmoji)
		addRetrievedCertificateToApp(for: TestData.encodingEmoji)
	}
	
	func test_encodingLongStrings() {
		addVaccinationCertificate(for: TestData.encodingLongStrings)
		addRetrievedCertificateToApp(for: TestData.encodingLongStrings)
	}
	
	func test_encodingLongNames() {
		addVaccinationCertificate(for: TestData.encodingLongNames)
		addRetrievedCertificateToApp(for: TestData.encodingLongNames)
	}
}
