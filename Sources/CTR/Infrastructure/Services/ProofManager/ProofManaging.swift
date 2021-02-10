/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ProofManaging {

	init()

	/// Get the providers
	func getCoronaTestProviders()

	/// Get the test types
	func getTestTypes()

	/// Get a test result
	/// - Parameters:
	///   - code: the verification code
	///   - oncompletion: completion handler
	func getTestResult(_ code: String, oncompletion: @escaping (Error?) -> Void)
}

/// The test providers
struct TestProvider: Codable {

	/// The identifier of the provider
	let identifier: String

	/// The name of the provider
	let name: String

	/// The url of the provider to fetch the result
	let resultURL: URL?

	/// The publc key of the provider
	let publicKey: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "provider_identifier"
		case name
		case resultURL = "result_url"
		case publicKey = "public_key"
	}
}

struct TestToken: Codable {

	/// The request token
	let requestToken: String

	/// The version of the protocol
	let protocolVersion: String

	/// The identifier of the provider
	let providerIdentifier: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case requestToken = "token"
		case protocolVersion
		case providerIdentifier
	}

	static var positiveTest: TestToken {
		return TestToken(requestToken: "YYYYYYYYYYYY", protocolVersion: "1.0", providerIdentifier: "BRB")
	}

	static var negativeTest: TestToken {
		return TestToken(requestToken: "0450A462FF82", protocolVersion: "1.0", providerIdentifier: "BRB")
	}
}

struct TestResult: Codable {

	/// The identifier of the test result
	let unique: String

	/// The timestamp of the test result
	let sampleDate: String

	/// The type of test (identifier)
	let testType: String

	/// Is this a negative test result?
	let negativeResult: Bool

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case unique
		case sampleDate
		case testType
		case negativeResult
	}
}

/// The state of a test
enum TestState: String, Codable {

	/// The test result is pending
	case pending

	/// The test is complete
	case complete

	/// The test is invalid
	case invalid

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
