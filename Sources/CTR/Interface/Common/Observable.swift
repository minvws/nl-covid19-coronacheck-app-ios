/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// wrap a value to make it observable (i.e. observers get updates to `value`).
/// immediately calls observer with current value when said observer is added.
class Observable<T> {
	
	var value: T {
		didSet {
			observers.forEach { observer in observer(value) }
		}
	}
	
	private var observers = [(T) -> Void]()
	
	init(value: T) {
		self.value = value
	}
	
	func observe(_ handler: @escaping (T) -> Void) {
		observers.append(handler)
		handler(value)
	}
}
