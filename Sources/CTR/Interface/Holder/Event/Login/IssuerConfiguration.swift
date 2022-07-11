/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CryptoKit

final class MaxConfig: IssuerConfiguration {
	
	var issuerUrl: URL {
		return Configuration().getTVSURL()
	}
	
	var clientId: String {
		return Configuration().getTVSClientId()
	}
	
	var redirectUri: URL {
		return Configuration().getTVSRedirectUri()
	}
}

final class PapConfig: IssuerConfiguration {
	
	var issuerUrl: URL {
		return Configuration().getPortalURL()
	}
	
	var clientId: String {
		return Configuration().getPortalClientId()
	}
	
	var redirectUri: URL {
		return Configuration().getPortalRedirectUri()
	}
}
