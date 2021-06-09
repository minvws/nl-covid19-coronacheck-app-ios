/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct RemoteGreenCards: Codable {

	struct Response: Codable {

		let domesticGreenCard: DomesticGreenCard?
		let euGreenCards: [EuGreenCard]?

		enum CodingKeys: String, CodingKey {

			case domesticGreenCard = "domesticGreencard"
			case euGreenCards = "euGreencards"
		}
	}

	struct DomesticGreenCard: Codable {

		let origins: [RemoteGreenCards.Origin]
		let createCredentialMessages: String?
	}

	struct EuGreenCard: Codable {

		let origins: [RemoteGreenCards.Origin]
		let credential: String
	}

	struct Origin: Codable {

		let type: String
		let eventTime: Date
		let expirationTime: Date
		let validFrom: Date
	}
}
