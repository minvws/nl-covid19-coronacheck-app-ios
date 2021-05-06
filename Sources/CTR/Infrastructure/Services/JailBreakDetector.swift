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
}

class JailBreakDetector: JailBreakProtocol, Logging {

	/// Is this device jail broken?
	func isJailBroken() -> Bool {

		let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailedChecks()
		if jailbreakStatus.jailbroken {
			if (jailbreakStatus.failedChecks.contains { $0.check == .existenceOfSuspiciousFiles })
				&& (jailbreakStatus.failedChecks.contains { $0.check == .suspiciousFilesCanBeOpened }) {
				logInfo("This device is a real jailbroken device")
				logDebug("Reasons: \(IOSSecuritySuite.amIJailbrokenWithFailMessage())")
				return true
			}
		}
		return false
	}
}
