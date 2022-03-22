/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// References:
// - https://www.objc.io/blog/2018/12/18/atomic-variables/
// - https://www.vadimbulavin.com/swift-atomic-properties-with-property-wrappers/

@propertyWrapper
class Atomic<Value> {
	
	/// Serial Queue
	private let queue = DispatchQueue(label: "nl.coronacheck.atomicserialqueue.\(UUID().uuidString)")
	private var value: Value
	
	var didSet: ((Atomic<Value>) -> Void)?
	
	var projectedValue: Atomic<Value> {
		return self
	}
	
	var wrappedValue: Value {
		get {
			return queue.sync { value }
		}
		set {
			mutate { value in
				value = newValue
			}
		}
	}
	
	init(wrappedValue: Value) {
		self.value = wrappedValue
	}
	
	func mutate(_ mutation: (inout Value) -> Void) {
		
		queue.sync {
			mutation(&value)
			
			if let didSet = self.didSet {
				DispatchQueue.main.async(execute: {
					didSet(self)
				})
			}
		}
	}
}
