/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

enum VerificationPolicy: Codable {
	/// 3G policy
	case policy3G
	/// 1G policy
	case policy1G
	
	var scanPolicy: String {
		switch self {
			case .policy3G:
				return MobilecoreVERIFICATION_POLICY_3G
			case .policy1G:
				// Update when working on ticket #3087
				return ""
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
	
	var localization: String {
		switch self {
			case .policy3G:
				return "3G"
			case .policy1G:
				return "1G"
		}
	}
}
