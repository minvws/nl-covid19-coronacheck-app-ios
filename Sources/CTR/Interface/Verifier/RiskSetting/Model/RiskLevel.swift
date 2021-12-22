/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

enum RiskLevel: Codable {
	case low
	case high
	
	var isLow: Bool {
		return self == .low
	}
	
	var isHigh: Bool {
		return self == .high
	}
	
	var policy: String {
		switch self {
			case .low:
				return MobilecoreVERIFICATION_POLICY_3G
			case .high:
				return MobilecoreVERIFICATION_POLICY_2G
		}
	}
}
