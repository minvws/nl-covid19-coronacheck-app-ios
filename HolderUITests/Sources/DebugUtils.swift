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
   Parent: \(debugDescription)
   Buttons: \(buttons.elementMap())
   Static Texts: \(staticTexts.elementMap())
   Text Fields: \(textFields.elementMap())
   Text Views: \(textViews.elementMap())
   Links: \(links.elementMap())
   Other Elements: \(otherElements.elementMap())
   ------ END ELEMENTS ------
  """
		print(debug)
	}
	
	func printChildWebElements() {
		let debug = """
   ----- BEGIN ELEMENTS -----
   Buttons: \(webViews.buttons.elementMap())
   Static Texts: \(webViews.staticTexts.elementMap())
   Text Fields: \(webViews.textFields.elementMap())
   Text Views: \(webViews.textViews.elementMap())
   Secure Text Fields: \(webViews.secureTextFields.elementMap())
   ------ END ELEMENTS ------
  """
		print(debug)
	}
}
