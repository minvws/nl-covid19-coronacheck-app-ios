/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

/// Provides the ability to observe value changes with a closure.
///
/// # Example use:
/// ````
/// @Bindable private(set) var title = "Add Contact"
/// $title.binding = { [weak self] in self?.titleLabel.text = $0 }
/// ````
///
/// - Tag: Bindable
@propertyWrapper public class Bindable<T> {
	
	public var value: T
	public private(set) lazy var projectedValue = Binder { [unowned self] in self.value }
	
	public init(wrappedValue: T) {
		
		value = wrappedValue
	}
	
	public var wrappedValue: T {
		get {
			return value
		}
		
		set {
			value = newValue
			projectedValue.binding?(newValue)
		}
	}
	
	// Use a nested class to store the binding closure. This way a @Bindable property can be declared immutable and still have a mutable value for the closure.
	public class Binder {
		
		private var valueProvider: () -> T
		public var binding: ((T) -> Void)? { didSet { binding?(valueProvider()) } }
		
		init(valueProvider: @escaping () -> T) {
			
			self.valueProvider = valueProvider
		}
	}
}
