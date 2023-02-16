/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Platform to detect if we are running in the simulator (used for preventing camera features)
public struct Platform {

	public static let isSimulator: Bool = {

		#if targetEnvironment(simulator)
		return true
		#else
		return false
		#endif
	}()
}
