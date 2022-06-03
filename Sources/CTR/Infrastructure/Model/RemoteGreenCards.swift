/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct RemoteGreenCards: Codable {

	struct Response: Codable {

		let domesticGreenCard: DomesticGreenCard?
		let euGreenCards: [EuGreenCard]?
		let blobExpiries: [BlobExpiry]?

		enum CodingKeys: String, CodingKey {

			case domesticGreenCard = "domesticGreencard"
			case euGreenCards = "euGreencards"
			case blobExpiries
		}

		func getOrigins(ofType: String) -> [RemoteGreenCards.Origin] {
		
			return getDomesticOrigins(ofType: ofType) + getInternationalOrigins(ofType: ofType)
		}
		
		func getDomesticOrigins(ofType: String) -> [RemoteGreenCards.Origin] {

			return domesticGreenCard?.origins
				.filter { $0.type == ofType } ?? []
		}

		func hasDomesticOrigins(ofType: String) -> Bool {

			return !getDomesticOrigins(ofType: ofType).isEmpty
		}

		func getInternationalOrigins(ofType: String) -> [RemoteGreenCards.Origin] {

			return euGreenCards?
				.flatMap { $0.origins }
				.filter { $0.type == ofType } ?? []
		}

		func hasInternationalOrigins(ofType: String) -> Bool {

			return !getInternationalOrigins(ofType: ofType).isEmpty
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
		let doseNumber: Int?
	}
	
	struct BlobExpiry: Codable {
		
		let identifier: String
		let expirationDate: Date
		
		enum CodingKeys: String, CodingKey {

			case identifier = "id"
			case expirationDate = "expiry"
		}
	}
}
