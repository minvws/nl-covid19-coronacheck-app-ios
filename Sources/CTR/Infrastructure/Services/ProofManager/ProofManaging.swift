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
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchCoronaTestProviders(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?)

	/// Get the test types
	func fetchTestTypes()

	/// Fetch the issuer public keys
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchIssuerPublicKeys(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?)

	/// Get the test result for a token
	/// - Parameters:
	///   - token: the request token
	///   - code: the verification code
	///   - onCompletion: completion handler
	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		onCompletion: @escaping (Result<TestResultWrapper, Error>) -> Void)

	/// Create a nonce and a stoken
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchNonce(
		onCompletion: @escaping (() -> Void),
		onError: @escaping ((Error) -> Void))

	/// Fetch the signed Test Result
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchSignedTestResult(
		onCompletion: @escaping ((SignedTestResultState) -> Void),
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

	case missingParams
}
