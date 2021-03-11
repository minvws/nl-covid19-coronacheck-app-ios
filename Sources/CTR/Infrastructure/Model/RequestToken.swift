/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The request token to fetch a test result form a commercial tester
struct RequestToken: Codable {

	/// The request token
	let token: String

	/// The version of the protocol
	let protocolVersion: String

	/// The identifier of the provider
	let providerIdentifier: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case token
		case protocolVersion
		case providerIdentifier
	}
}
