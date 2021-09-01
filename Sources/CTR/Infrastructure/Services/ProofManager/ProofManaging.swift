/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ProofManaging: AnyObject {

	init()

	/// Fetch the issuer public keys
	/// - Parameters:
	///   - onCompletion: completion handler
	func fetchIssuerPublicKeys(onCompletion: ((Result<Data, NetworkError>) -> Void)?)

	/// Get the test result for a token
	/// - Parameters:
	///   - token: the request token
	///   - code: the verification code
	///   - onCompletion: completion handler
	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		onCompletion: @escaping (Result<RemoteEvent, Error>) -> Void)
}

enum ProofError: Error {

	case invalidUrl

	case missingParams
}
