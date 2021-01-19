//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct Event: Codable {

	/// The title of the event
	var title: String

	/// The location of the event
	var location: String

	/// The time of the event
	var time: String

	/// Key mapping
	enum CodingKeys: CodingKey {
		case title
		case location
		case time
	}

	func generateString() -> String {

		if let data = try? JSONEncoder().encode(self),
		   let convertedToString = String(data: data, encoding: .ascii) {
			print("CTR: Converted Event to \(convertedToString)")
			return convertedToString
		}
		return ""
	}
}
