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
	
	static func holderDashboardQRExpired(originType: OriginType) -> String {
		switch originType {

			case .test:
				return L.holder_dashboard_originExpiredBanner_internationalTest_title()
			case .vaccination:
				return L.holder_dashboard_originExpiredBanner_internationalVaccine_title()
			case .recovery:
				return L.holder_dashboard_originExpiredBanner_internationalRecovery_title()
		}
	}
}
