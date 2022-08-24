//
/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// A generic function that can be used for a `completionHandler: Result<T, Error>`,
/// to pipe the `Result<T, Error>` straight into a Promise (reducing code duplication of unwrapping result):
func resultCompletionHandler<T, E: Error>(fulfil: @escaping (T) -> Void, reject: @escaping (Error) -> Void) -> (Result<T, E>) -> Void {
	return { result in
		switch result {
			case .success(let envelope):
				fulfil(envelope)
			case .failure(let error):
				reject(error)
		}
	}
}
