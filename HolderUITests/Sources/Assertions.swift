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
		app.tapText("Naar mijn bewijzen")
	}
	
	func assertSomethingWentWrong() {
		app.textExists("Sorry, er gaat iets mis")
		returnToCertificateOverview()
	}
	
	func assertNoVaccinationsAvailable() {
		app.textExists("Geen vaccinaties beschikbaar")
		returnToCertificateOverview()
	}
	
	func assertNoCertificateCouldBeCreated() {
		app.textExists("We kunnen geen bewijs maken")
		returnToCertificateOverview()
	}
	
	func assertCertificateIsOnlyValidInternationally() {
		app.textExists("Er is alleen een internationaal bewijs gemaakt")
		returnToCertificateOverview()
	}
	
	func assertNoTestresultIsAvailable() {
		app.textExists("Geen testuitslag beschikbaar")
		returnToCertificateOverview()
	}
	
	func assertPositiveTestResultIsNotValidAnymore() {
		app.textExists("Positieve testuitslag niet meer geldig")
		returnToCertificateOverview()
	}
	
	func replaceExistingCertificate(_ replace: Bool = true) {
		textExists("Wil je je bewijs vervangen?")
		tapButton(replace ? "Vervang" : "Stoppen")
	}
	
	// MARK: The Netherlands
	
	func tapOnTheNetherlandsTab() {
		app.tapButton("Nederland")
	}
	
	func assertNoDutchCertificate() {
		tapOnTheNetherlandsTab()
		app.textExists("Hier komt jouw Nederlandse bewijs")
	}
	
	func assertDisclosureMessages() {
		switch disclosureMode {
			case .only3G:
				app.containsText("Op je bewijs staat nu 3G. Dit betekent dat je bewijs geschikt is voor plekken in Nederland die 3G-toegang geven.")
			case .only1G:
				app.linkExists("Wil je naar een plek met 1G-toegang? Dan heb je een testbewijs nodig.")
				app.textExists("Vanaf nu heb je een testbewijs nodig voor 1G toegang")
			case .bothModes:
				app.linkExists("Bekijk vooraf of de locatie die je bezoekt een bewijs voor 3G- of 1G toegang vraagt.")
				app.textExists("Vanaf nu zijn er 2 aparte QR-codes voor 3G- en 1G-toegang")
		}
	}
	
	func assertNoValidDutchCertificate(ofType certificateType: CertificateType) {
		tapOnTheNetherlandsTab()
		app.textExists("Je hebt geen Nederlands " + certificateType.rawValue.lowercased())
	}
	
	func assertValidDutchVaccinationCertificate(doses: Int = 0, validFromOffset: Int? = nil, validUntilOffset: Int? = nil, validUntilDate: String? = nil) {
		tapOnTheNetherlandsTab()
		card3G().containsText(CertificateType.vaccination.rawValue)
		card3G().containsText(amountOfDoses(for: doses))
		if let offset = validUntilOffset {
			card3G().containsText("geldig tot " + formattedOffsetDate(with: offset))
		}
		if let offset = validFromOffset {
			card3G().containsText("geldig vanaf " + formattedOffsetDate(with: offset))
		}
		if let date = validUntilDate {
			card3G().containsText("tot " + formattedDate(with: date))
		}
		card3G().containsText(is3GEnabled() ? "Bekijk QR" : "Dit bewijs wordt nu niet gebruikt in Nederland")
	}
	
	func assertValidDutchRecoveryCertificate(validUntilOffset: Int) {
		tapOnTheNetherlandsTab()
		card3G().containsText(CertificateType.recovery.rawValue)
		card3G().containsText("geldig tot " + formattedOffsetDate(with: validUntilOffset))
		card3G().containsText(is3GEnabled() ? "Bekijk QR" : "Dit bewijs wordt nu niet gebruikt in Nederland")
	}
	
	func assertValidDutchTestCertificate(validUntilOffset: Int = 1) {
		tapOnTheNetherlandsTab()
		for card in cardsToCheck(for: .test) {
			card.containsText(CertificateType.test.rawValue)
			card.containsText("geldig tot " + formattedOffsetDate(with: validUntilOffset, withYear: false, withDay: true))
			card.containsText("Bekijk QR")
		}
	}
	
	func assertDutchCertificateIsNotYetValid(ofType certificateType: CertificateType, doses: Int = 0, validFromOffset: Int, validUntilOffset: Int? = nil) {
		tapOnTheNetherlandsTab()
		for card in cardsToCheck(for: certificateType) {
			card.containsText(certificateType.rawValue)
			card.containsText("geldig vanaf " + formattedOffsetDate(with: validFromOffset, withYear: false))
			if let offset = validUntilOffset {
				card.containsText("tot " + formattedOffsetDate(with: offset))
			}
			card.containsText("Wordt automatisch geldig")
		}
	}
	
	// MARK: International
	
	func tapOnInternationalTab() {
		app.tapButton("Internationaal")
	}
	
	func assertNoInternationalCertificate() {
		tapOnInternationalTab()
		app.textExists("Hier komt jouw internationale bewijs")
	}
	
	func assertValidInternationalVaccinationCertificate(doses: [String], dateOffset: Int = -30) {
		tapOnInternationalTab()
		app.containsText(CertificateType.vaccination.rawValue)
		for (index, dose) in doses.reversed().enumerated() {
			app.containsText("Dosis \(dose) Vaccinatiedatum: " + formattedOffsetDate(with: dateOffset - (30 * index)))
		}
		app.containsText("Bekijk QR")
	}
	
	func assertValidInternationalRecoveryCertificate(validUntilOffset: Int) {
		tapOnInternationalTab()
		app.containsText(CertificateType.recovery.rawValue)
		app.containsText("Geldig tot " + formattedOffsetDate(with: validUntilOffset))
		app.containsText("Bekijk QR")
	}
	
	func assertValidInternationalTestCertificate(testType: TestCertificateType, dateOffset: Int = 0) {
		tapOnInternationalTab()
		app.containsText(CertificateType.test.rawValue)
		app.containsText("Type test: " + testType.rawValue)
		app.containsText("Testdatum: " + formattedOffsetDate(with: dateOffset, withYear: false, withDay: true))
		app.containsText("Bekijk QR")
	}
	
	func assertCertificateIsNotValidInternationally(ofType certificateType: CertificateType) {
		tapOnInternationalTab()
		app.textExists("Je \(certificateType.rawValue.lowercased()) is niet internationaal geldig. Je hebt wel een Nederlands bewijs.")
	}
	
	func assertInternationalCertificateIsNotYetValid(ofType certificateType: CertificateType, doses: Int = 0, validFromOffset: Int, validUntilOffset: Int? = nil) {
		tapOnTheNetherlandsTab()
		app.containsText(certificateType.rawValue)
		app.containsText("Geldig vanaf " + formattedOffsetDate(with: validFromOffset, withYear: false))
		if let offset = validUntilOffset {
			app.containsText("tot " + formattedOffsetDate(with: offset))
		}
		app.containsText("Wordt automatisch geldig")
	}
}
