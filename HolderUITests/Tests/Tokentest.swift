/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class Tokentest: BaseTest {
	
	let testDate = Date()
	let birthDate = Date("1971-07-31")
	let fullName = "de Beer, Boris"
	let verificationCode = "123456"
	
	func test_retrieveTokenWithVerificationCode() {
		let retrievalCode = "ZZZ-ZT66URU6TY2J96-32"
		addCommercialTestCertificate(for: retrievalCode, with: verificationCode)
		
		app.containsText("Kloppen de gegevens?")
		
		app.tapButton("Details")
		app.containsText("Naam: " + fullName)
		app.containsText("Geboortedatum: " + birthDate.toString(.written))
		app.containsText("Testdatum: " + testDate.toString(.recently))
		app.containsText("Testuitslag: negatief (geen coronavirus vastgesteld)")
		app.tapButton("Sluiten")
		
		app.tapButton("Maak bewijs")
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_retrieveTokenWithoutVerificationCode() {
		let retrievalCode = "ZZZ-FZB3CUYL55U7ZT-R2"
		addCommercialTestCertificate(for: retrievalCode)
		
		app.containsText("Kloppen de gegevens?")
		
		app.tapButton("Details")
		app.containsText("Naam: " + fullName)
		app.containsText("Geboortedatum: " + birthDate.toString(.written))
		app.containsText("Testdatum: " + testDate.toString(.recently))
		app.containsText("Testuitslag: negatief (geen coronavirus vastgesteld)")
		app.tapButton("Sluiten")
		
		app.tapButton("Maak bewijs")
		
		assertValidInternationalTestCertificate(testType: .pcr)
	}
	
	func test_tokenRetrievalErrors() {
		let retrievalCode = "ZZZ-ZT66URU6TY2J96-32"
		
		addCommercialTestCertificate()
		
		// Assert screen
		app.containsText("Testuitslag ophalen")
		app.textNotExists("Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: BRB-YYYYYYYYY1-Z2.")
		
		// Assert info sheet
		app.textExists("Heb je geen ophaalcode?")
		app.tapButton("Heb je geen ophaalcode?")
		
		app.containsValue("Je krijgt van de testlocatie een ophaalcode met cijfers en letters.")
		app.containsValue("Heb je geen code gekregen? Of ben je deze kwijtgeraakt? Neem dan contact op met je testlocatie.")
		app.tapButton("Sluiten")
		
		// No retrieval code
		let retrievalField = app.textFields["Ophaalcode"]
		retrievalField.tap()
		retrievalField.typeText("")
		app.staticTexts["Volgende"].tap()
		app.containsValue("Graag eerst een ophaalcode invullen")
		
		// Incorrect retrieval code
		retrievalField.tap()
		retrievalField.typeText("incorrect")
		app.staticTexts["Volgende"].tap()
		app.containsValue("Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: BRB-YYYYYYYYY1-Z2.")
		
		// Correct retrieval code
		retrievalField.clearText()
		retrievalField.typeText(retrievalCode)
		app.staticTexts["Volgende"].tap()
		
		app.textNotExists("Deze code is niet geldig. Een code ziet er bijvoorbeeld zo uit: BRB-YYYYYYYYY1-Z2.")
		app.containsText("Verificatiecode")
		app.containsText("Je krijgt een code via sms of e-mail")
		
		// No verification code
		let verificationField = app.textFields["Verificatiecode"]
		verificationField.tap()
		verificationField.typeText("")
		app.staticTexts["Volgende"].tap()
		app.containsValue("Graag eerst een verificatiecode invullen")
		
		// Incorrect verification code
		verificationField.tap()
		verificationField.typeText("incorrect")
		app.staticTexts["Volgende"].tap()
		app.containsValue("Geen geldige combinatie. Vul de 6-cijferige verificatiecode in.")
		
		// Assert info dialog
		app.tapButton("Geen verificatiecode gekregen?")
		app.textExists("Geen verificatiecode gekregen?")
		app.textExists("Je krijgt de verificatiecode via een sms of e-mail. Niks gekregen? Klik hieronder op ‘stuur opnieuw’ voor een nieuwe code.")
		app.tapButton("Sluiten")
		
		// Correct verification code
		verificationField.clearText()
		verificationField.typeText(verificationCode)
		app.staticTexts["Volgende"].tap()
		app.textNotExists("Geen geldige combinatie. Vul de 6-cijferige verificatiecode in.")
	}
}
