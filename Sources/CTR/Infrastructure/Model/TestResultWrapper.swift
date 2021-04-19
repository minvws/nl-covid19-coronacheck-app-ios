/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// A wrapper around a test result.
struct TestResultWrapper: Codable {

	/// The provider identifier
	let providerIdentifier: String

	/// The protocol version
	let protocolVersion: String

	/// The test result
	let result: TestResult?

	/// The state of the test
	let status: TestState

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case result
		case protocolVersion
		case providerIdentifier
		case status
	}
}
