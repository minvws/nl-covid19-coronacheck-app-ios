/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	
	func addVaccinationCertificate(for person: TestPerson) {
		addEvent()
		app.tapButton("Vaccinatie. Ik heb een (booster)vaccinatie gehad")
		app.tapText("Log in met DigiD")
		retrieveCertificateFromServer(for: person)
	}
	
	func addRecoveryCertificate(for person: TestPerson) {
		addEvent()
		app.tapButton("Positieve test. Uit de test blijkt dat ik corona heb gehad")
		app.tapText("Log in met DigiD")
		retrieveCertificateFromServer(for: person)
	}
	
	func addTestCertificateFromGGD(for person: TestPerson) {
		addEvent()
		app.tapButton("Negatieve test. Uit de test blijkt dat ik geen corona heb")
		app.tapButton("GGD")
		app.tapText("Log in met DigiD")
		retrieveCertificateFromServer(for: person)
	}
	
	func retrieveCertificateFromServer(for person: TestPerson) {
		
		XCTAssertTrue(safari.wait(for: .runningForeground, timeout: self.loginTimeout))
		makeScreenShot(name: "Safari is ready")
		
		let loggedIn = safari.webViews.staticTexts["DigiD MOCK"].waitForExistence(timeout: self.loginTimeout)
		makeScreenShot(name: "Logged in: " + loggedIn.description)
		
		if !loggedIn { loginToServer() }
		
		let textField = safari.webViews.textFields.firstMatch.assertExistence()
		textField.clearText()
		textField.typeText(person.bsn)
		makeScreenShot(name: "BSN typed")
		
		let submit = safari.webViews.staticTexts["Login / Submit"].assertExistence()
		submit.tap()
		makeScreenShot(name: "BSN submit button")
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
		
		let username = safari.webViews.textFields["User Name"].assertExistence()
		username.tap()
		username.typeText("coronacheck")
		makeScreenShot(name: "Username typed")
		
		let continueButton = safari.buttons["Continue"]
		if continueButton.waitForExistence(timeout: self.loginTimeout) {
			continueButton.tap()
			makeScreenShot(name: "Hide continue button")
		}
		
		let password = safari.webViews.secureTextFields["Password"].assertExistence()
		password.tap()
		password.typeText(authPassword)
		makeScreenShot(name: "Password typed")
		
		let submitAuth = safari.webViews.buttons["Log In"].assertExistence()
		submitAuth.tap()
		makeScreenShot(name: "Auth submit button")
	}
	
	func addRetrievedCertificateToApp() {
		app.textExists("Kloppen de gegevens?")
		makeScreenShot(name: "Back in app")
		app.tapText("Maak bewijs")
	}
}
