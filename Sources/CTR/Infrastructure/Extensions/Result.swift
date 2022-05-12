/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Result {

	var isSuccess: Bool {
		switch self {
			case .failure: return false
			case .success: return true
		}
	}

	var successValue: Success? {
		guard case let .success(value) = self else { return nil }
		return value
	}

	var isFailure: Bool {
		switch self {
			case .failure: return true
			case .success: return false
		}
	}

	var failureError: Failure? {
		guard case let .failure(error) = self else { return nil }
		return error
	}
}
