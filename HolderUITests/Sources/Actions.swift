/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension BaseTest {
	
	func addEvent() {
		tapOtherElement("Open menu")
		tapButton("Vaccinatie of test toevoegen")
	}
	
	func addVaccinationCertificate(for person: TestPerson) {
		addEvent()
		tapButton("Vaccinatie. Ik heb een (booster)vaccinatie gehad")
		tapText("Log in met DigiD")
		retrieveCertificateFromServer(for: person)
	}
	
	func addRecoveryCertificate(for person: TestPerson) {
		addEvent()
		tapButton("Positieve test. Uit de test blijkt dat ik corona heb gehad")
		tapText("Log in met DigiD")
		retrieveCertificateFromServer(for: person)
	}
	
	func addTestCertificateFromGGD(for person: TestPerson) {
		addEvent()
		tapButton("Negatieve test. Uit de test blijkt dat ik geen corona heb")
		tapButton("GGD")
		tapText("Log in met DigiD")
		retrieveCertificateFromServer(for: person)
	}
	
	func retrieveCertificateFromServer(for person: TestPerson) {
		
		XCTAssertTrue(safari.wait(for: .runningForeground, timeout: self.timeout))
		makeScreenShot(name: "Safari is ready")
		
		let loggedIn = safari.webViews.staticTexts["DigiD MOCK"].waitForExistence(timeout: self.timeout)
		makeScreenShot(name: "Logged in: " + loggedIn.description)
		
		if !loggedIn { loginToServer() }
		
		let textField = waitFor(element: safari.webViews.textFields.firstMatch, type: "TextField BSN")
		textField.clear()
		textField.typeText(person.bsn)
		makeScreenShot(name: "BSN typed")
		
		let submit = waitFor(element: safari.webViews.staticTexts["Login / Submit"], type: "Button Login / Submit")
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
		
		let username = waitFor(element: safari.webViews.textFields["User Name"], type: "Textfield Username")
		username.tap()
		username.typeText("coronacheck")
		makeScreenShot(name: "Username typed")
		
		let continueButton = safari.buttons["Continue"]
		if continueButton.waitForExistence(timeout: self.timeout) {
			continueButton.tap()
			makeScreenShot(name: "Hide continue button")
		}
		
		let password = waitFor(element: safari.webViews.secureTextFields["Password"], type: "TextField Password")
		password.tap()
		password.typeText(authPassword)
		makeScreenShot(name: "Password typed")
		
		let submitAuth = waitFor(element: safari.webViews.buttons["Log In"], type: "Button Log in")
		submitAuth.tap()
		makeScreenShot(name: "Auth submit button")
	}
	
	func addRetrievedCertificateToApp(for person: TestPerson? = nil) {
		makeScreenShot(name: "Back in app")
		textExists("Kloppen de gegevens?")
		if let person = person {
			textContains("Naam: " + person.name!)
		}
		tapText("Maak bewijs")
	}
}
