/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct SignedResponse: Codable, Equatable {
	
	/// The payload
	let payload: String
	
	/// The signature
	let signature: String
	
	// Key mapping
	enum CodingKeys: String, CodingKey {
		
		case payload
		case signature
	}

	var decodedPayload: Data? {
		Data(base64Encoded: payload)
	}

	var decodedSignature: Data? {
		Data(base64Encoded: signature)
	}
}
