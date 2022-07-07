/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MaxConfig: IssuerConfiguration {
	
	func getIssuerURL() -> URL {
		return Configuration().getTVSURL()
	}
	
	func getClientId() -> String {
		return Configuration().getConsumerId()
	}
	
	func getRedirectUri() -> URL {
		return Configuration().getRedirectUri()
	}
}

class PapConfig: IssuerConfiguration {
	
	func getIssuerURL() -> URL {
		return Configuration().getPortalURL()
	}
	
	func getClientId() -> String {
		return Configuration().getPortalClientId()
	}
	
	func getRedirectUri() -> URL {
		return Configuration().getPortalRedirectUri()
	}
}
