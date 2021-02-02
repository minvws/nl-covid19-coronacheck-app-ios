/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Alamofire
import Foundation

/// The protocol for all api calls
protocol ApiClientProtocol {
	
	/// Get the public keys
	/// - Parameter completionHandler: completion handler
	func getPublicKeys(completionHandler: @escaping ([Issuer]) -> Void)
	
	/// Get the nonce
	/// - Parameter completionHandler: completion handler
	func getNonce(completionHandler: @escaping (NonceEnvelope?) -> Void)
	
	/// Get the test results
	/// - Parameters:
	///   - identifier: the identifier of the user
	///   - completionHandler: the completion handler
	func getTestResults(
		identifier: String,
		completionHandler: @escaping (TestProofs?) -> Void)
	
	/// Fetch the test results with issue signature message
	/// - Parameters:
	///   - dictionary: dictionary
	///   - completionHandler: the completion handler
	func fetchTestResultsWithISM(
		dictionary: [String: AnyObject],
		completionHandler: @escaping (TestProofs?) -> Void)
}

/// The Api Client for all API Calls.
class ApiClient: ApiClientProtocol {
	
	/// Get the public keys
	/// - Parameter completionHandler: completion handler
	func getPublicKeys(completionHandler: @escaping ([Issuer]) -> Void) {
		
		AF.request(
			ApiRouter.publicKeys
		)
		.responseDecodable(of: Issuers.self) { response in
			
			switch response.result {
				case let .success(object):
					completionHandler(object.issuers)
					
				case .failure:
					completionHandler([])
			}
		}
	}
	
	/// Get the nonce
	/// - Parameter completionHandler: completion handler
	func getNonce(completionHandler: @escaping (NonceEnvelope?) -> Void) {
		
		AF.request(
			ApiRouter.nonce
		)
		.responseDecodable(of: NonceEnvelope.self) { response in
			
			switch response.result {
				case let .success(object):
					completionHandler(object)
					
				case .failure:
					completionHandler(nil)
			}
		}
	}
	
	/// Get the test results
	/// debug purpose only!
	/// - Parameters:
	///   - identifier: the identifier of the user
	///   - completionHandler: the completion handler
	func getTestResults(
		identifier: String,
		completionHandler: @escaping (TestProofs?) -> Void) {
		
		AF.request(
			ApiRouter.testResults(identifier: identifier)
		)
		.responseDecodable(of: TestProofs.self) { response in
			
			switch response.result {
				case let .success(object):
					completionHandler(object)
					
				case let .failure(error):
					print(error)
					completionHandler(nil)
			}
		}
	}
	
	/// Fetch the test results with issue signature message
	/// - Parameters:
	///   - dictionary: dictionary
	///   - completionHandler: the completion handler
	func fetchTestResultsWithISM(
		dictionary: [String: AnyObject],
		completionHandler: @escaping (TestProofs?) -> Void) {
		
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
			AF.request(
				ApiRouter.testResultsWithIssuerSignatureMessage(body: jsonData)
			)
			.responseDecodable(of: TestProofs.self) { response in
				
				switch response.result {
					case let .success(object):
						completionHandler(object)
						
					case let .failure(error):
						print(error)
						completionHandler(nil)
				}
			}
			
		} catch {
			completionHandler(nil)
		}
	}
}
