/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

enum VerificationPolicy: Codable, CaseIterable {
	/// 3G policy
	case policy3G
	/// 1G policy
	case policy1G
	
	var policy: String {
		switch self {
			case .policy3G:
				return MobilecoreVERIFICATION_POLICY_3G
			case .policy1G:
				return MobilecoreVERIFICATION_POLICY_1G
		}
	}
	
	var featureFlag: String {
		switch self {
			case .policy3G:
				return "3G"
			case .policy1G:
				return "1G"
		}
	}
}
