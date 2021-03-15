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
	///   - oncompletion: completion handler
	///   - onError: error handler
	func fetchCoronaTestProviders(
		oncompletion: (() -> Void)?,
		onError: ((Error) -> Void)?)

	/// Get the test types
	func fetchTestTypes()

	/// Fetch the issuer public keys
	/// - Parameters:
	///   - oncompletion: completion handler
	///   - onError: error handler
	func fetchIssuerPublicKeys(
		oncompletion: (() -> Void)?,
		onError: ((Error) -> Void)?)

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

	case missingParams
}
