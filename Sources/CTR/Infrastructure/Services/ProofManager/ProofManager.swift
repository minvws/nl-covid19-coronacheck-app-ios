/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ProofManager: ProofManaging, Logging {

	var loggingCategory: String = "ProofManager"

	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager

	/// Structure to hold cryptography data
	private struct ProofData: Codable {

		/// The key of the holder
		var testProviders: [TestProvider]

		/// The key of the holder
		var testTypes: [TestType]

		/// The test result
		var testWrapper: TestResultWrapper?

		/// The signed Wrapper
		var signedWrapper: SignedResponse?

		/// Empty crypto data
		static var empty: ProofData {
			return ProofData(testProviders: [], testTypes: [], testWrapper: nil, signedWrapper: nil)
		}
	}

	/// Array of constants
	private struct Constants {
		static let keychainService = "ProofManager\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// The crypto data stored in the keychain
	@Keychain(name: "proofData", service: Constants.keychainService, clearOnReinstall: true)
	private var proofData: ProofData = .empty

	@UserDefaults(key: "providersFetchedTimestamp", defaultValue: nil)
	private var providersFetchedTimestamp: Date? // swiftlint:disable:this let_var_whitespace

	/// Initializer
	required init() {
		// Required by protocol
	}

	/// Get the providers
	func fetchCoronaTestProviders() {

		#if DEBUG
		if let lastFetchedTimestamp = providersFetchedTimestamp,
		   lastFetchedTimestamp > Date() - 3600, !proofData.testProviders.isEmpty {
			// Don't fetch again within an hour
				return
		}
		#endif

		networkManager.getTestProviders { [weak self] response in
			self?.providersFetchedTimestamp = Date()
			// Response is of type (Result<[TestProvider], NetworkError>)
			switch response {
				case let .success(providers):
					self?.proofData.testProviders = providers
				case let .failure(error):
					self?.logError("Error getting the test providers: \(error)")
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

		for provider in proofData.testProviders where provider.identifier.lowercased() == token.providerIdentifier.lowercased() {
			return provider
		}
		return nil
	}

	/// Get the test result for a token
	/// - Parameters:
	///   - token: the request token
	///   - code: the verification code
	///   - oncompletion: completion handler
	func fetchTestResult(
		_ token: RequestToken,
		code: String?,
		provider: TestProvider,
		oncompletion: @escaping (Result<TestResultWrapper, Error>) -> Void) {

		guard let url = provider.resultURL else {
			self.logError("No url provided for \(provider)")
			oncompletion(.failure(ProofError.invalidUrl))
			return
		}

		networkManager.getTestResult(providerUrl: url, token: token, code: code) { response in
			// response is of type (Result<(TestResultWrapper, SignedResponse), NetworkError>)

			switch response {
				case let .success(wrapper):
					print("iii")
					if wrapper.0.status == .complete {
						self.proofData.testWrapper = wrapper.0
						self.proofData.signedWrapper = wrapper.1
				}
					oncompletion(.success(wrapper.0))
				case let .failure(error):
					self.logError("Error getting the result: \(error)")
					oncompletion(.failure(error))
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
	}
}
