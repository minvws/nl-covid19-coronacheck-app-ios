/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// 🔭
/// Mechanism for registering for external state change notifications
class Observatory<T> {
	
	// MARK: - Types -
	typealias ObserverToken = UUID

	// MARK: - Static
	
	/// Vends an observatory instance, along with a callback to allow the holder
	/// to publish updates to registered observers.
	/// (this allows `notifyObservers()` itself to stay private)
	///
	static func create() -> (Observatory<T>, (T) -> Void) {
		let observatory = Observatory<T>()
		let updateCallback = observatory.notifyObservers
		return (observatory, updateCallback)
	}
	
	// MARK: - Init
	
	private init() {}
	
	// MARK: - Vars
	
	private var observers = [ObserverToken: (T) -> Void]()
	
	// MARK: - Public functions
	
	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func append(observer: @escaping (T) -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		observers[newToken] = observer
		return newToken
	}

	func remove(observerToken token: ObserverToken) {
		observers[token] = nil
	}

	func removeAll() {
		observers = [:]
	}
	
	// MARK: - Private functions
	
	private func notifyObservers(newValue: T) {
		observers.values.forEach { callback in
			callback(newValue)
		}
	}
}
