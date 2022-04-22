/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum DCCScanResult {
	case ctb
	case dutchDCC(dcc: String)
	case foreignDCC(dcc: String)
	case unknown
}

protocol DCCScannerProtocol: AnyObject {
	
	func scan(_ code: String) -> DCCScanResult
}

class DCCScanner: DCCScannerProtocol, Logging {
	
	/// The crypto manager
	weak var cryptoManager: CryptoManaging? = Current.cryptoManager
	
	func scan(_ code: String) -> DCCScanResult {
		
		if code.lowercased().hasPrefix("nl") {
			return .ctb
		} else if let euCredential = cryptoManager?.readEuCredentials(Data(code.utf8)) {
			logInfo("Scanned: \(euCredential)")
			if euCredential.isForeignDCC {
				return .foreignDCC(dcc: code)
			} else {
				return .dutchDCC(dcc: code)
			}
		} else {
			return .unknown
		}
	}
}
