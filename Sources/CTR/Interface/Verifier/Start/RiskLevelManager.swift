/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RiskLevelManaging {
	func appendObserver(_ observer: @escaping (RiskLevel?) -> Void) -> RiskLevelManager.ObserverToken
	func removeObserver(token: RiskLevelManager.ObserverToken)
	
	init()
}

final class RiskLevelManager: RiskLevelManaging {
	typealias ObserverToken = UUID
	
	fileprivate(set) var state: RiskLevel? {
		didSet {
			notifyObservers()
		}
	}
	private var observers = [ObserverToken: (RiskLevel?) -> Void]()
	
	required init() {
		// Todo: persist the risk level across launches (keychain).
		state = nil
	}
	
	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func appendObserver(_ observer: @escaping (RiskLevel?) -> Void) -> ObserverToken {
		let newToken = ObserverToken()
		observers[newToken] = observer
		return newToken
	}

	func removeObserver(token: ObserverToken) {
		observers[token] = nil
	}

	private func notifyObservers() {
		observers.values.forEach { callback in
			callback(state)
		}
	}
}

#if DEBUG
extension RiskLevelManaging {
	
	/// LLDB:
	/// `e import CTR`
	/// `Services.riskLevelManager.set(riskLevel: .high)`
	func set(riskLevel: RiskLevel) {
		let casted = self as! RiskLevelManager // swiftlint:disable:this force_cast
		casted.state = riskLevel
	}
}
#endif
