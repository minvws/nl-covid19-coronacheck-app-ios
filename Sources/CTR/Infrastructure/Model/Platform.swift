/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/**
Platform to detect if we are running in the simulator
*/
struct Platform {
	static let isSimulator: Bool = {
		var isSim = false
		#if arch(i386) || arch(x86_64)
		isSim = true
		#endif
		return isSim
	}()
}
