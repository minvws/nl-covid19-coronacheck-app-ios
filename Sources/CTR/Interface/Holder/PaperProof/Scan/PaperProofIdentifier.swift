/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum PaperProofType {
	case ctb
	case dutchDCC(dcc: String)
	case foreignDCC(dcc: String)
	case unknown
}

protocol PaperProofIdentifierProtocol: AnyObject {
	
	func identify(_ code: String) -> PaperProofType
}

class PaperProofIdentifier: PaperProofIdentifierProtocol {
	
	/// The crypto manager
	weak var cryptoManager: CryptoManaging? = Current.cryptoManager
	
	func identify(_ code: String) -> PaperProofType {
		
		if code.lowercased().hasPrefix("nl") {
			return .ctb
		} else if let euCredential = cryptoManager?.readEuCredentials(Data(code.utf8)) {
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
