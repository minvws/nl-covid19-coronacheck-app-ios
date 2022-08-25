/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import BrightFutures

extension NetworkManaging {
	
	/// Shim to allow return of Promise for `prepareIssue`
	func prepareIssue() -> Future<PrepareIssueEnvelope, ServerError> {
		
		Future { complete in
			prepareIssue { result in
				switch result {
				case .success(let value): complete(.success(value))
				case .failure(let error): complete(.failure(error))
				}
			}
		}
	}
	
	/// Shim to allow return of Promise for `fetchGreencards`
	func fetchGreencards(dictionary: [String: AnyObject]) -> Future<RemoteGreenCards.Response, ServerError> {
		Future { complete in
			fetchGreencards(dictionary: dictionary, completion: { result in
				switch result {
				case .success(let value): complete(.success(value))
				case .failure(let error): complete(.failure(error))
				}
			})
		}
	}
//	/// Shim to allow return of Promise for `fetchGreencards`
//	func fetchGreencards(dictionary: [String: AnyObject]) -> Promise<RemoteGreenCards.Response> {
//		Promise(work: { [self] fulfill, reject in
//			fetchGreencards(dictionary: dictionary, completion: resultCompletionHandler(fulfil: fulfill, reject: reject))
//		})
//	}
}
