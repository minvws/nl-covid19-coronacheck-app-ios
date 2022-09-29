/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import BrightFutures
import Shared

extension Future {

	/// Prevents a Failure propagating by catching it and replacing it with a `.success(nil)` event
	func catchErrorReplacingWithNil() -> Future<T?, Never> {
		return self
			.map { Optional.some($0) }
			.recover { _ in return nil }
	}
}

extension Future {

	func logVerbose(_ message: String) -> Future<T, E> {
		return self.map { value -> T in
			Shared.logVerbose(message + ": \(value)")
			return value
		}
	}

	func logDebug(_ message: String) -> Future<T, E> {
		return self.map { value -> T in
			Shared.logDebug(message + ": \(value)")
			return value
		}
	}

	func logInfo(_ message: String) -> Future<T, E> {
		return self.map { value -> T in
			Shared.logInfo(message + ": \(value)")
			return value
		}
	}

	func logWarning(_ message: String) -> Future<T, E> {
		return self.map { value -> T in
			Shared.logWarning(message + ": \(value)")
			return value
		}
	}

	func logError(_ message: String) -> Future<T, E> {
		return self.map { value -> T in
			Shared.logError(message + ": \(value)")
			return value
		}
	}
}
