/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared

enum UniversalLink: Equatable {
	
	case redeemHolderToken(requestToken: RequestToken)
	case redeemVaccinationAssessment(requestToken: RequestToken)
	case thirdPartyTicketApp(returnURL: URL?)
	case tvsAuth(returnURL: URL?)
	case thirdPartyScannerApp(returnURL: URL?)
}
