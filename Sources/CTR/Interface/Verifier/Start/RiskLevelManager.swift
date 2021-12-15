/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RiskLevelManaging: AnyObject {
	var state: RiskLevel? { get }
	
	init()
	func update(riskLevel: RiskLevel?)
	func appendObserver(_ observer: @escaping (RiskLevel?) -> Void) -> RiskLevelManager.ObserverToken
	func removeObserver(token: RiskLevelManager.ObserverToken)
	func reset()
}

final class RiskLevelManager: RiskLevelManaging {
	typealias ObserverToken = UUID
	
	// MARK: - Types

	private struct Constants {
		static let keychainService: String = {
			guard !ProcessInfo.processInfo.isTesting else { return UUID().uuidString }
			return "RiskLevelManager\(Configuration().getEnvironment())"
		}()
	}
	
	// MARK: - Vars
	
	fileprivate(set) var state: RiskLevel? {
		get {
			keychainRiskLevel
		}
		set {
			keychainRiskLevel = newValue
			notifyObservers()
		}
	}
	private var observers = [ObserverToken: (RiskLevel?) -> Void]()
	
	@Keychain(name: "riskLevel", service: Constants.keychainService, clearOnReinstall: false)
	fileprivate var keychainRiskLevel: RiskLevel? = .none // swiftlint:disable:this let_var_whitespace
	
	required init() {}
	
	func update(riskLevel: RiskLevel?) {
		state = riskLevel
	}
	
	// MARK: - Observer notifications
	
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
		let newState = state
		observers.values.forEach { callback in
			callback(newState)
		}
	}

	func reset() {

		observers = [:]
		keychainRiskLevel = .none
		state = keychainRiskLevel
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
