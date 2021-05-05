/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import IOSSecuritySuite

protocol JailBreakProtocol {

	/// Is this device jail broken?
	func isJailBroken() -> Bool

//	/// Should we warn the user
//	func shouldWarnUser() -> Bool
//
//	/// The user has seen the warning
//	func warningHasBeenSeen()
}

class JailBreakDetector: JailBreakProtocol, Logging {

//	/// The user settings to store if the warning should be shown / has been seen.
//	private var userSettings: UserSettingsProtocol
//
//	/// Initializer
//	/// - Parameter userSettings: the user settings
//	init(userSettings: UserSettingsProtocol = UserSettings()) {
//
//		self.userSettings = userSettings
//	}

	/// Is this device jail broken?
	func isJailBroken() -> Bool {

		let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailedChecks()
		if jailbreakStatus.jailbroken {
			if (jailbreakStatus.failedChecks.contains { $0.check == .existenceOfSuspiciousFiles }) && (jailbreakStatus.failedChecks.contains { $0.check == .suspiciousFilesCanBeOpened }) {
				logInfo("This device is a real jailbroken device")
				logDebug("Reasons: \(IOSSecuritySuite.amIJailbrokenWithFailMessage())")
				return true
			}
		}
		return false
	}

//	/// Should we warn the user
//	func shouldWarnUser() -> Bool {
//
//		return !userSettings.jailbreakWarningShown
//	}
//
//	/// The user has seen the warning
//	func warningHasBeenSeen() {
//
//		userSettings.jailbreakWarningShown = true
//	}
}
