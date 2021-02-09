/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ProofManaging {

	init()

	/// Get the provicers
	func getCoronaTestProviders()
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

	let token: String
	let protocolVersion: String
	let providerIdentifier: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case token
		case protocolVersion
		case providerIdentifier
	}

	static var positiveTest: TestToken {
		return TestToken(token: "YYYYYYYYYYYY", protocolVersion: "1.0", providerIdentifier: "BRB")
	}

	static var negativeTest: TestToken {
		return TestToken(token: "0450A462FF82", protocolVersion: "1.0", providerIdentifier: "BRB")
	}
}

struct TestResult: Codable {

	let unique: String
	let sampleDate: String
	let testType: String
	let negativeResult: Bool

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case unique
		case sampleDate
		case testType
		case negativeResult
	}
}

enum TestState: String, Codable {

	case pending
	case complete
	case invalid
	case verificationRequired = "verification_required"
	case unknown

	init(from decoder: Decoder) throws {
		self = try TestState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
	}
}

struct TestResultWrapper: Codable {

	let result: TestResult?
	let protocolVersion: String
	let providerIdentifier: String
	let status: TestState

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case result
		case protocolVersion
		case providerIdentifier
		case status
	}
}
