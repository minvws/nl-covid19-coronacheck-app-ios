/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension BaseTest {
	
	private func offsetDateWithDays(offset: Int) -> Date {
		let today = Date()
		let offsetDate = Calendar.current.date(byAdding: .day, value: offset, to: today)!
		return offsetDate
	}
	
	private func formatDate(of date: Date, withYear: Bool, withDay: Bool, short: Bool) -> String {
		let formatter = DateFormatter()
		var dateFormat = "d MMMM"
		if withYear { dateFormat = dateFormat + " yyyy" }
		if withDay { dateFormat = "EEEE " + dateFormat }
		if short { dateFormat = "dd-MM-yyyy" }
		formatter.dateFormat = dateFormat
		let formattedDate = formatter.string(from: date)
		return formattedDate
	}
	
	func formattedOffsetDate(with offset: Int, withYear: Bool = true, withDay: Bool = false, short: Bool = false) -> String {
		let calculatedDate = offsetDateWithDays(offset: offset)
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
	
	func cardsToCheck(for certificateType: CertificateType, _ combinedWithOther: Bool = false) -> [XCUIElement] {
		switch certificateType {
			case .test:
				switch disclosureMode {
					case .only1G:
						return [card1G()]
					case .only3G:
						return [card3G()]
					case .bothModes:
						if combinedWithOther {
							return [card1G()]
						} else {
							return [card1G(), card3G()]
						}
				}
			default:
				return [card3G()]
		}
	}
	
	func is3GEnabled() -> Bool {
		switch disclosureMode {
			case .only1G:
				return false
			case .only3G, .bothModes:
				return true
		}
	}
}
