/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class VisitorPassTest: BaseTest {
	
	override func setUpWithError() throws {
		self.disclosureMode = DisclosureMode.mode3G
		
		try super.setUpWithError()
	}
	
	let assessmentDate = Date("2022-09-27")
	let vaccinationAssessment = "ZZZ-47Z2Q8FZ3VL3QQ-92"
	let vaccinationAssessmentToken = "333333"
	let negativeTest = "ZZZ-QB858FYFT7ZLUU-72"
	let negativetestToken = "123456"
	let fullName = "de Beer, Boris"
	let birthDate = Date("1971-07-31")

	func test_vaccinationAssessmentPlusNegativeTest() {

		// Add vaccination assessment
		addVaccinationAssessment(for: vaccinationAssessment, with: vaccinationAssessmentToken)

		// Check data
		app.textExists("Vaccinatiebeoordeling")
		app.textExists("Beoordelingsdatum: " + assessmentDate.toString(.recently))
		app.textExists("Naam: " + fullName)
		app.textExists("Geboortedatum: " + birthDate.toString(.written))
		let vacAssessment = storeRetrievedCertificateDetails()

		// Continue
		app.tapButton("Toevoegen")

		// Overview
		assertVaccinationAssessmentIncomplete()

		// Add negative test
		app.tapButton("Maak bewijs compleet")
		app.tapButton("Testuitslag ophalen")

		// Retrieval code
		let retrievalField = app.textFields["Ophaalcode"]
		retrievalField.tap()
		retrievalField.typeText(negativeTest)
		app.tapButton("Volgende", index: 1)

		// Verification code
		app.containsText("Verificatiecode")
		let verificationField = app.textFields["Verificatiecode"]
		verificationField.tap()
		verificationField.typeText(negativetestToken)
		app.tapButton("Volgende")

		// Check data
		app.textExists("Negatieve testuitslag")
		app.containsText("Testdatum: " + assessmentDate.toString(.recently))
		app.textExists("Naam: " + fullName)
		app.textExists("Geboortedatum: " + birthDate.toString(.written))
		let negativeTest = storeRetrievedCertificateDetails()

		// Continue
		app.tapButton("Maak bewijs")

		// Overview
		assertValidDutchAssessmentCertificate(validUntilDate: assessmentDate.offset(14))
		assertAssessmentNotValidInternationally()
		let neg = NegativeTest(eventDate: assessmentDate, testType: .pcr)
		assertInternationalTest(of: neg)
		
		// Wallet
		viewWallet()
		assertWalletItem(ofType: .negative, with: negativeTest)
		assertWalletItem(ofType: .vaccinationAssessment, with: vacAssessment)
	}
	
	func test_negativeTestPlusVaccinationAssessment() {
		
		// Add negative test
		addCommercialTestCertificate(for: negativeTest, with: negativetestToken)
		
		// Check data
		app.textExists("Negatieve testuitslag")
		app.containsText("Testdatum: " + assessmentDate.toString(.recently))
		app.textExists("Naam: " + fullName)
		app.textExists("Geboortedatum: " + birthDate.toString(.written))
		let negativeTest = storeRetrievedCertificateDetails()

		// Continue
		app.tapButton("Maak bewijs")
		
		// Add vaccination assessment
		addVaccinationAssessment(for: vaccinationAssessment, with: vaccinationAssessmentToken)

		// Check data
		app.textExists("Vaccinatiebeoordeling")
		app.textExists("Beoordelingsdatum: " + assessmentDate.toString(.recently))
		app.textExists("Naam: " + fullName)
		app.textExists("Geboortedatum: " + birthDate.toString(.written))
		let vacAssessment = storeRetrievedCertificateDetails()

		// Continue
		app.tapButton("Toevoegen")

		// Overview
		assertValidDutchAssessmentCertificate(validUntilDate: assessmentDate.offset(14))
		assertAssessmentNotValidInternationally()
		let neg = NegativeTest(eventDate: assessmentDate, testType: .pcr)
		assertInternationalTest(of: neg)
		
		// Wallet
		viewWallet()
		assertWalletItem(ofType: .negative, with: negativeTest)
		assertWalletItem(ofType: .vaccinationAssessment, with: vacAssessment)
	}
	
	func test_visitorPassErrors() {
		let incorrectCode = "A"
		
		addVaccinationAssessment()

		// Assert screen
		app.textExists("Vaccinatiebeoordeling ophalen")
		app.textNotExists("Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: VAC-YYYYYYYYY1-F2.")

		// Assert info sheet
		app.textExists("Heb je geen beoordelingscode?")
		app.tapButton("Heb je geen beoordelingscode?")
		app.containsValue("Je krijgt een beoordelingscode van de balie waar je vaccinatie is beoordeeld.")
		app.containsValue("Deze code heb je geprint gekregen. Heb je geen beoordelingscode? Ga dan terug naar de balie waar je bent geweest.")
		app.tapButton("Sluiten")

		// Incorrect retrieval code
		let retrievalField = app.textFields["Beoordelingscode"]
		retrievalField.tap()
		retrievalField.typeText(incorrectCode)
		app.staticTexts["Volgende"].tap()
		app.containsValue("Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: VAC-YYYYYYYYY1-F2.")

		// Correct retrieval code
		retrievalField.clearText()
		retrievalField.typeText(vaccinationAssessment)
		app.staticTexts["Volgende"].tap()

		app.textNotExists("Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: VAC-YYYYYYYYY1-F2.")
		app.textExists("Verificatiecode")
		app.textExists("Je krijgt een code via sms of e-mail")

		// Incorrect verification code
		let verificationField = app.textFields["Verificatiecode"]
		verificationField.tap()
		verificationField.typeText(incorrectCode)
		app.staticTexts["Volgende"].tap()
		app.containsValue("Geen geldige combinatie. Vul de 6-cijferige verificatiecode in.")

		// Assert info dialog
		app.tapButton("Geen verificatiecode gekregen?")
		app.textExists("Geen verificatiecode gekregen?")
		app.textExists("Je krijgt de verificatiecode via een sms of e-mail. Niks gekregen? Klik hieronder op ‘stuur opnieuw’ voor een nieuwe code.")
		app.tapButton("Sluiten")

		// Correct verification code
		verificationField.clearText()
		verificationField.typeText(vaccinationAssessmentToken)
		app.staticTexts["Volgende"].tap()
		app.textNotExists("Geen geldige combinatie. Vul de 6-cijferige verificatiecode in.")
	}
}
