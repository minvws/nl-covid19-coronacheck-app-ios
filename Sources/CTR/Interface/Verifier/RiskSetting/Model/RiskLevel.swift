/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

enum RiskLevel: Codable {
	/// 3G policy
	case low
	/// 2G policy
	case high
	/// 2G+ policy
	case highPlus
	
	var isLow: Bool {
		return self == .low
	}
	
	var isHigh: Bool {
		return self == .high
	}
	
	var isHighPlus: Bool {
		return self == .highPlus
	}
	
	var policy: String {
		switch self {
			case .low:
				return MobilecoreVERIFICATION_POLICY_3G
			case .high:
				return MobilecoreVERIFICATION_POLICY_2G
			case .highPlus:
				// Update
				return ""
		}
	}
}
