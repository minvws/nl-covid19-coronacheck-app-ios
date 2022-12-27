/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public extension ProcessInfo {

	/// Are we unit testing?
	var isUnitTesting: Bool {

		// "--unittesting" should be in the arguments of the scheme
		return ProcessInfo.processInfo.arguments.contains("--unittesting")
	}
}
