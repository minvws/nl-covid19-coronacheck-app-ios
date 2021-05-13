/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The access token used to fetch fat and thin ID Hashes
struct AccessToken: Codable {

	/// The provider identifier
	let providerIdentifier: String

	/// The unomi access token
	let unomiAccessToken: String

	/// The event access token
	let eventAccessToken: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case providerIdentifier = "provider_identifier"
		case eventAccessToken = "event"
		case unomiAccessToken = "unomi"
	}
}
