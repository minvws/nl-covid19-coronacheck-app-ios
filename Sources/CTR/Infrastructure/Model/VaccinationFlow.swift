/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct VaccinationFlow {

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

	/// A wrapper around an event result.
	struct EventResultWrapper: Codable {

		/// The provider identifier
		let providerIdentifier: String

		/// The protocol version
		let protocolVersion: String

		let identity: Identity

		/// The state of the test
		let status: EventState

		/// The vaccination events
		var events: [Event] = []

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identity = "holder"
			case protocolVersion
			case providerIdentifier
			case status
			case events
		}
	}

	/// The state of a test
	enum EventState: String, Codable {

		/// The vaccination result is pending
		case pending

		/// The vaccination result is complete
		/// This refers to the data-completeness, not vaccination status.
		case complete

		/// Unknown state
		case unknown

		/// Custom initializer to default to unknown state
		/// - Parameter decoder: the decoder
		/// - Throws: Decoding error
		init(from decoder: Decoder) throws {
			self = try EventState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
		}
	}

	struct Identity: Codable {

		let identityHash: String

		let firstName: String

		let lastName: String

		let birthDateString: String

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identityHash
			case firstName
			case lastName
			case birthDateString = "birthDate"
		}
	}

	struct Event: Codable {

		/// The type of event (vaccination / vaccinationComplete)
		let type: String

		/// The identifier of this event
		let unique: String

		/// The vaccination
		let vaccination: Vaccination?

		/// The complete vaccination
		let vaccinationComplete: Vaccination?
	}

	/// An actual vaccination
	struct Vaccination: Codable {

		/// The date of administering the vaccin
		let dateString: String?

		/// the hpk code of the vaccin (https://hpkcode.nl/)
		/// If available: type/brand can be left blank.
		let hpkCode: String?

		/// the type of vaccin
		let type: String?

		/// the brand of the vaccin
		let brand: String?

		/// The batch number of the vaccin
		let batchNumber: String?

		/// The place of administering
		let administeringCenter: String?

		/// The country in which the administering took place
		let country: String?

		enum CodingKeys: String, CodingKey {

			case dateString = "date"
			case hpkCode
			case type
			case brand
			case batchNumber
			case administeringCenter
			case country
		}
	}
}
