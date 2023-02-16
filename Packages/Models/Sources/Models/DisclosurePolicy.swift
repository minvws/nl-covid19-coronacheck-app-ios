/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

public enum DisclosurePolicy: Codable, CaseIterable {
	/// 3G policy
	case policy3G
	/// 1G policy
	case policy1G
	
	public var mobileDisclosurePolicy: String {
		switch self {
			case .policy3G:
				return MobilecoreDISCLOSURE_POLICY_3G
			case .policy1G:
				return MobilecoreDISCLOSURE_POLICY_1G
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
