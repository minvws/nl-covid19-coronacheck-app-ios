/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

extension BaseTest {
	
	// MARK: General
	
	func assertNoCertificateRetrieved() {
		assertNoDutchCertificate()
		assertNoInternationalCertificate()
	}
	
	// MARK: Certificate retrieval
	
	private func returnToCertificateOverview() {
		tapText("Naar mijn bewijzen")
	}
	
	func assertSomethingWentWrong() {
		textExists("Sorry, er gaat iets mis")
		returnToCertificateOverview()
	}
	
	func assertNoVaccinationsAvailable() {
		textExists("Geen vaccinaties beschikbaar")
		returnToCertificateOverview()
	}
	
	func assertNoCertificateCouldBeCreated() {
		textExists("We kunnen geen bewijs maken")
		returnToCertificateOverview()
	}
	
	func assertCertificateIsOnlyValidInternationally() {
		textExists("Er is alleen een internationaal bewijs gemaakt")
		returnToCertificateOverview()
	}
	
	func assertNoTestresultIsAvailable() {
		textExists("Geen testuitslag beschikbaar")
		returnToCertificateOverview()
	}
	
	func assertPositiveTestResultIsNotValidAnymore() {
		textExists("Positieve testuitslag niet meer geldig")
		returnToCertificateOverview()
	}
	
	// MARK: The Netherlands
	
	func tapOnTheNetherlandsTab() {
		tapButton("Nederland")
	}
	
	func assertNoDutchCertificate() {
		tapOnTheNetherlandsTab()
		textExists("Hier komt jouw Nederlandse bewijs")
	}
	
	func assertNoValidDutchCertificate(ofType certificateType: CertificateType) {
		tapOnTheNetherlandsTab()
		textExists("Je hebt geen Nederlands " + certificateType.rawValue.lowercased())
	}
	
	func assertValidDutchVaccinationCertificate(doses: Int = 0, validFromOffset: Int? = nil, validUntilOffset: Int? = nil, validUntilDate: String? = nil) {
		tapOnTheNetherlandsTab()
		assertValidCertificate(ofType: .vaccination)
		textContains(amountOfDoses(for: doses))
		if let offset = validUntilOffset {
			textContains("geldig tot " + formattedOffsetDate(with: offset))
		}
		if let offset = validFromOffset {
			textContains("geldig vanaf " + formattedOffsetDate(with: offset))
		}
		if let date = validUntilDate {
			textContains("tot " + formattedDate(with: date))
		}
	}
	
	func assertValidDutchRecoveryCertificate(validUntilOffset: Int) {
		tapOnTheNetherlandsTab()
		assertValidCertificate(ofType: .recovery)
		textContains("geldig tot " + formattedOffsetDate(with: validUntilOffset))
	}
	
	func assertValidDutchTestCertificate(validUntilOffset: Int = 1) {
		tapOnTheNetherlandsTab()
		assertValidCertificate(ofType: .test)
		textContains("geldig tot " + formattedOffsetDate(with: validUntilOffset, withYear: false, withDay: true))
	}
	
	func assertDutchCertificateIsNotYetValid(ofType certificateType: CertificateType, doses: Int = 0, validFromOffset: Int, validUntilOffset: Int? = nil) {
		tapOnTheNetherlandsTab()
		textContains(certificateType.rawValue)
		textContains("geldig vanaf " + formattedOffsetDate(with: validFromOffset, withYear: false))
		if let offset = validUntilOffset {
			textContains("tot " + formattedOffsetDate(with: offset))
		}
		textContains("Wordt automatisch geldig")
	}
	
	// MARK: International
	
	func tapOnInternationalTab() {
		tapButton("Internationaal")
	}
	
	func assertNoInternationalCertificate() {
		tapOnInternationalTab()
		textExists("Hier komt jouw internationale bewijs")
	}
	
	func assertValidInternationalVaccinationCertificate(doses: [String], dateOffset: Int = -30) {
		tapOnInternationalTab()
		assertValidCertificate(ofType: .vaccination)
		for (index, dose) in doses.reversed().enumerated() {
			textContains("Dosis \(dose) Vaccinatiedatum: " + formattedOffsetDate(with: dateOffset - (30 * index)))
		}
	}
	
	func assertValidInternationalRecoveryCertificate(validUntilOffset: Int) {
		tapOnInternationalTab()
		assertValidCertificate(ofType: .recovery)
		textContains("Geldig tot " + formattedOffsetDate(with: validUntilOffset))
	}
	
	func assertValidInternationalTestCertificate(testType: TestCertificateType, dateOffset: Int = 0) {
		tapOnInternationalTab()
		assertValidCertificate(ofType: .test)
		textContains("Type test: " + testType.rawValue)
		textContains("Testdatum: " + formattedOffsetDate(with: dateOffset, withYear: false, withDay: true))
	}
	
	func assertCertificateIsNotValidInternationally(ofType certificateType: CertificateType) {
		tapOnInternationalTab()
		textExists("Je \(certificateType.rawValue.lowercased()) is niet internationaal geldig. Je hebt wel een Nederlands bewijs.")
	}
	
	func assertInternationalCertificateIsNotYetValid(ofType certificateType: CertificateType, doses: Int = 0, validFromOffset: Int, validUntilOffset: Int? = nil) {
		tapOnTheNetherlandsTab()
		textContains(certificateType.rawValue)
		textContains("Geldig vanaf " + formattedOffsetDate(with: validFromOffset, withYear: false))
		if let offset = validUntilOffset {
			textContains("tot " + formattedOffsetDate(with: offset))
		}
		textContains("Wordt automatisch geldig")
	}
	
	// MARK: Private functions
	
	private func assertValidCertificate(ofType certificateType: CertificateType) {
		textContains(certificateType.rawValue)
	}
}
