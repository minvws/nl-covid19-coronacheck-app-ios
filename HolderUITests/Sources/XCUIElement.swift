/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension XCUIElement {
	
	private static let timeout = 30.0
	
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
		let elementPresent = self.waitForExistence(timeout: XCUIElement.timeout)
		XCTAssertTrue(elementPresent, self.description + " could not be found")
		return self
	}
	
	func tapButton(_ label: String) {
		let elementQuery = self.descendants(matching: .button).matching(identifier: label)
		let predicate = NSPredicate(format: "isEnabled == true")
		let element = elementQuery.element(matching: predicate).firstMatch
		element.assertExistence().tap()
	}
	
	func textExists(_ label: String) {
		_ = self.staticTexts[label].assertExistence()
	}
	
	func labelValuePairExist(label: String, value: String) {
		let elementLabel = [label, value].joined(separator: ",")
		_ = self.otherElements[elementLabel].assertExistence()
	}
	
	func containsText(_ text: String) {
		let elementQuery = self.descendants(matching: .any)
		let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
		let element = elementQuery.element(matching: predicate)
		_ = element.assertExistence()
	}
}
