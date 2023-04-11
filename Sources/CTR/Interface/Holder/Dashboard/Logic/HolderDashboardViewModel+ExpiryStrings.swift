/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import Models
import Resources

extension String {
	
	static func holderDashboardQRExpired(originType: OriginType, region: QRCodeValidityRegion) -> String {
		switch (originType, region) {
			case (.test, .domestic):
				return L.holder_dashboard_originExpiredBanner_domesticTest_title()
			case (.vaccination, .domestic):
				return L.holder_dashboard_originExpiredBanner_domesticVaccine_title()
			case (.recovery, .domestic):
				return L.holder_dashboard_originExpiredBanner_domesticRecovery_title()
				
			case (.test, .europeanUnion):
				return L.holder_dashboard_originExpiredBanner_internationalTest_title()
			case (.vaccination, .europeanUnion):
				return L.holder_dashboard_originExpiredBanner_internationalVaccine_title()
			case (.recovery, .europeanUnion):
				return L.holder_dashboard_originExpiredBanner_internationalRecovery_title()
		}
	}
}
