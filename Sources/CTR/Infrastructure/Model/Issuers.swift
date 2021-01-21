//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/


import Foundation

struct Issuer: Codable {

	var identifier: String
	var name: String
	var publicKey: String

	enum CodingKeys: String, CodingKey {

		case identifier = "uuid"
		case name
		case publicKey = "public_key"
	}
}

struct Issuers: Codable {

	var issuers: [Issuer]
	enum CodingKeys: String, CodingKey {

		case issuers
	}
}
