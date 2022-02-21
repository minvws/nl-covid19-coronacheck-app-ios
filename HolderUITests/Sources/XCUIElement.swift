/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension XCUIElement {
	
	func clearText() {
		guard let stringValue = self.value as? String else {
			XCTFail("Tried to clear and enter text into a non string value")
			return
		}
		
		let lowerRightCorner = self.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
		lowerRightCorner.tap()
		
		let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
		self.typeText(deleteString)
	}
	
	func assertExistence() -> XCUIElement {
		let timeout = 30.0
		let elementPresent = self.waitForExistence(timeout: timeout)
		XCTAssertTrue(elementPresent, self.elementType.rawValue.description + " could not be found: " + self.description)
		return self
	}
	
	private func waitAndTap() {
		self.assertExistence().tap()
	}
	
	func tapButton(_ label: String) {
		self.buttons[label].waitAndTap()
	}
	
	func tapText(_ label: String) {
		self.staticTexts[label].waitAndTap()
	}
	
	func tapOther(_ label: String) {
		self.otherElements[label].waitAndTap()
	}
	
	func textExists(_ label: String) {
		_ = self.assertExistence()
	}
	
	func linkExists(_ label: String) {
		_ = self.assertExistence()
	}
	
	func containsText(_ text: String, count: Int = 1) {
		let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
		let elementQuery = self.children(matching: .any).containing(predicate)
		XCTAssertTrue(elementQuery.count == count, "text could not be found: " + text)
	}
}
