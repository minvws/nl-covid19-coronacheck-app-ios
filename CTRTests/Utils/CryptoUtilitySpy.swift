/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class CryptoUtilitySpy: CryptoUtilityProtocol {
	func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void) {

	}

	func signature(forData data: Data, key: Data) -> Data {
		return Data()
	}

	func sha256(data: Data) -> String? {
		return nil
	}
}
