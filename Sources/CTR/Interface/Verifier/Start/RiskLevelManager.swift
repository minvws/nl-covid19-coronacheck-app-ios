/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RiskLevelManaging: AnyObject {
	var state: VerificationPolicy? { get }
	
	func update(verificationPolicy: VerificationPolicy?)
	func appendObserver(_ observer: @escaping (VerificationPolicy?) -> Void) -> RiskLevelManager.ObserverToken
	func removeObserver(token: RiskLevelManager.ObserverToken)
	func wipePersistedData()
}

final class RiskLevelManager: RiskLevelManaging {
	typealias ObserverToken = UUID
	
	// MARK: - Vars
	
	fileprivate(set) var state: VerificationPolicy? {
		get {
			keychainVerificationPolicy
		}
		set {
			keychainVerificationPolicy = newValue
			notifyObservers()
		}
	}
	
	fileprivate var keychainVerificationPolicy: VerificationPolicy? {
		get { secureUserSettings.verificationPolicy }
		set { secureUserSettings.verificationPolicy = newValue }
	}

	private var observers = [ObserverToken: (VerificationPolicy?) -> Void]()
	
	// MARK: - Dependencies
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}
	
	func update(verificationPolicy: VerificationPolicy?) {
		state = verificationPolicy
	}
	
	// MARK: - Observer notifications
	
	/// Be careful to use weak references to your observers within the closure, and
	/// to unregister your observer using the returned `ObserverToken`.
	func appendObserver(_ observer: @escaping (VerificationPolicy?) -> Void) -> ObserverToken {
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

	func wipePersistedData() {

		observers = [:]
		keychainVerificationPolicy = .none
		state = keychainVerificationPolicy
	}
}

#if DEBUG
extension RiskLevelManaging {
	
	/// LLDB:
	/// `e import CTR`
	/// `Current.riskLevelManager.set(VerificationPolicy: .policy3G)`
	func set(verificationPolicy: VerificationPolicy) {
		let casted = self as! RiskLevelManager // swiftlint:disable:this force_cast
		casted.state = verificationPolicy
	}
}
#endif
