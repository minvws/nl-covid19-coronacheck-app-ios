/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import AppAuthEnterpriseUserAgent

extension OIDExternalUserAgentIOSCustomBrowser {

	/// Get the system default browser (i.e. the one that opens a http/https link
	/// - Returns: optional browser
	class func defaultBrowser() -> OIDExternalUserAgentIOSCustomBrowser? {

		return OIDExternalUserAgentIOSCustomBrowser(
			urlTransformation: urlTransformationSchemeSubstitutionHTTPS("https", http: "http"),
			canOpenURLScheme: "https",
			appStore: nil
		)
	}
}
