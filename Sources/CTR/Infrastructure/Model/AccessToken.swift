/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// A wrapper around a test result.
struct AccessToken: Codable {

	/// The provider identifier
	let providerIdentifier: String

	/// The unomi access token
	let unomi: String

	/// The event access token
	let event: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case providerIdentifier = "provider_identifier"
		case event
		case unomi
	}
}
