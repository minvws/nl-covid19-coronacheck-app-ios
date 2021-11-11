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

		func filterDomesticGreenCard(ofType: String) -> [RemoteGreenCards.Origin] {

			return domesticGreenCard?.origins
				.filter { $0.type == ofType } ?? []
		}

		func hasDomesticGreenCard(ofType: String) -> Bool {

			return !filterDomesticGreenCard(ofType: ofType).isEmpty
		}

		func filterInternationalGreenCard(ofType: String) -> [RemoteGreenCards.Origin] {

			return euGreenCards?
				.flatMap { $0.origins }
				.filter { $0.type == ofType } ?? []
		}

		func hasInternationalGreenCard(ofType: String) -> Bool {

			return !filterInternationalGreenCard(ofType: ofType).isEmpty
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
