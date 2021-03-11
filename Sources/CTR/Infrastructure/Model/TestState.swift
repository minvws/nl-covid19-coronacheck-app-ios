/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The state of a test
enum TestState: String, Codable {

	/// The test result is pending
	case pending

	/// The test is complete
	case complete

	/// The test is invalid
	case invalid = "invalid_token"

	/// Verification is required before we can fetch the result
	case verificationRequired = "verification_required"

	/// Unknown state
	case unknown

	/// Custom initializer to default to unknown state
	/// - Parameter decoder: the decoder
	/// - Throws: Decoding error
	init(from decoder: Decoder) throws {
		self = try TestState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
	}
}
