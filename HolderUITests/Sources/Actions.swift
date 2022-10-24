/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension BaseTest {
	
	func addEvent() {
		app.tapButton("Open menu")
		app.tapButton("Vaccinatie of test toevoegen")
	}
	
	func addScannedQR() {
		app.tapButton("Open menu")
		app.tapButton("Coronabewijs inscannen")
		app.tapButton("Start scannen")
		app.tapButton("Bewijs toevoegen")
		waitUntilSpinnerIsGone()
	}
	
	func addVisitorPass() {
		app.tapButton("Open menu")
		app.tapButton("Bezoekersbewijs toevoegen")
		app.tapButton("Volgende")
	}
	
	private func viewQR(of certificate: CertificateType, label: String, hiddenQR: Bool) {
		card(of: certificate).tapButton(label)
		if hiddenQR { assertHiddenQR() }
	}
	
	private func assertHiddenQR() {
		app.containsText("QR-code is verborgen")
		app.containsText("Wat betekent dit?")
		app.containsText("Laat toch zien")
		app.tapButton("Wat betekent dit?")
		app.textExists("Verborgen QR-code")
		app.tapButton("Sluiten")
		app.tapButton("Laat toch zien")
		app.textNotExists("QR-code is verborgen")
	}
	
	func viewQRCode(of certificate: CertificateType, hiddenQR: Bool = false) {
		viewQR(of: certificate, label: "Bekijk QR", hiddenQR: hiddenQR)
	}
	
	func viewQRCodes(of	certificate: CertificateType, hiddenQR: Bool = false) {
		viewQR(of: certificate, label: "Bekijk QR-codes", hiddenQR: hiddenQR)
	}
	
	func viewPreviousQR(hidden: Bool = false) {
		app.tapButton("Vorige QR-code")
		if hidden { assertHiddenQR() }
	}
	
	func addVaccinationCertificate(for bsn: String, combinedWithPositiveTest: Bool = false) {
		addEvent()
		app.tapButton("Vaccinatie. Ik heb een (booster)vaccinatie gehad")
		if combinedWithPositiveTest { app.enableSwitch("Haal ook mijn positieve testuitslag op") }
		app.tapButton("Log in met DigiD")
		retrieveCertificateFromServer(for: bsn)
	}
	
	func addRecoveryCertificate(for bsn: String) {
		addEvent()
		app.tapButton("Positieve test. Uit de test blijkt dat ik corona heb gehad")
		app.tapButton("Log in met DigiD")
		retrieveCertificateFromServer(for: bsn)
	}
	
	func addTestCertificateFromGGD(for bsn: String) {
		addEvent()
		app.tapButton("Negatieve test. Uit de test blijkt dat ik geen corona heb")
		app.tapButton("GGD")
		app.tapButton("Log in met DigiD")
		retrieveCertificateFromServer(for: bsn)
	}
	
	func addCommercialTestCertificate(for retrievalCode: String? = nil, with verificationCode: String? = nil) {
		addEvent()
		app.tapButton("Negatieve test. Uit de test blijkt dat ik geen corona heb")
		app.tapButton("Andere testlocatie")
		
		if let retrievalCode = retrievalCode {
			let retrievalField = app.textFields["Ophaalcode"]
			retrievalField.tap()
			retrievalField.typeText(retrievalCode)
			app.tapButton("Volgende", index: 1)
		}
		
		if let verificationCode = verificationCode {
			app.containsText("Verificatiecode")
			let verificationField = app.textFields["Verificatiecode"]
			verificationField.tap()
			verificationField.typeText(verificationCode)
			app.tapButton("Volgende")
		}
	}
	
	func addVaccinationAssessment(for approvalCode: String? = nil, with verificationCode: String? = nil) {
		addVisitorPass()
		
		if let approvalCode = approvalCode {
			let approvalField = app.textFields["Beoordelingscode"]
			approvalField.tap()
			approvalField.typeText(approvalCode)
			app.tapButton("Volgende", index: 1)
		}
		
		if let verificationCode = verificationCode {
			let verificationField = app.textFields["Verificatiecode"]
			verificationField.tap()
			verificationField.typeText(verificationCode)
			app.tapButton("Volgende")
		}
	}
	
	private func retrieveCertificateFromServer(for bsn: String) {
		
		XCTAssertTrue(safari.wait(for: .runningForeground, timeout: self.loginTimeout))
		makeScreenShot(name: "Safari is ready")
		
		let loggedIn = safari.webViews.staticTexts["DigiD MOCK"].waitForExistence(timeout: self.loginTimeout)
		makeScreenShot(name: "Logged in: \(loggedIn.description)")
		
		if !loggedIn { loginToServer() }
		
		let textField = safari.webViews.textFields.firstMatch.assertExistence()
		textField.clearText()
		textField.typeText(bsn)
		makeScreenShot(name: "BSN typed")
		
		let submit = safari.webViews.staticTexts["Login / Submit"].assertExistence()
		submit.tap()
		makeScreenShot(name: "BSN submit button")
		
		let predicate = NSPredicate(format: "label contains[c] %@", "Open this page in")
		let elementQuery = safari.webViews.textViews.matching(predicate)
		let popup = elementQuery.firstMatch.waitForExistence(timeout: 5.0)
		if popup { safari.webViews.buttons["Open"].tap() }
	}
	
	private func loginToServer() {
		guard let authPassword = ProcessInfo.processInfo.environment["ACCEPTANCE_BASIC_AUTH_PASSWORD"] else {
			XCTFail("The password could not be found.")
			return
		}
		guard !authPassword.isEmpty else {
			XCTFail("The password is empty")
			return
		}

		let dutchDialog = safari.textFields["Gebruikersnaam"].waitForExistence(timeout: 3.0)
		
		let username = safari.textFields[dutchDialog ? "Gebruikersnaam" : "User Name"]
		username.tap()
		username.typeText("coronacheck")
		makeScreenShot(name: "Username typed")
		
		let continueButton = safari.buttons["Continue"]
		if rapidlyEvaluate(timeout: self.loginTimeout, { continueButton.exists }) {
			continueButton.tap()
			makeScreenShot(name: "Hide continue button")
		}
		
		let password = safari.secureTextFields[dutchDialog ? "Wachtwoord" : "Password"]
		password.tap()
		password.typeText(authPassword)
		makeScreenShot(name: "Password typed")
		
		let submitAuth = safari.buttons[dutchDialog ? "Log in" : "Log In"]
		submitAuth.tap()
		makeScreenShot(name: "Auth submit button")
	}
	
	func addRetrievedCertificateToApp() {
		makeScreenShot(name: "Back in app")
		app.textExists("Kloppen de gegevens?")
		waitUntilSpinnerIsGone()
		makeScreenShot(name: "Data retrieval screen")
		app.tapButton("Maak bewijs")
		waitUntilSpinnerIsGone()
	}
	
	private func waitUntilSpinnerIsGone() {
		let element = app.descendants(matching: .activityIndicator).firstMatch
		let predicate = NSPredicate(format: "exists == false")
		self.expectation(for: predicate, evaluatedWith: element, handler: nil)
		self.waitForExpectations(timeout: self.loginTimeout, handler: nil)
	}
	
	func viewWallet() {
		app.tapButton("Open menu")
		app.tapButton("Over deze app")
		app.tapButton("Opgeslagen gegevens")
		app.textExists("Mijn opgeslagen gegevens")
	}
	
	func returnFromWalletToOverview() {
		app.tapButton("Terug")
		app.tapButton("Terug")
		app.tapButton("Terug")
	}
	
	func storeRetrievedCertificateDetails(atIndex: Int = 0) -> Set<String> {
		app.tapButton("Details", index: atIndex)
		makeScreenShot(name: "Details \(atIndex)")
		let result = app.otherElements["RemoteEventDetailsView"].descendants(matching: .other).mapLabelsToSet()
		app.tapButton("Sluiten")
		return result
	}
	
	func deleteItemFromWallet(atIndex: Int = 0, confirm: Bool = true) {
		app.tapButton("Uit de app verwijderen", index: atIndex)
		app.textExists("Deze gegevens verwijderen?")
		app.tapButton(confirm ? "Verwijderen" : "Annuleer")
		waitUntilSpinnerIsGone()
	}
	
	func resetApp(confirm: Bool = true) {
		app.tapButton("Open menu")
		app.tapButton("Over deze app")
		app.tapButton("App resetten")
		app.tapButton(confirm ? "Reset app" : "Annuleer")
		if !confirm {
			app.tapButton("Terug")
			app.tapButton("Terug")
		}
	}
}
