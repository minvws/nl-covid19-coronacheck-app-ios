/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// An issuer signed message object
struct IssuerSignedMessage: Codable {

	/// the issuer signed message in base 64
	var base64Ism: String

	/// a list of string attributes
	var attributes: [String]

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case base64Ism = "ism"
		case attributes = "attributes"
	}
}

/// A Test proof
struct TestProof: Codable {

	/// The issuer signed message
	var issuerSignedMessage: IssuerSignedMessage?

	/// The signature
	var signature: String?

	/// The test type
	var type: TestType?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case issuerSignedMessage = "test_proof"
		case signature = "signature"
		case type = "test_type"
	}
}

/// A wrapper arount test proofs
struct TestProofs: Codable {

	/// the test proofs
	var testProofs: [TestProof]?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case testProofs = "test_proofs"
	}
}

/// The type of test (pcr, breathalyzer
struct TestType: Codable {

	/// The name of the test type
	var name: String

	/// The identifier ot the test type
	var identifier: String

	/// The maximum validity of the tests (in seconds)
	var maxValidity: Int?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "uuid"
		case name
		case maxValidity = "max_validity"
	}
}
