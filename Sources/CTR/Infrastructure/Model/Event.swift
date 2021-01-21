//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct AgentEnvelope: Codable {

	var agent: VerifierAgent
	var signature: String

	enum CodingKeys: String, CodingKey {

		case agent
		case signature = "agent_signature"
	}
}

struct EventEnvelope: Codable {

	var event: Event
	var signature: String

	enum CodingKeys: String, CodingKey {

		case event
		case signature = "event_signature"
	}
}

struct VerifierAgent: Codable {

	var event: Event

	enum CodingKeys: String, CodingKey {

		case event
	}
}

struct Event: Codable {

	var title: String?
	var identifier: String?
	var privateKey: String?
	var publicKey: String?
	var validFrom: Int64?
	var validTo: Int64?
	var location: EventLocation?
	var type: EventType?
	var validTestsTypes: [TestType] = []

	enum CodingKeys: String, CodingKey {

		case title = "name"
		case identifier = "uuid"
		case publicKey = "public_key"
		case privateKey = "private_key"
		case validFrom = "valid_from"
		case validTo = "valid_to"
		case validTestsTypes = "valid_tests"
		case location
		case type
	}
}

struct EventLocation: Codable {

	var identifier: String?
	var name: String?
	var streetname: String?
	var housenumber: Int?
	var zipcode: String?

	enum CodingKeys: String, CodingKey {

		case identifier = "uuid"
		case name
		case streetname = "street_name"
		case housenumber = "house_number"
		case zipcode
	}
}

struct EventType: Codable {
	var name: String?
	var identifier: String?

	enum CodingKeys: String, CodingKey {
		case name
		case identifier = "uuid"
	}
}
