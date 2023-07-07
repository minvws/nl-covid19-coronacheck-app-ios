/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public class TimerSpy: Timeable {
	
	public init() {}

	public var invokedInvalidate = false
	public var invokedInvalidateCount = 0

	public func invalidate() {
		invokedInvalidate = true
		invokedInvalidateCount += 1
	}

	public var invokedFire = false
	public var invokedFireCount = 0

	public func fire() {
		invokedFire = true
		invokedFireCount += 1
	}
}
