/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Equivalent to `DispatchQueue.main.async`, except that if you're already
/// on the main thread it executes immediately.
///
/// This is useful during tests: https://www.swiftbysundell.com/articles/reducing-flakiness-in-swift-tests/#jumping-queues
func performUIUpdate(using closure: @escaping () -> Void) {
	// If we are already on the main thread, execute the closure directly
	if Thread.isMainThread {
		closure()
	} else {
		DispatchQueue.main.async(execute: closure)
	}
}
