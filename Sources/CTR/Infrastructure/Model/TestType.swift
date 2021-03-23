/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The type of tests
struct TestType: Codable {

	/// The identifier of the test type
	let identifier: String

	/// The name of the test type
	let name: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "uuid"
		case name
	}
}
