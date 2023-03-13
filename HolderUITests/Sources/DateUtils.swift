/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

// Inspired by https://prograils.com/swift-date-handler

import Foundation

extension DateFormatter {
	convenience init(format: String) {
		self.init()
		dateFormat = format
	}
}

struct DateHandler {
	let formatter: DateFormatter
	
	static let short = DateHandler(format: "yyyy-MM-dd")
	static let written = DateHandler(format: "d MMMM yyyy")
	static let recently = DateHandler(format: "EEEE d MMMM")
	static let dutch = DateHandler(format: "dd-MM-yyyy")
	
	init(format: String) {
		formatter = DateFormatter(format: format)
	}
}

extension Date {
	init(_ dateString: String) {
		self = dateString.toDate(.short)!
	}
	
	init(_ offset: Int, component: Calendar.Component = .day) {
		self = Date().offset(offset, component)
	}
	
	func toString(_ type: DateHandler) -> String {
		type.formatter.string(from: self)
	}
	
	func offset(_ offset: Int, _ component: Calendar.Component = .day) -> Date {
		return Calendar.current.date(byAdding: component, value: offset, to: self)!
	}
	
	var short: String {
		return toString(.short)
	}
}

extension String {
	func toDate(_ type: DateHandler) -> Date? {
		type.formatter.date(from: self)
	}
}

struct DateWrapper {
	let handler: DateHandler
	
	init(format: String) {
		handler = DateHandler(format: format)
	}
}
