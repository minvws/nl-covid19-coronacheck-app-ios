/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct SignedResponse: Codable, Equatable {
	
	/// The payload
	public let payload: String
	
	/// The signature
	public let signature: String
	
	// Key mapping
	enum CodingKeys: String, CodingKey {
		
		case payload
		case signature
	}

	public var decodedPayload: Data? {
		Data(base64Encoded: payload)
	}

	public var decodedSignature: Data? {
		Data(base64Encoded: signature)
	}
	
	public init(payload: String, signature: String) {
		self.payload = payload
		self.signature = signature
	}
}
