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
		let hints: [String]
		
		enum CodingKeys: String, CodingKey {

			case type
			case eventTime
			case expirationTime
			case validFrom
			case doseNumber
			case hints
		}
	}
	
	struct BlobExpiry: Codable, Equatable, Hashable {
		
		let identifier: String
		let expirationDate: Date
		let reason: String
		
		enum CodingKeys: String, CodingKey {

			case identifier = "id"
			case expirationDate = "expiry"
			case reason = "reason"
		}
	}
}

extension Array where Element == RemoteGreenCards.BlobExpiry {
	
	/// Determine which BlobExpiry elements ("blockItems") match EventGroups which were sent to be signed:
	func combinedWith(matchingEventGroups eventGroups: [EventGroup]) -> [(RemoteGreenCards.BlobExpiry, EventGroup)] {
		reduce([]) { partialResult, blockItem in
			guard let matchingEvent = eventGroups.first(where: { "\($0.uniqueIdentifier)" == blockItem.identifier }) else { return partialResult }
			return partialResult + [(blockItem, matchingEvent)]
		}
	}
}
