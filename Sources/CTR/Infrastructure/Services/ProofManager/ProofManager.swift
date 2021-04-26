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
	
	/// The remote config manager
	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	
	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager
	
	/// The crypto manager
	var cryptoManager: CryptoManaging = Services.cryptoManager
	
	/// Structure to hold proof data
	private struct ProofData: Codable {
		
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
	
	/// Structure to hold provider data
	private struct ProviderData: Codable {
		
		/// The key of the holder
		var testProviders: [TestProvider]
		
		/// Empty crypto data
		static var empty: ProviderData {
			return ProviderData(testProviders: [])
		}
	}
	
	/// Array of constants
	private struct Constants {
		static let keychainService = "ProofManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}
	
	/// The proof data stored in the keychain
	@Keychain(name: "proofData", service: Constants.keychainService, clearOnReinstall: true)
	private var proofData: ProofData = .empty
	
	/// The provider data stored in the keychain
	@Keychain(name: "providerData", service: Constants.keychainService, clearOnReinstall: true)
	private var providerData: ProviderData = .empty
	
	@UserDefaults(key: "providersFetchedTimestamp", defaultValue: nil)
	private var providersFetchedTimestamp: Date? // swiftlint:disable:this let_var_whitespace
	
	@UserDefaults(key: "keysFetchedTimestamp", defaultValue: nil)
	var keysFetchedTimestamp: Date? // swiftlint:disable:this let_var_whitespace
	
	/// Initializer
	required init() {
		// Required by protocol
		
		removeTestWrapper()
	}
	
	/// Get the providers
	func fetchCoronaTestProviders(
		onCompletion: (() -> Void)?,
		onError: ((Error) -> Void)?) {
		
		#if DEBUG
		if let lastFetchedTimestamp = providersFetchedTimestamp,
		   lastFetchedTimestamp > Date() - 3600, !providerData.testProviders.isEmpty {
			// Don't fetch again within an hour
			onCompletion?()
			return
		}
		#endif
		
		networkManager.getTestProviders { [weak self] response in
			
			// Response is of type (Result<[TestProvider], NetworkError>)
			switch response {
				case let .success(providers):
					self?.providerData.testProviders = providers
					self?.providersFetchedTimestamp = Date()
					onCompletion?()
					
				case let .failure(error):
					self?.logError("Error getting the test providers: \(error)")
					onError?(error)
			}
		}
	}
	
	/// Get the test types
	func fetchTestTypes() {
		
		networkManager.getTestTypes { [weak self] response in
			// Response is of type (Result<[TestType], NetworkError>)
			switch response {
				case let .success(types):
					self?.proofData.testTypes = types
					
				case let .failure(error):
					self?.logError("Error getting the test types: \(error)")
			}
		}
	}
	
	/// Get the provider for a test token
	/// - Parameter token: the test token
	/// - Returns: the test provider
	func getTestProvider(_ token: RequestToken) -> TestProvider? {
		
		for provider in providerData.testProviders where provider.identifier.lowercased() == token.providerIdentifier.lowercased() {
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
			
			// Response is of type (Result<[IssuerPublicKey], NetworkError>)
			switch resultwrapper {
				case let .success(keys):
					
					if let manager = self?.cryptoManager, manager.setIssuerPublicKeys(keys) {
						self?.keysFetchedTimestamp = Date()
						onCompletion?()
					} else {
						// Loading of the public keys into the CL Library failed.
						// This is pretty much a dead end for the user.
						onError?(NetworkResponseHandleError.invalidPublicKeys)
					}
				case let .failure(error):
					
					self?.logError("Error getting the issuers public keys: \(error)")
					if let lastFetchedTimestamp = self?.keysFetchedTimestamp,
					   lastFetchedTimestamp > Date() - ttl {
						self?.logInfo("Issuer public keys still within TTL")
						onCompletion?()
						
					} else {
						onError?(error)
					}
			}
		}
	}
	
	/// Create a nonce and a stoken
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchNonce(
		onCompletion: @escaping (() -> Void),
		onError: @escaping ((Error) -> Void)) {
		
		networkManager.getNonce { [weak self] resultwrapper in
			
			switch resultwrapper {
				case let .success(envelope):
					self?.cryptoManager.setNonce(envelope.nonce)
					self?.cryptoManager.setStoken(envelope.stoken)
					onCompletion()
					
				case let .failure(networkError):
					self?.logError("Can't fetch the nonce: \(networkError.localizedDescription)")
					onError(networkError)
			}
		}
	}
	
	/// Fetch the signed Test Result
	/// - Parameters:
	///   - onCompletion: completion handler
	///   - onError: error handler
	func fetchSignedTestResult(
		onCompletion: @escaping ((SignedTestResultState) -> Void),
		onError: @escaping ((Error) -> Void)) {
		
		guard let icm = cryptoManager.generateCommitmentMessage(),
			  let icmDictionary = icm.convertToDictionary(),
			  let stoken = cryptoManager.getStoken(),
			  let wrapper = getSignedWrapper() else {
			
			onError(ProofError.missingParams)
			return
		}
		
		let dictionary: [String: AnyObject] = [
			"test": generateString(object: wrapper) as AnyObject,
			"stoken": stoken as AnyObject,
			"icm": icmDictionary as AnyObject
		]
		
		networkManager.fetchTestResultsWithISM(dictionary: dictionary) { [weak self] resultwrapper in
			
			switch resultwrapper {
				case let .success(data):
					self?.parseSignedTestResult(data, onCompletion: onCompletion)
					
				case let .failure(networkError):
					self?.logError("Can't fetch the signed test result: \(networkError.localizedDescription)")
					onError(networkError)
			}
		}
	}
	
	private func parseSignedTestResult(_ data: Data, onCompletion: @escaping ((SignedTestResultState) -> Void)) {
		
		logDebug("ISM Response: \(String(decoding: data, as: UTF8.self))")
		
		removeTestWrapper()
		do {
			let ismResponse = try JSONDecoder().decode(SignedTestResultErrorResponse.self, from: data)
			onCompletion(ismResponse.asSignedTestResultState())
			
		} catch {
			// No error from the signer. Let's create the credential from the proof
			let result = cryptoManager.createCredential(data)
			switch result {
				case let .success(credential):
					cryptoManager.storeCredential(credential)
					onCompletion(SignedTestResultState.valid)
				case let .failure(error):
					logError("Can't create credential: \(error.localizedDescription)")
					cryptoManager.removeCredential()

					let response: SignedTestResultErrorResponse

					switch error {
						case CryptoError.keyMissing:
							response = SignedTestResultErrorResponse(status: error.localizedDescription, code: 19991)
						case let CryptoError.credentialCreateFail(reason):
							response = SignedTestResultErrorResponse(status: reason, code: 19992)
						default:
							response = SignedTestResultErrorResponse(status: error.localizedDescription, code: 19990)
					}

					onCompletion(SignedTestResultState.unknown(response: response))
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
		onCompletion: @escaping (Result<TestResultWrapper, Error>) -> Void) {
		
		if provider.resultURL == nil {
			self.logError("No url provided for \(provider)")
			onCompletion(.failure(ProofError.invalidUrl))
			return
		}
		
		networkManager.getTestResult(provider: provider, token: token, code: code) { response in
			// response is of type (Result<(TestResultWrapper, SignedResponse), NetworkError>)
			
			switch response {
				case let .success(wrapper):
					self.logDebug("We got \(wrapper.0.status) wrapper.")
					if wrapper.0.status == .complete || wrapper.0.status == .pending {
						self.proofData.testWrapper = wrapper.0
						self.proofData.signedWrapper = wrapper.1
					}
					onCompletion(.success(wrapper.0))
				case let .failure(error):
					self.logError("Error getting the result: \(error)")
					onCompletion(.failure(error))
			}
		}
	}
	
	/// Get a test result
	/// - Returns: a test result
	func getTestWrapper() -> TestResultWrapper? {
		
		return proofData.testWrapper
	}
	
	/// Get the signed test result
	/// - Returns: a test result
	func getSignedWrapper() -> SignedResponse? {
		
		return proofData.signedWrapper
	}
	
	/// Remove the test wrapper
	func removeTestWrapper() {
		
		proofData.testWrapper = nil
		proofData.signedWrapper = nil
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
