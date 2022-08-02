/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct RemoteGreenCards: Codable, Equatable {

	struct Response: Codable, Equatable {

		var domesticGreenCard: DomesticGreenCard?
		var euGreenCards: [EuGreenCard]?
		var blobExpireDates: [BlobExpiry]?
		var hints: [String]?
		
		enum CodingKeys: String, CodingKey {

			case domesticGreenCard = "domesticGreencard"
			case euGreenCards = "euGreencards"
			case blobExpireDates
			case hints
		}
	}

	struct DomesticGreenCard: Codable, Equatable {

		let origins: [RemoteGreenCards.Origin]
		let createCredentialMessages: String?
	}

	struct EuGreenCard: Codable, Equatable {

		let origins: [RemoteGreenCards.Origin]
		let credential: String
	}

	struct Origin: Codable, Equatable {

		let type: String
		let eventTime: Date
		let expirationTime: Date
		let validFrom: Date
		let doseNumber: Int?
	}
	
	struct BlobExpiry: Codable, Equatable {
		
		let identifier: String
		let expirationDate: Date
		
		enum CodingKeys: String, CodingKey {

			case identifier = "id"
			case expirationDate = "expiry"
		}
	}
}
