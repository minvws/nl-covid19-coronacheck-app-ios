/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI
import OpenIDConnect

final class MaxConfig: OpenIDConnectConfiguration {
	
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

final class PapConfig: OpenIDConnectConfiguration {
	
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
