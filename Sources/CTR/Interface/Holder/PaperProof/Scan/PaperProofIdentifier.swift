/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum PaperProofType: Equatable {
	case hasDomesticPrefix
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
		
		guard let cryptoManager = cryptoManager else {
			return .unknown
		}
	
		let data = Data(code.utf8)
		
		if cryptoManager.hasDomesticPrefix(data) {
			return .hasDomesticPrefix
		} else if cryptoManager.isForeignDCC(data) {
			return .foreignDCC(dcc: code)
		} else if cryptoManager.isDCC(data) {
			return .dutchDCC(dcc: code)
		} else {
			return .unknown
		}
	}
}
