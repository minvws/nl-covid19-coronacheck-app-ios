/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct Vaccination {

	/// The access token used to fetch fat and thin ID Hashes
	struct AccessToken: Codable, Equatable {

		/// The provider identifier
		let providerIdentifier: String

		/// The unomi access token (thin ID Hash)
		let unomiAccessToken: String

		/// The event access token (fat ID Hash)
		let eventAccessToken: String

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case providerIdentifier = "provider_identifier"
			case eventAccessToken = "event"
			case unomiAccessToken = "unomi"
		}
	}

	// A Vaccination Event Provider (VEP)
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

		/// The access token for api calls
		var accessToken: AccessToken?

		/// Result of the unomi call
		var eventInformationAvailable: EventInformationAvailable?

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

	/// The response of a unomi call
	struct EventInformationAvailable: Codable, Equatable {

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
	
}
