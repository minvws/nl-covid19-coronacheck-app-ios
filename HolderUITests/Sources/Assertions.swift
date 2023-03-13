/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension BaseTest {
	
	// MARK: General
	
	func assertNoCertificateRetrieved() {
		assertNoInternationalCertificate()
	}
	
	func assertRemovedCertificates(events: [Event]) {
		app.textExists("Mijn bewijzen")
		let message = "Je gegevens zijn bijgewerkt. Mogelijk zijn daardoor bewijzen weg."
		let notification = app.otherElements.containing(.staticText, identifier: message).allElementsBoundByIndex.last
		notification?.tapButton("Lees meer")
		
		app.textExists("Bijgewerkte gegevens")
		for event in events {
			app.containsText(event.type.rawValue)
			app.containsValue(event.eventDate.toString(.written))
		}
	}
	
	// MARK: - Certificate retrieval
	
	func assertSomethingWentWrong(error: String = "") {
		app.textExists("Sorry, er gaat iets mis")
		if !error.isEmpty {
			app.containsValue(error)
		}
		proceedToOverview()
	}
	
	func assertNoVaccinationsAvailable() {
		app.textExists("Geen vaccinaties beschikbaar")
		proceedToOverview()
	}
	
	func assertNoCertificateCouldBeCreated(error: String = "") {
		app.textExists("We kunnen geen bewijs maken")
		if !error.isEmpty {
			app.containsValue(error)
		}
		proceedToOverview()
	}
	
	func assertPositiveTestResultNotValidAnymore() {
		guard disclosureMode != .mode0G else { return }
		app.textExists("Positieve testuitslag niet meer geldig")
		proceedToOverview()
	}
	
	func assertCertificateIsOnlyValidInternationally() {
		app.textExists("Er is alleen een internationaal bewijs gemaakt")
		app.containsValue("Van je opgehaalde gegevens kon alleen een internationaal vaccinatiebewijs worden gemaakt.")
		proceedToOverview()
	}
	
	func assertNoTestresultIsAvailable() {
		app.textExists("Geen testuitslag beschikbaar")
		proceedToOverview()
	}
	
	func assertHintForInternationalVaccinationAndRecoveryCertificate() {
		app.textExists("Vaccinatiebewijs en herstelbewijs gemaakt")
		app.containsValue("Van je opgehaalde vaccinaties kon alleen een internationaal vaccinatiebewijs worden gemaakt.")
		app.containsValue("Van je positieve testuitslag kon ook een herstelbewijs gemaakt worden.")
		proceedToOverview()
	}
	
	func assertHintForVaccinationAndRecoveryCertificate() {
		app.textExists("Vaccinatiebewijs en herstelbewijs gemaakt")
		app.containsValue("Van je opgehaalde vaccinaties is een vaccinatiebewijs gemaakt.")
		app.containsValue("Van je positieve testuitslag kon ook een herstelbewijs worden gemaakt.")
		proceedToOverview()
	}
	
	func assertRetrievedCertificate(for person: TestPerson) {
		app.textExists("Kloppen de gegevens?")
		app.containsText("Naam: " + person.name)
		app.containsText("Geboortedatum: " + formattedDate(of: person.birthDate))
	}
	
	func assertRetrievedCertificateDetails(for person: TestPerson) {
		app.tapButton("Details")
		app.containsText("Naam: " + person.name)
		app.textExists("Geboortedatum: " + formattedDate(of: person.birthDate))
		app.tapButton("Sluiten")
	}
	
	func assertRetrievedVaccinationDetails(for person: Person, vaccination: Vaccination, position: Int = 0) {
		app.tapButton("Details", index: position)
		app.containsText("Naam: " + person.name)
		app.containsText("Geboortedatum: " + person.birthDate.toString(.written))
		app.containsText("Ziekteverwekker: " + vaccination.disease)
		app.containsText("Vaccin: " + vaccination.vaccine.rawValue)
		app.containsText("Vaccinatiedatum: " + vaccination.eventDate.toString(.written))
		app.containsText("Gevaccineerd in: " + vaccination.country)
		
		app.tapButton("Sluiten")
	}
	
	func assertDisclosureMessages() {
		switch disclosureMode {
			case .mode0G:
				app.textExists("In Nederland wordt het coronabewijs niet meer gebruikt. Daarom staan er alleen nog internationale bewijzen in de app.")
			case .mode3G:
				tapOnTheNetherlandsTab()
				app.containsText("Op dit moment geeft een Nederlands bewijs 3G-toegang.")
			case .mode1G:
				tapOnTheNetherlandsTab()
				app.textExists("Je kunt een bewijs voor 1G-toegang toevoegen wanneer je negatief getest bent")
			case .mode1GWith3G:
				tapOnTheNetherlandsTab()
				app.textExists("De Nederlandse toegangsregels zijn veranderd. Er zijn nu aparte bewijzen voor plekken die 3G-toegang en 1G-toegang geven.")
		}
	}
	
	private func tapOnTheNetherlandsTab() {
		app.tapButton("Nederland")
	}
	
	// MARK: - International
	
	private func tapOnInternationalTab() {
		guard disclosureMode != .mode0G else {
			return
		}
		app.tapButton("Internationaal")
	}
	
	func assertNoInternationalCertificate() {
		tapOnInternationalTab()
		app.textExists("Hier komt jouw internationale bewijs")
	}
	
	func assertValidInternationalVaccinationCertificate(doses: [String], vaccinationDateOffsetInDays: Int = -30) {
		tapOnInternationalTab()
		card(of: .vaccination).containsText(CertificateType.vaccination.rawValue)
		for (index, dose) in doses.reversed().enumerated() {
			card(of: .vaccination).containsText("Dosis \(dose) Vaccinatiedatum: " + formattedOffsetDate(with: vaccinationDateOffsetInDays - (30 * index)))
		}
		card(of: .vaccination).containsText("Bekijk QR")
	}
	
	func assertInternationalVaccination(of vaccination: Vaccination, dose: String? = nil) {
		tapOnInternationalTab()
		card(of: .vaccination).containsText(vaccination.internationalEventCertificate)
		if let dose {
			card(of: .vaccination).containsText("Dosis \(dose)")
		}
		card(of: .vaccination).containsText("Vaccinatiedatum: " + vaccination.eventDate.toString(.written))
		card(of: .vaccination).containsText("Bekijk QR")
	}
	
	func assertValidInternationalRecoveryCertificate(validUntilOffsetInDays: Int) {
		tapOnInternationalTab()
		card(of: .recovery).containsText(CertificateType.recovery.rawValue)
		card(of: .recovery).containsText("Geldig tot " + formattedOffsetDate(with: validUntilOffsetInDays))
		card(of: .recovery).containsText("Bekijk QR")
	}
	
	func assertInternationalRecovery(of positiveTest: PositiveTest) {
		card(of: .recovery).containsText(positiveTest.internationalEventCertificate)
		card(of: .recovery).containsText("Geldig tot " + positiveTest.validUntil!.toString(.written))
		card(of: .recovery).containsText("Bekijk QR")
	}
	
	func assertValidInternationalTestCertificate(testType: TestCertificateType, testDateOffsetInDays: Int = 0) {
		tapOnInternationalTab()
		card(of: .test).containsText(CertificateType.test.rawValue)
		card(of: .test).containsText("Type test: " + testType.rawValue)
		card(of: .test).containsText("Testdatum: " + formattedOffsetDate(with: testDateOffsetInDays, withYear: false, withDay: true))
		card(of: .test).containsText("Bekijk QR")
	}
	
	func assertInternationalTest(of negativeTest: NegativeTest) {
		tapOnInternationalTab()
		if disclosureMode == .mode0G {
			card(of: .test).containsText(negativeTest.internationalEventCertificate)
		} else {
			card(of: .test).containsText(negativeTest.eventCertificate)
		}
		card(of: .test).containsText("Type test: " + negativeTest.testType.rawValue)
		card(of: .test).containsText("Testdatum: " + negativeTest.eventDate.toString(.recently))
		card(of: .test).containsText("Bekijk QR")
	}
	
	func assertCertificateIsNotValidInternationally(ofType certificateType: CertificateType) {
		guard disclosureMode != .mode0G else { return }
		tapOnInternationalTab()
		app.textExists("Je \(certificateType.rawValue.lowercased()) is niet internationaal geldig. Je hebt wel een Nederlands bewijs.")
	}
	
	func assertInternationalCertificateIsNotYetValid(ofType certificateType: CertificateType, validFromOffsetInDays: Int, validUntilOffsetInDays: Int) {
		tapOnInternationalTab()
		app.containsText(certificateType.rawValue)
		app.containsText("Geldig vanaf " + formattedOffsetDate(with: validFromOffsetInDays, withYear: false))
		app.containsText("tot " + formattedOffsetDate(with: validUntilOffsetInDays))
		app.containsText("Wordt automatisch geldig")
	}
	
	func assertAssessmentNotValidInternationally() {
		tapOnInternationalTab()
		app.textExists("Je bezoekersbewijs is niet geldig buiten Nederland")
	}
	
	// MARK: - International QR Details
	
	func assertInternationalVaccinationQRDetails(for person: TestPerson, vaccinationDateOffsetInDays: Int = -30) {
		let doses = person.doseIntl
		
		card(of: .vaccination).tapButton(doses.count > 1 ? "Bekijk QR-codes" : "Bekijk QR")
		for (index, dose) in doses.reversed().enumerated() {
			app.textExists("Dosis " + dose)
			
			openQRDetails(for: person)
			app.textExists("Over mijn dosis " + dose)
			app.labelValuePairExist(label: "Ziekteverwekker / Disease targeted:", value: "COVID-19")
			app.labelValuePairExist(label: "Dosis / Number in series of doses:", value: spreadDose(dose))
			
			let vacDate = formattedOffsetDate(with: vaccinationDateOffsetInDays - (30 * index), short: true)
			app.labelValuePairExist(label: "Vaccinatiedatum / Vaccination date*:", value: vacDate)
			
			closeQRDetails()
			
			if index != doses.indices.last {
				app.tapButton("Vorige QR-code")
			}
		}
		app.tapButton("Terug")
	}
	
	func assertInternationalVaccinationQR(of vaccination: Vaccination, dose: String? = nil, for person: Person? = nil) {
		if let dose {
			app.textExists("Dosis " + dose)
		}
		
		openQRDetails(for: person)
		if let dose = dose {
			app.textExists("Over mijn dosis " + dose)
		}
		app.labelValuePairExist(label: "Ziekteverwekker / Disease targeted:", value: vaccination.disease)
		app.labelValuePairExist(label: "Vaccin / Vaccine:", value: vaccination.vaccine.rawValue)
		if let dose {
			app.labelValuePairExist(label: "Dosis / Number in series of doses:", value: dose.map { String($0) }.joined(separator: " "))
		}
		app.labelValuePairExist(label: "Vaccinatiedatum / Vaccination date*:", value: vaccination.eventDate.toString(.dutch))
		app.labelValuePairExist(label: "Gevaccineerd in / Vaccinated in:", value: vaccination.countryInternational)
		
		closeQRDetails()
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
		app.tapButton("Terug")
	}
	
	func assertInternationalRecoveryQR(for positiveTest: PositiveTest, for person: Person? = nil) {
		card(of: .recovery).tapButton("Bekijk QR")
		app.textExists("Internationale QR")
		
		openQRDetails(for: person)
		app.textExists("Over mijn internationale QR-code")
		app.labelValuePairExist(label: "Ziekte waarvan hersteld / Disease recovered from:", value: positiveTest.disease)
		app.labelValuePairExist(label: "Testdatum / Test date:", value: positiveTest.eventDate.toString(.dutch))
		app.labelValuePairExist(label: "Getest in / Member state of test:", value: positiveTest.countryInternational)
		app.labelValuePairExist(label: "Geldig vanaf / Valid from*:", value: positiveTest.validFrom!.toString(.dutch))
		app.labelValuePairExist(label: "Geldig tot / Valid to*:", value:
									positiveTest.validUntil!.toString(.dutch))
		closeQRDetails()
		app.tapButton("Terug")
	}
	
	func assertInternationalTestQRDetails(for person: TestPerson, testType: TestCertificateType) {
		card(of: .test).tapButton("Bekijk QR")
		app.textExists("Internationale QR")
		
		openQRDetails(for: person)
		app.textExists("Over mijn internationale QR-code")
		app.labelValuePairExist(label: "Testuitslag / Test result:", value: "negatief (geen coronavirus vastgesteld) / negative (no coronavirus detected)")
		app.labelValuePairExist(label: "Type test / Test type:", value: testType.rawValue)
		closeQRDetails()
		app.tapButton("Terug")
	}
	
	private func openQRDetails(for person: Person? = nil) {
		openQRDetails()
		if let person {
			app.labelValuePairExist(label: "Naam / Name:", value: person.name)
			app.labelValuePairExist(label: "Geboortedatum / Date of birth*:", value: person.birthDate.toString(.dutch))
		}
	}
	
	private func openQRDetails(for person: TestPerson) {
		openQRDetails()
		app.labelValuePairExist(label: "Naam / Name:", value: person.name)
		app.labelValuePairExist(label: "Geboortedatum / Date of birth*:", value: formattedDate(of: person.birthDate, short: true))
	}
	
	private func openQRDetails() {
		app.tapButton("Details")
	}
	
	private func closeQRDetails() {
		app.tapButton("Sluiten")
	}
	
	// MARK: - Wallet
	
	func assertNoEventsInWallet() {
		app.textExists("Geen gegevens opgeslagen")
	}
	
	func assertWalletItem(ofType eventType: EventType, atIndex: Int = 0, with dataToCheck: Set<String>) {
		app.tapButton(eventType.rawValue, index: atIndex)
		let dataShown = app.otherElements["StoredEventDetailsView"].descendants(matching: .other).mapLabelsToSet()
		makeScreenShot(name: "Wallet item \(eventType.rawValue)@\(atIndex)")
		XCTAssertTrue(dataToCheck.isSubset(of: dataShown))
		app.tapButton("Terug")
	}
	
	func assertAmountOfWalletItems(ofType eventType: EventType, is expectedAmount: Int) {
		let predicate = NSPredicate(format: "label contains[c] %@", eventType.rawValue)
		let items = app.descendants(matching: .button).matching(predicate)
		XCTAssertEqual(items.count, expectedAmount)
	}
}
