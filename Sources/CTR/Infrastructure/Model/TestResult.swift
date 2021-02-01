/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct TestResultEnvelope: Codable {

	var testResults: [TestResult]
	var signatures: [TestSignature]
	var types: [TestType]?

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case testResults = "test_results"
		case signatures = "test_signatures"
		case types = "test_types"
	}
}

struct Ism: Codable {

	var identifier: String
	var ism: String

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case identifier = "uuid"
		case ism = "ism"
	}
}

struct IsmResponse: Codable {

	var isms: [Ism]
	var signatures: [TestSignature]
	var types: [TestType]?

	enum CodingKeys: String, CodingKey {

		case isms = "test_results"
		case signatures = "test_signatures"
		case types = "test_types"
	}
}

struct TestSignature: Codable {

	var identifier: String
	var signature: String

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case identifier = "uuid"
		case signature
	}
}

/// A test Result
struct TestResult: Codable {

	var identifier: String
	var testType: String
	var dateTaken: Int64
	var result: Int

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case identifier = "uuid"
		case testType = "test_type"
		case dateTaken = "date_taken"
		case result
	}
}

struct TestType: Codable {
	var name: String
	var identifier: String
	var maxValidity: Int?

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case identifier = "uuid"
		case name
		case maxValidity = "max_validity"
	}
}

struct Payload: Codable {
	var identifier: String
	var time: Int64
	var test: TestResult?
	var signature: String?

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case identifier = "event_uuid"
		case time
		case test
		case signature = "test_signature"
	}
}

struct CustomerQR: Codable {

	var publicKey: String
	var nonce: String
	var payload: String

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case publicKey = "public_key"
		case nonce
		case payload
	}
}
