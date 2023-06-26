/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Mobilecore

public enum VerificationPolicy: Codable, CaseIterable, Sendable {
	/// 3G policy
	case policy3G
	/// 1G policy
	case policy1G
	
	public var scanPolicy: String {
		switch self {
			case .policy3G:
				return MobilecoreVERIFICATION_POLICY_3G
			case .policy1G:
				return MobilecoreVERIFICATION_POLICY_1G
		}
	}
	
	public var featureFlag: String {
		switch self {
			case .policy3G:
				return "3G"
			case .policy1G:
				return "1G"
		}
	}
	
	public var localization: String {
		switch self {
			case .policy3G:
				return "3G"
			case .policy1G:
				return "1G"
		}
	}
}
