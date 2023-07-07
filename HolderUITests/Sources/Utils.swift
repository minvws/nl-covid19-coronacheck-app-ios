/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckTest

extension BaseTest {
	
	private func offsetDateWithDays(offset: Int, component: Calendar.Component) -> Date {
		let today = Date()
		let offsetDate = Calendar.current.date(byAdding: component, value: offset, to: today)!
		return offsetDate
	}
	
	private func formatDate(of date: Date, withYear: Bool, withDay: Bool, short: Bool) -> String {
		let formatter = DateFormatter()
		var dateFormat = "d MMMM"
		if withYear { dateFormat += " yyyy" }
		if withDay { dateFormat = "EEEE " + dateFormat }
		if short { dateFormat = "dd-MM-yyyy" }
		formatter.dateFormat = dateFormat
		let formattedDate = formatter.string(from: date)
		return formattedDate
	}
	
	func formattedOffsetDate(with offset: Int, component: Calendar.Component = .day, withYear: Bool = true, withDay: Bool = false, short: Bool = false) -> String {
		let calculatedDate = offsetDateWithDays(offset: offset, component: component)
		return formatDate(of: calculatedDate, withYear: withYear, withDay: withDay, short: short)
	}
	
	func formattedDate(of date: String, withYear: Bool = true, withDay: Bool = false, short: Bool = false) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let calculatedDate = formatter.date(from: date)
		return formatDate(of: calculatedDate!, withYear: withYear, withDay: withDay, short: short)
	}
	
	func amountOfDoses(for doses: Int) -> String {
		let doseText = doses == 1 ? " dosis" : " doses"
		return "(" + String(doses) + doseText + ")"
	}
	
	func spreadDose(_ dose: String) -> String {
		return dose.map { String($0) }.joined(separator: " ")
	}
	
	func makeScreenShot(name: String = "") {
		let screenshot = XCUIScreen.main.screenshot()
		let fullScreenshotAttachment = XCTAttachment(screenshot: screenshot)
		let currentTestName = self.name
		fullScreenshotAttachment.name = currentTestName + name
		fullScreenshotAttachment.lifetime = .deleteOnSuccess
		add(fullScreenshotAttachment)
	}
	
	func card1G() -> XCUIElement {
		return cardElement("1GQRCard")
	}
	
	func card3G() -> XCUIElement {
		return cardElement("3GQRCard")
	}
	
	private func cardElement(_ identifier: String) -> XCUIElement {
		return app.descendants(matching: .any)[identifier]
	}
	
	func card(of certificateType: CertificateType) -> XCUIElement {
		let predicate = NSPredicate(format: "label CONTAINS[c] %@", certificateType.rawValue)
		return app.descendants(matching: .any).matching(identifier: "QRCard").containing(predicate).firstMatch
	}
	
	func cardsToCheck(for certificateType: CertificateType, _ combinedWithOther: Bool = false) -> [XCUIElement] {
		switch certificateType {
			case .test:
				switch disclosureMode {
					case .mode0G:
						return []
				}
			default:
				return [card3G()]
		}
	}
	
	func is3GEnabled() -> Bool {
		return false
	}
}
