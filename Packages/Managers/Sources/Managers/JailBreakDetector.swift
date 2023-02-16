/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import IOSSecuritySuite

public protocol JailBreakProtocol: AnyObject {

	/// Is this device jail broken?
	func isJailBroken() -> Bool
}

public class JailBreakDetector: JailBreakProtocol {

	public init() {}

	/// Is this device jail broken?
	public func isJailBroken() -> Bool {

		let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailedChecks()
		return jailbreakStatus.jailbroken
	}
}
