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

	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	var networkManager: NetworkManaging = Services.networkManager
	var cryptoManager: CryptoManaging = Services.cryptoManager
	var walletManager: WalletManaging = Services.walletManager
	var cryptoLibUtility: CryptoLibUtilityProtocol = Services.cryptoLibUtility

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

	@UserDefaults(key: "keysFetchedTimestamp", defaultValue: nil)
	var keysFetchedTimestamp: Date? // swiftlint:disable:this let_var_whitespace
	
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
	func fetchIssuerPublicKeys(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?) {
		
		let ttl = TimeInterval(remoteConfigManager.getConfiguration().configTTL ?? 0)
		
		networkManager.getPublicKeys { [weak self] resultwrapper in
			
			// Response is of type (Result<Data, NetworkError>)
			switch resultwrapper {
				case .success(let data):
					
					self?.keysFetchedTimestamp = Date()
					self?.cryptoLibUtility.store(data, for: .publicKeys)
					onCompletion?()
				case let .failure(error):
					
					self?.logError("Error getting the issuers public keys: \(error)")
					if let lastFetchedTimestamp = self?.keysFetchedTimestamp,
					   lastFetchedTimestamp > Date() - ttl {
						self?.logInfo("Issuer public keys still within TTL")
						self?.cryptoLibUtility.checkFile(.publicKeys)
						onCompletion?()
						
					} else {
						onError?(error)
					}
			}
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
	
	// MARK: - Helper methods
	
	private func generateString<T>(object: T) -> String where T: Codable {
		
		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .utf8) {
			logVerbose("ProofManager: Convert to \(convertedToString)")
			return convertedToString
		}
		return ""
	}
}
