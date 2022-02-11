/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension BaseTest {
	
	func waitFor(element: XCUIElement, type: String = "Element") -> XCUIElement {
		let elementPresent = element.waitForExistence(timeout: self.timeout)
		XCTAssertTrue(elementPresent, type + " could not be found: " + element.description)
		return element
	}
	
	func tapButton(_ label: String) {
		let buttonElement = waitFor(element: app.buttons[label], type: "Button")
		buttonElement.tap()
	}
	
	func tapText(_ text: String) {
		let textElement = waitFor(element: app.staticTexts[text], type: "Text")
		textElement.tap()
	}
	
	func tapOtherElement(_ text: String) {
		let textElement = waitFor(element: app.otherElements[text], type: "Other")
		textElement.tap()
	}
	
	func textExists(_ text: String) {
		_ = waitFor(element: app.staticTexts[text], type: "Text")
	}
	
	func textContains(_ text: String) {
		let staticTextsQuery = searchTextInElement(text: text, element: app.staticTexts)
		let otherElementsQuery = searchTextInElement(text: text, element: app.otherElements)
		XCTAssertTrue(staticTextsQuery.count + otherElementsQuery.count >= 1, "Text could not be found in elements: " + text)
	}
	
	func searchTextInElement(text: String, element: XCUIElementQuery) -> XCUIElementQuery {
		let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
		let elementQuery = element.containing(predicate)
		return elementQuery
	}
	
	private func offsetDateWithDays(offset: Int) -> Date {
		let today = Date()
		let offsetDate = Calendar.current.date(byAdding: .day, value: offset, to: today)!
		return offsetDate
	}
	
	private func formatDate(with date: Date, withYear: Bool, withDay: Bool) -> String {
		let formatter = DateFormatter()
		var dateFormat = "d MMMM"
		if withYear { dateFormat = dateFormat + " yyyy" }
		if withDay { dateFormat = "EEEE " + dateFormat }
		formatter.dateFormat = dateFormat
		let formattedDate = formatter.string(from: date)
		return formattedDate
	}
	
	func formattedOffsetDate(with offset: Int, withYear: Bool = true, withDay: Bool = false) -> String {
		let calculatedDate = offsetDateWithDays(offset: offset)
		return formatDate(with: calculatedDate, withYear: withYear, withDay: withDay)
	}
	
	func formattedDate(with date: String, withYear: Bool = true, withDay: Bool = false) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-mm-dd"
		let calculatedDate = formatter.date(from: date)
		return formatDate(with: calculatedDate!, withYear: withYear, withDay: withDay)
	}
	
	func amountOfDoses(for doses: Int) -> String {
		let doseText = doses == 1 ? " dosis" : " doses"
		return "(" + String(doses) + doseText + ")"
	}
	
	func makeScreenShot(name: String = "") {
		let screenshot = XCUIScreen.main.screenshot()
		let fullScreenshotAttachment = XCTAttachment(screenshot: screenshot)
		let currentTestName = self.name
		fullScreenshotAttachment.name = currentTestName + name
		fullScreenshotAttachment.lifetime = .deleteOnSuccess
		add(fullScreenshotAttachment)
	}
}
