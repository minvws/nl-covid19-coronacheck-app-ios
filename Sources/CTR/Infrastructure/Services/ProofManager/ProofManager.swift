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

		/// The test result
		var testResult: TestResult?

		/// Empty crypto data
		static var empty: ProofData {
			return ProofData(testProviders: [], testResult: nil)
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
	func getCoronaTestProviders() {

		networkManager.getTestProviders { response in
			// Repsonse is of type (Result<[TestProvider], NetworkError>)
			switch response {
				case let .success(providers):
					self.proofData.testProviders = providers
					self.getTestResult()
				case let .failure(error):
					self.logError("Error getting the test providers: \(error)")
			}
		}
	}

	func getTestResult(_ code: String = "1234") {

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
						if let result = wrapper.result {
							self.proofData.testResult = result
						}
					case let .failure(error):
						self.logError("Error getting the result: \(error)")
				}
			}
		}
	}
}
