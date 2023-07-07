/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckTest

extension XCUIElement {
	
	private static let timeout = 15.0
	
	func clearText() {
		guard let stringValue = value as? String else {
			XCTFail("Tried to clear and enter text into a non string value")
			return
		}
		
		let lowerRightCorner = coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
		lowerRightCorner.tap()
		
		let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
		typeText(deleteString)
	}
	
	func assertExistence() -> XCUIElement {
		let elementPresent = rapidlyEvaluate(timeout: XCUIElement.timeout) { self.exists }
		XCTAssertTrue(elementPresent, "\(description) could not be found")
		return self
	}
	
	func assertNotExistence() {
		let elementPresent = rapidlyEvaluate(timeout: 1.0) { self.exists }
		XCTAssertFalse(elementPresent, "\(debugDescription) could be found")
	}
	
	func tapButton(_ label: String, index: Int = 0) {
		let predicate = NSPredicate(format: "label beginswith[c] %@", label)
		let elementQuery = descendants(matching: .any).matching(predicate)
		let element = elementQuery.element(boundBy: index)
		element.assertExistence().tap()
	}
	
	func enableSwitch(_ label: String) {
		let element = switches[label]
		element.assertExistence().tap()
		XCTAssertTrue(element.isEnabled)
	}
	
	func textExists(_ label: String) {
		_ = staticTexts[label].assertExistence()
	}
	
	func textNotExists(_ label: String) {
		staticTexts[label].assertNotExistence()
	}
	
	func labelValuePairExist(label: String, value: String) {
		let elementLabel = [label, value].joined(separator: ",")
		_ = otherElements[elementLabel].assertExistence()
	}
	
	func containsText(_ text: String) {
		let elementQuery = descendants(matching: .any)
		let predicate = NSPredicate(format: "label contains[c] %@", text)
		let element = elementQuery.element(matching: predicate)
		_ = element.assertExistence()
	}
	
	func containsValue(_ text: String) {
		let elementQuery = descendants(matching: .any)
		let predicate = NSPredicate(format: "value contains[c] %@", text)
		let element = elementQuery.element(matching: predicate)
		_ = element.assertExistence()
	}
}
