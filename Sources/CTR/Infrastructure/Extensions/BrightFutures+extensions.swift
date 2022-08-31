/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import BrightFutures

extension Future {

	/// Prevents a Failure propagating by catching it and replacing it with a `.success(nil)` event
	func catchErrorReplacingWithNil() -> Future<T?, Never> {
		return self
			.map { Optional.some($0) }
			.recover { _ in return nil }
	}
}
