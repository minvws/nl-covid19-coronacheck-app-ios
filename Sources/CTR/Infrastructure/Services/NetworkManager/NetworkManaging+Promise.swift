//
/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Promise

extension NetworkManaging {
	
	/// Shim to allow return of Promise for `prepareIssue`
	func prepareIssue() -> Promise<PrepareIssueEnvelope> {
		Promise(work: { [self] fulfill, reject in
			prepareIssue(completion: resultCompletionHandler(fulfil: fulfill, reject: reject))
		})
	}
	
	/// Shim to allow return of Promise for `fetchGreencards`
	func fetchGreencards(dictionary: [String: AnyObject]) -> Promise<RemoteGreenCards.Response> {
		Promise(work: { [self] fulfill, reject in
			fetchGreencards(dictionary: dictionary, completion: resultCompletionHandler(fulfil: fulfill, reject: reject))
		})
	}
}
