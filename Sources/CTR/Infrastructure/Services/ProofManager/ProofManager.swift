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

		/// Empty crypto data
		static var empty: ProofData {
			return ProofData(testProviders: [], testTypes: [], testWrapper: nil)
		}
	}

	/// Array of constants
	private struct Constants {
		static let keychainService = "ProofManager\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	/// The crypto data stored in the keychain
	@Keychain(name: "proofData", service: Constants.keychainService, clearOnReinstall: true)
	private var proofData: ProofData = .empty

	/// Initializer
	required init() {
		// Required by protocol
	}

	/// Get the providers
	func fetchCoronaTestProviders() {

		networkManager.getTestProviders { response in
			// Response is of type (Result<[TestProvider], NetworkError>)
			switch response {
				case let .success(providers):
					self.proofData.testProviders = providers
				case let .failure(error):
					self.logError("Error getting the test providers: \(error)")
			}
		}
	}

	/// Get the test types
	func fetchTestTypes() {

		networkManager.getTestTypes { response in
			// Response is of type (Result<[TestType], NetworkError>)
			switch response {
				case let .success(types):
					self.proofData.testTypes = types
				case let .failure(error):
					self.logError("Error getting the test types: \(error)")
			}
		}
	}

	/// Get a test result
	/// - Parameters:
	///   - code: the verification code
	///   - oncompletion: completion handler
	func fetchTestResult(_ code: String, oncompletion: @escaping (Error?) -> Void) {

		let token = TestToken.negativeTest
		for provider in proofData.testProviders where provider.identifier == token.providerIdentifier {

			guard let url = provider.resultURL else {
				self.logError("No url provided for \(provider)")
				return
			}

			networkManager.getTestResult(providerUrl: url, token: token, code: code) { response in
				// response is of type (Result<TestResultWrapper, NetworkError>)

				switch response {
					case let .success(wrapper):
						self.proofData.testWrapper = wrapper
						oncompletion(nil)
					case let .failure(error):
						self.logError("Error getting the result: \(error)")
						oncompletion(error)
				}
			}
		}
	}

	/// Get a test result
	/// - Returns: a test result
	func getTestWrapper() -> TestResultWrapper? {

		return proofData.testWrapper
	}
}
