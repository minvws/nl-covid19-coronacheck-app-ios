/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// A test result
struct TestResult: Codable, Equatable {

	/// The identifier of the test result
	let unique: String

	/// The timestamp of the test result
	let sampleDate: String

	/// The type of test (identifier)
	let testType: String

	/// Is this a negative test result?
	let negativeResult: Bool

	/// The holder of the test
	let holder: TestHolderIdentity?  // Version 2.0.

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case unique
		case sampleDate
		case testType
		case negativeResult
		case holder
	}
}
