/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import IOSSecuritySuite

protocol JailBreakProtocol: AnyObject {

	init()

	/// Is this device jail broken?
	func isJailBroken() -> Bool
}

class JailBreakDetector: JailBreakProtocol, Logging {

	required init() {
		
	}

	/// Is this device jail broken?
	func isJailBroken() -> Bool {

		let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailedChecks()
		return jailbreakStatus.jailbroken
	}
}
