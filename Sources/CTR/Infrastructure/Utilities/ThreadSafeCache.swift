/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// A basic generic cache which can only be accessed synchronously via a private queue
final class ThreadSafeCache<Key: Hashable, Value> {
	
	private var storage: [Key: Value] = [:]
	private let queue = DispatchQueue(label: "nl.coronacheck.threadsafe.\(UUID().uuidString)")
	
	subscript(key: Key) -> Value? {
		get {
			queue.sync {
				storage[key]
			}
		}
		set {
			queue.sync {
				storage[key] = newValue
			}
		}
	}
	
	var values: [Key: Value] {
		return storage
	}
}
