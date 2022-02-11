/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

extension BaseTest {
	
	func printOnScreenElements() {
		let debug = """
			----- BEGIN ELEMENTS -----
			Buttons: \(app.buttons.elementMap())
			Static Texts: \(app.staticTexts.elementMap())
			Text Fields: \(app.textFields.elementMap())
			Text Views: \(app.textViews.elementMap())
			Links: \(app.links.elementMap())
			Other Elements: \(app.otherElements.elementMap())
			------ END ELEMENTS ------
		"""
		print(debug)
	}
	
	func printOnScreenWebElements() {
		let debug = """
			----- BEGIN ELEMENTS -----
			Buttons: \(safari.webViews.buttons.elementMap())
			Static Texts: \(safari.webViews.staticTexts.elementMap())
			Text Fields: \(safari.webViews.textFields.elementMap())
			Text Views: \(safari.webViews.textViews.elementMap())
			Secure Text Fields: \(safari.webViews.secureTextFields.elementMap())
			------ END ELEMENTS ------
		"""
		print(debug)
	}
}
