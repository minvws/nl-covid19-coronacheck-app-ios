/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/*
 Thread-safe way of tracking ProgressIndication by incrementing/decrementing an integer
 */
public class ProgressIndicationCounter {

	private let shouldShowProgressIndicationCallback: (Bool) -> Void

	public init(_ shouldShowProgressIndicationCallback: @escaping (Bool) -> Void) {
		self.shouldShowProgressIndicationCallback = shouldShowProgressIndicationCallback
	}

	private(set) var isActive: Bool = false {
		didSet {
			guard oldValue != isActive else { return }
			shouldShowProgressIndicationCallback(isActive)
		}
	}

	/// Inverts `isActive`
	public var isInactive: Bool {
		return !isActive
	}

	/// 0 = inactive, >=1 = active
	private var counter = 0 {
		didSet {
			objc_sync_enter(self)
			defer { objc_sync_exit(self) }

			isActive = counter > 0
		}
	}

	public func increment() {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		counter += 1
	}

	public func decrement() {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }

		guard counter > 0 else { return }

		counter -= 1
	}
}
