/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension String {
	
	static var cryptoLibNotInitializedTitle: String {
		
		return Localization.string(for: "general.error.cryptolib.title")
	}
	
	static var cryptoLibNotInitializedMessage: String {
		
		return Localization.string(for: "general.error.cryptolib.message")
	}
	
	static var cryptoLibNotInitializedRetry: String {
		
		return Localization.string(for: "general.error.cryptolib.retry")
	}
}
