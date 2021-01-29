/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Alamofire
import Foundation

/// The protocol for all api calls
protocol RemoteConfigurationApiClientProtocol {

	/// Get the remote configuration
	/// - Parameters:
	///   - completionHandler: the completion handler
	func getRemoteConfiguration(_ completionHandler: @escaping (RemoteConfiguration?) -> Void)
}

/// The Api Client for all API Calls.
class RemoteConfigurationApiClient: RemoteConfigurationApiClientProtocol {

	/// Get the remote configuration
	/// - Parameters:
	///   - completionHandler: the completion handler
	func getRemoteConfiguration(_ completionHandler: @escaping (RemoteConfiguration?) -> Void) {

		AF.request(
			RemoteConfigurationRouter.getRemoteConfiguration
		)
		.cacheResponse(using: ResponseCacher(behavior: .doNotCache))
		.responseDecodable(of: RemoteConfiguration.self) { response in

			switch response.result {
				case let .success(object):
					completionHandler(object)

				case .failure:
					completionHandler(nil)
			}
		}
	}
}
