//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The type of test results
enum TestResultType: String, Codable {

	/// Result is positive for Covid-19
	case positive

	/// Result is negative for Covid-19
	case negative

	/// Result is unknown, default value
	case unknown

	/// Key mapping
	enum CodingKeys: CodingKey {
		case positive
		case negative
		case unknown
	}
}

/// A test Result
struct TestResult: Codable {

	/// The status of the test
	var status: TestResultType

	/// The date of the test
	var timeStamp: Date?

	/// Key mapping
	enum CodingKeys: CodingKey {
		case status
		case timeStamp
	}

	func generateString() -> String {

		if let data = try? JSONEncoder().encode(self),
		   let convertedToString = String(data: data, encoding: .utf8) {
			print("CTR: Converted Testresult to \(convertedToString)")
				return convertedToString
		}
		return ""
	}
}
