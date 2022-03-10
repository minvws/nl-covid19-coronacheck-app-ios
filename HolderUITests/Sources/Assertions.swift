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
	
	func assertPositiveTestResultNotValidAnymore() {
		app.textExists("Positieve testuitslag niet meer geldig")
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
		app.textExists("Wil je je bewijs vervangen?")
		app.tapButton(replace ? "Vervang" : "Stoppen")
	}
	
	func assertRetrievedCertificate(for person: TestPerson) {
		app.textExists("Kloppen de gegevens?")
		app.containsText("Naam: " + person.name)
		app.containsText("Geboortedatum: " + formattedDate(of: person.birthDate))
	}
	
	func assertRetriedCertificateDetails(for person: TestPerson) {
		app.tapButton("Details")
		app.textExists("Naam: " + person.name)
		app.textExists("Geboortedatum: " + formattedDate(of: person.birthDate))
		app.tapButton("CloseButton")
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
				app.containsText("Op dit moment geeft een Nederlands bewijs 3G-toegang.")
			case .only1G:
				app.linkExists("In Nederland krijg je alleen toegang met een testbewijs op plekken waar om een coronabewijs wordt gevraagd (1G-toegang).")
				app.textExists("Je kunt een bewijs voor 1G-toegang toevoegen wanneer je negatief getest bent")
			case .bothModes:
				app.linkExists("Bezoek je een plek in Nederland? Check vooraf of je een bewijs voor 3G- of 1G toegang nodig hebt.")
				app.textExists("De Nederlandse toegangsregels zijn veranderd. Er zijn nu aparte bewijzen voor plekken die 3G-toegang en 1G-toegang geven.")
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
			card3G().containsText("tot " + formattedDate(of: date))
		}
		card3G().containsText(is3GEnabled() ? "Bekijk QR" : "Dit bewijs wordt nu niet gebruikt in Nederland")
	}
	
	func assertValidDutchRecoveryCertificate(validUntilOffset: Int) {
		tapOnTheNetherlandsTab()
		card3G().containsText(CertificateType.recovery.rawValue)
		card3G().containsText("geldig tot " + formattedOffsetDate(with: validUntilOffset))
		card3G().containsText(is3GEnabled() ? "Bekijk QR" : "Dit bewijs wordt nu niet gebruikt in Nederland")
	}
	
	func assertValidDutchTestCertificate(validUntilOffset: Int = 1, combinedWithOther: Bool = false) {
		tapOnTheNetherlandsTab()
		for card in cardsToCheck(for: .test, combinedWithOther) {
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
	
	func assertInternationalCertificateIsNotYetValid(ofType certificateType: CertificateType, validFromOffset: Int, validUntilOffset: Int? = nil) {
		tapOnTheNetherlandsTab()
		app.containsText(certificateType.rawValue)
		app.containsText("Geldig vanaf " + formattedOffsetDate(with: validFromOffset, withYear: false))
		if let offset = validUntilOffset {
			app.containsText("tot " + formattedOffsetDate(with: offset))
		}
		app.containsText("Wordt automatisch geldig")
	}
	
	func assertInternationalVaccinationQRDetails(for person: TestPerson, dateOffset: Int = -30) {
		card(of: .vaccination).tapButton(person.doseIntl.count > 1 ? "Bekijk QR-codes" : "Bekijk QR")
		for (index, dose) in person.doseIntl.reversed().enumerated() {
			app.textExists("Dosis " + dose)
			
			openQRDetails(for: person)
			app.textExists("Over je dosis " + dose)
			app.labelValuePairExist(label: "Ziekteverwekker / Disease targeted:", value: "COVID-19")
			app.labelValuePairExist(label: "Dosis / Number in series of doses:", value: spreadDose(dose))
			app.labelValuePairExist(label: "Vaccinatiedatum / Date of vaccination*:", value: formattedOffsetDate(with: dateOffset - (30 * index), short: true))
			closeQRDetails()
			
			if index != person.doseIntl.indices.last {
				app.tapButton("Vorige QR-code")
			}
		}
		app.tapButton("BackButton")
	}
	
	func assertInternationalRecoveryQRDetails(for person: TestPerson) {
		card(of: .recovery).tapButton("Bekijk QR")
		app.textExists("Internationale QR")
		
		openQRDetails(for: person)
		app.textExists("Over mijn internationale QR-code")
		app.labelValuePairExist(label: "Ziekte waarvan hersteld / Disease recovered from:", value: "COVID-19")
		app.labelValuePairExist(label: "Geldig vanaf / Valid from*:", value: formattedOffsetDate(with: person.recFrom, short: true))
		app.labelValuePairExist(label: "Geldig tot / Valid to*:", value: formattedOffsetDate(with: person.recUntil, short: true))
		closeQRDetails()
		app.tapButton("BackButton")
	}
	
	func assertInternationalTestQRDetails(for person: TestPerson, testType: TestCertificateType) {
		card(of: .test).tapButton("Bekijk QR")
		app.textExists("Internationale QR")
		
		openQRDetails(for: person)
		app.textExists("Over mijn internationale QR-code")
		app.labelValuePairExist(label: "Testuitslag / Test result:", value: "negatief (geen corona)")
		app.labelValuePairExist(label: "Type test / Type of test:", value: testType.rawValue)
		closeQRDetails()
		app.tapButton("BackButton")
	}
	
	private func openQRDetails(for person: TestPerson) {
		app.tapButton("InformationButton")
		app.labelValuePairExist(label: "Naam / Name: ", value: person.name)
		app.labelValuePairExist(label: "Geboortedatum / Date of birth*:", value: formattedDate(of: person.birthDate, short: true))
	}
	
	private func closeQRDetails() {
		app.tapButton("Sluiten")
	}
}
