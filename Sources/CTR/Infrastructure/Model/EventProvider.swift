/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// The Event providers
struct EventProvider: Codable, Equatable {

	/// The identifier of the provider
	let identifier: String

	/// The name of the provider
	let name: String

	/// The url of the provider to fetch the unomi
	let unomiURL: URL?

	/// The url of the provider to fetch the events
	let eventURL: URL?

	/// The ssl certificate of the provider
	let cmsCertificate: String

	/// The ssl certificate of the provider
	let tlsCertificate: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "provider_identifier"
		case name
		case unomiURL = "unomi_url"
		case eventURL = "event_url"
		case cmsCertificate = "cms"
		case tlsCertificate = "tls"
	}
}
