/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension XCUIElement {
	
	func printChildElements() {
		let debug = """
			----- BEGIN ELEMENTS -----
			Parent: \(self.description)
			Buttons: \(self.buttons.elementMap())
			Static Texts: \(self.staticTexts.elementMap())
			Text Fields: \(self.textFields.elementMap())
			Text Views: \(self.textViews.elementMap())
			Links: \(self.links.elementMap())
			Other Elements: \(self.otherElements.elementMap())
			------ END ELEMENTS ------
		"""
		print(debug)
	}
	
	func printChildWebElements() {
		let debug = """
			----- BEGIN ELEMENTS -----
			Buttons: \(self.webViews.buttons.elementMap())
			Static Texts: \(self.webViews.staticTexts.elementMap())
			Text Fields: \(self.webViews.textFields.elementMap())
			Text Views: \(self.webViews.textViews.elementMap())
			Secure Text Fields: \(self.webViews.secureTextFields.elementMap())
			------ END ELEMENTS ------
		"""
		print(debug)
	}
}
