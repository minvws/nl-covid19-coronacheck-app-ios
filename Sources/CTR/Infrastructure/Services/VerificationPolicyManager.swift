/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol VerificationPolicyManaging: AnyObject {
	var state: VerificationPolicy? { get }
	var observatory: Observatory<VerificationPolicy?> { get }

	func update(verificationPolicy: VerificationPolicy?)
	func wipeScanMode()
	func wipePersistedData()
}

/// Distributes changes to the current "risk level" to observers
/// RiskLevel == VerificationPolicy
final class VerificationPolicyManager: VerificationPolicyManaging {
	// MARK: - Vars
	
	fileprivate(set) var state: VerificationPolicy? {
		get {
			keychainVerificationPolicy
		}
		set {
			keychainVerificationPolicy = newValue
			notifyObservers(newValue)
		}
	}
	
	// Mechanism for registering for external state change notifications:
	let observatory: Observatory<VerificationPolicy?>
	private let notifyObservers: (VerificationPolicy?) -> Void

	private var keychainVerificationPolicy: VerificationPolicy? {
		get { secureUserSettings.verificationPolicy }
		set { secureUserSettings.verificationPolicy = newValue }
	}

	// MARK: - Dependencies
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
		(self.observatory, self.notifyObservers) = Observatory<VerificationPolicy?>.create()
	}
	
	func update(verificationPolicy: VerificationPolicy?) {
		state = verificationPolicy
	}
	
	func wipeScanMode() {
		
		keychainVerificationPolicy = .none
		state = keychainVerificationPolicy
	}
	
	func wipePersistedData() {

		observatory.removeAll()
		wipeScanMode()
	}
}

#if DEBUG
extension VerificationPolicyManaging {
	
	/// LLDB:
	/// `e import CTR`
	/// `Current.verificationPolicyManager.set(VerificationPolicy: .policy3G)`
	func set(verificationPolicy: VerificationPolicy) {
		let casted = self as! VerificationPolicyManager // swiftlint:disable:this force_cast
		casted.state = verificationPolicy
	}
}
#endif
