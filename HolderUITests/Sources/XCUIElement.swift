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
	
	private func waitAndTap() {
		self.assertExistence().tap()
	}
	
	func tapElement(type: ElementType, _ label: String, _ index: Int) {
		let elementQuery = self.descendants(matching: type)
		let element = elementQuery.element(matching: type, identifier: label)
		element.waitAndTap()
	}
	
	func tapButton(_ label: String, index: Int = 0) {
		tapElement(type: .button, label, index)
	}
	
	func tapText(_ label: String, index: Int = 0) {
		tapElement(type: .staticText, label, index)
	}
	
	func tapOther(_ label: String, index: Int = 0) {
		tapElement(type: .other, label, index)
	}
	
	func textExists(_ label: String) {
		_ = self.staticTexts[label].assertExistence()
	}
	
	func labelValuePairExist(label: String, value: String) {
		let texts = self.staticTexts.allElementsBoundByIndex
		
		var checkNext = false
		for text in texts {
			if text.label == label {
				checkNext = true
				continue
			}
			if checkNext {
				XCTAssertEqual(text.label, value)
				break
			}
		}
	}
	
	func linkExists(_ label: String) {
		_ = self.links[label].assertExistence()
	}
	
	func containsText(_ text: String) {
		let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
		let elementQuery = self.descendants(matching: .any)
		let element = elementQuery.element(matching: predicate)
		_ = element.assertExistence()
	}
}
