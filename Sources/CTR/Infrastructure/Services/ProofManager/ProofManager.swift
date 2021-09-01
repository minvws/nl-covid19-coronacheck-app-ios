/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The manager of all the test provider proof data
class ProofManager: ProofManaging, Logging {
	
	var loggingCategory: String = "ProofManager"

	var networkManager: NetworkManaging = Services.networkManager

	/// Array of constants
	private struct Constants {
		static let keychainService = "ProofManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// Initializer
	required init() {
		// Required by protocol
	}
	
	/// Fetch the issuer public keys
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchIssuerPublicKeys(onCompletion: ((Result<Data, NetworkError>) -> Void)?) {

		networkManager.getPublicKeys { result in
			onCompletion?(result)
		}
	}
	
	/// Get the test result for a token
	/// - Parameters:
	///   - token: the request token
	///   - code: the verification code
	///   - onCompletion: completion handler
	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		onCompletion: @escaping (Result<RemoteEvent, Error>) -> Void) {

		if provider.resultURL == nil {
			self.logError("No url provided for \(provider)")
			onCompletion(.failure(ProofError.invalidUrl))
			return
		}

		networkManager.fetchTestResult(provider: provider, token: token, code: code) { response in
			// response is of type (Result<(TestResultWrapper, SignedResponse), NetworkError>)

			switch response {
				case let .success(wrapper):
					self.logDebug("We got \(wrapper.0.status) wrapper.")
					onCompletion(.success(wrapper))
				case let .failure(error):
					self.logError("Error getting the result: \(error)")
					onCompletion(.failure(error))
			}
		}
	}
}
