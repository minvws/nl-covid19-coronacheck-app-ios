/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The response of a unomi call
struct UnomiResponse: Codable {

	/// The provider identifier
	let providerIdentifier: String

	/// The protocol version
	let protocolVersion: String

	/// The event access token
	let informationAvailable: Bool

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case providerIdentifier
		case protocolVersion
		case informationAvailable
	}
}
