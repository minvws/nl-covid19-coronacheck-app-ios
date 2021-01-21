//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Alamofire
import Foundation

class APIClient {

	func getIssuers(completionHandler: @escaping ([Issuer]) -> Void) {

		AF.request("https://api-ct.bananenhalen.nl/verifier/get_public_keys/")
			.responseDecodable(of: Issuers.self) { response in

				switch response.result {
					case let .success(object):
						completionHandler(object.issuers)

					case .failure:
						completionHandler([])
				}
			}
	}

	func getTestResults(identifier: String, completionHandler: @escaping (TestResultEnvelope?) -> Void) {

		AF.request("https://api-ct.bananenhalen.nl/citizen/get_test_results/?userUUID=\(identifier)")
			.responseDecodable(of: TestResultEnvelope.self) { response in

				switch response.result {
					case let .success(object):
						completionHandler(object)

					case .failure:
						completionHandler(nil)
				}
			}
		}
}
