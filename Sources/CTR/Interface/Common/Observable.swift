/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// wrap a value to make it observable (i.e. observers get updates to `value`).
/// immediately calls observer with current value when said observer is added.
class Observable<T> {
	
	private struct Observer: Equatable {
		static func == (lhs: Observable<T>.Observer, rhs: Observable<T>.Observer) -> Bool {
			return lhs.id == rhs.id
		}
 
		/// Callback to pass a value to the Observer:
		let receive: (T) -> Void
		
		private let id = UUID() // for Equatable conformance
	}
	
	var value: T {
		didSet {
			observers.forEach { observer in observer.receive(value) }
		}
	}
	
	private var observers = [Observer]()
	
	init(value: T) {
		self.value = value
	}

	/// Observe until the Observable itself is deallocated
	func observe(_ handler: @escaping (T) -> Void) {
		let observer = Observer(receive: handler)
		observers.append(observer)
		observer.receive(value)
	}
}

// MARK: - Disposable Observables -

extension Observable {
	
	/// Returned from `Observable.observe`, allowing an observation to be unregistered either
	/// by deallocating the Disposable instance, or manually calling `dispose()`:
	class Disposable {
		private let teardown: () -> Void
		
		fileprivate init(_ teardown: @escaping () -> Void) {
			self.teardown = teardown
		}
		
		private func dispose() {
			teardown()
		}
		
		deinit {
			dispose()
		}
	}
	
	/// Observe until the returned Disposable is deallocated
	func observeReturningDisposable(_ handler: @escaping (T) -> Void) -> Disposable {
		let observer = Observer(receive: handler)
		observers.append(observer)
		observer.receive(value)
		
		return Disposable { [weak self] in
			self?.observers.removeAll(where: { $0 == observer })
		}
	}
}
