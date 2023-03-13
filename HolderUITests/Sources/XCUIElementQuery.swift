/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

extension XCUIElementQuery {
	
	func elementMap() -> [Any] {
		return allElementsBoundByIndex.map { $0.label.isEmpty ? "Value: \($0.value ?? "")" : "Label: \($0.label)" }
	}
	
	func mapLabelsToSet() -> Set<String> {
		return Set(allElementsBoundByIndex.compactMap { $0.label.isEmpty == false ? $0.label : nil })
	}
}
