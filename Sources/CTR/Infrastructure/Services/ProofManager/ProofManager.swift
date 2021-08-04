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

	internal var testProviders = [TestProvider]()
	
	/// Structure to hold proof data
	internal struct ProofData: Codable {
		
		/// The key of the holder
		var testTypes: [TestType]
		
		/// The test result
		var testWrapper: TestResultWrapper?
		
		/// The signed Wrapper
		var signedWrapper: SignedResponse?
		
		/// Empty crypto data
		static var empty: ProofData {
			return ProofData(testTypes: [], testWrapper: nil, signedWrapper: nil)
		}
	}

	/// Array of constants
	private struct Constants {
		static let keychainService = "ProofManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}
	
	/// The proof data stored in the keychain
	@Keychain(name: "proofData", service: Constants.keychainService, clearOnReinstall: true)
	internal var proofData: ProofData = .empty
	
	/// Initializer
	required init() {
		// Required by protocol
	}
	
	/// Get the providers
	func fetchCoronaTestProviders(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?) {
		
		networkManager.fetchTestProviders { [weak self] response in
			
			// Response is of type (Result<[TestProvider], NetworkError>)
			switch response {
				case let .success(providers):
					self?.testProviders = providers
					onCompletion?()
					
				case let .failure(error):
					self?.logError("Error getting the test providers: \(error)")
					onError?(error)
			}
		}
	}
	
	/// Get the provider for a test token
	/// - Parameter token: the test token
	/// - Returns: the test provider
	func getTestProvider(_ token: RequestToken) -> TestProvider? {
		
		for provider in testProviders where provider.identifier.lowercased() == token.providerIdentifier.lowercased() {
			return provider
		}
		return nil
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
