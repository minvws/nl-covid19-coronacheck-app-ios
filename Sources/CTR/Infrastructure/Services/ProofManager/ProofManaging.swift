/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ProofManaging: AnyObject {

	init()

	/// Get the providers
	func fetchCoronaTestProviders()

	/// Get the test types
	func fetchTestTypes()

	/// Get the test result for a token
	/// - Parameters:
	///   - token: the request token
	///   - code: the verification code
	///   - oncompletion: completion handler
	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		oncompletion: @escaping (Result<TestResultWrapper, Error>) -> Void)

	/// Create a nonce and a stoken
	/// - Parameters:
	///   - oncompletion: completion handler
	///   - onError: error handler
	func fetchNonce(
		oncompletion: @escaping (() -> Void),
		onError: @escaping ((Error) -> Void))

	/// Fetch the signed Test Result
	/// - Parameters:
	///   - oncompletion: completion handler
	///   - onError: error handler
	func fetchSignedTestResult(
		oncompletion: @escaping ((SignedTestResultState) -> Void),
		onError: @escaping ((Error) -> Void))

	/// Get the provider for a test token
	/// - Parameter token: the test token
	/// - Returns: the test provider
	func getTestProvider(_ token: RequestToken) -> TestProvider?

	/// Get a test result
	/// - Returns: a test result
	func getTestWrapper() -> TestResultWrapper?

	/// Get the signed test result
	/// - Returns: a test result
	func getSignedWrapper() -> SignedResponse?

	/// Remove the test wrapper
	func removeTestWrapper()
}

enum ProofError: Error {

	case invalidUrl
}

/// The test providers
struct TestProvider: Codable, Equatable {

	/// The identifier of the provider
	let identifier: String

	/// The name of the provider
	let name: String

	/// The url of the provider to fetch the result
	let resultURL: URL?

	/// The publc key of the provider
	let publicKey: String

	/// The ssl certificate of the provider
	let certificate: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "provider_identifier"
		case name
		case resultURL = "result_url"
		case publicKey = "public_key"
		case certificate = "ssl_cert"
	}

	func getCertificateData() -> Data? {

		if let base64DecodedString = certificate.base64Decoded() {
			return Data(base64DecodedString.utf8)
		}
		return nil
	}
}

/// The request token to fetch a test result form a commercial tester
struct RequestToken: Codable {

	/// The request token
	let token: String

	/// The version of the protocol
	let protocolVersion: String

	/// The identifier of the provider
	let providerIdentifier: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case token
		case protocolVersion
		case providerIdentifier
	}
}

/// A test result
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

/// A wrapper arround a test result.
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

/// The state of the signed test result
enum SignedTestResultState {

	/// The test was already signed before (code 99994)
	case alreadySigned

	/// The test was not negative (code 99993)
	case notNegative

	/// The test was in future (code 99991)
	case tooNew

	/// The test is too old (code 99992)
	case tooOld

	/// The state is unknown
	case unknown(Error?)

	/// The signed test result is valid
	case valid
}

struct SignedTestResultErrorResponse: Decodable {

	/// The error status
	let status: String

	/// The error code
	let code: Int
}
