/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Models

public protocol VerificationPolicyManaging: AnyObject {
	var state: VerificationPolicy? { get }
	var observatory: Observatory<VerificationPolicy?> { get }

	func update(verificationPolicy: VerificationPolicy?)
	func wipeScanMode()
	func wipePersistedData()
}

/// Distributes changes to the current "risk level" to observers
/// RiskLevel == VerificationPolicy
public final class VerificationPolicyManager: VerificationPolicyManaging {
	// MARK: - Vars
	
	public fileprivate(set) var state: VerificationPolicy? {
		get {
			keychainVerificationPolicy
		}
		set {
			keychainVerificationPolicy = newValue
			notifyObservers(newValue)
		}
	}
	
	// Mechanism for registering for external state change notifications:
	public let observatory: Observatory<VerificationPolicy?>
	private let notifyObservers: (VerificationPolicy?) -> Void

	private var keychainVerificationPolicy: VerificationPolicy? {
		get { secureUserSettings.verificationPolicy }
		set { secureUserSettings.verificationPolicy = newValue }
	}

	// MARK: - Dependencies
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	public required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
		(self.observatory, self.notifyObservers) = Observatory<VerificationPolicy?>.create()
	}
	
	public func update(verificationPolicy: VerificationPolicy?) {
		state = verificationPolicy
	}
	
	public func wipeScanMode() {
		
		keychainVerificationPolicy = .none
		state = keychainVerificationPolicy
	}
	
	public func wipePersistedData() {

		observatory.removeAll()
		wipeScanMode()
	}
}
