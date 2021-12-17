/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RiskLevelManaging: AnyObject {
	var state: RiskLevel? { get }
	
	init(secureUserSettings: SecureUserSettingsProtocol)
	func update(riskLevel: RiskLevel?)
	func appendObserver(_ observer: @escaping (RiskLevel?) -> Void) -> RiskLevelManager.ObserverToken
	func removeObserver(token: RiskLevelManager.ObserverToken)
	func reset()
}

final class RiskLevelManager: RiskLevelManaging {
	typealias ObserverToken = UUID
	
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
	
	fileprivate var keychainRiskLevel: RiskLevel? {
		get { secureUserSettings.riskLevel }
		set { secureUserSettings.riskLevel = newValue }
	}

	private var observers = [ObserverToken: (RiskLevel?) -> Void]()
	
	// MARK: - Dependencies
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}
	
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
	/// `Current.riskLevelManager.set(riskLevel: .high)`
	func set(riskLevel: RiskLevel) {
		let casted = self as! RiskLevelManager // swiftlint:disable:this force_cast
		casted.state = riskLevel
	}
}
#endif
