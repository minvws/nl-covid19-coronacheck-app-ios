/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct RemoteGreenCards: Codable, Equatable {

	public struct Response: Codable, Equatable {

		public var euGreenCards: [EuGreenCard]?
		public var blobExpireDates: [BlobExpiry]?
		public var hints: [String]?
		
		enum CodingKeys: String, CodingKey {

			case euGreenCards = "euGreencards"
			case blobExpireDates
			case hints
		}
		
		public init(euGreenCards: [EuGreenCard]? = nil, blobExpireDates: [BlobExpiry]? = nil, hints: [String]? = nil) {
			self.euGreenCards = euGreenCards
			self.blobExpireDates = blobExpireDates
			self.hints = hints
		}
	}

	public struct EuGreenCard: Codable, Equatable {

		public let origins: [RemoteGreenCards.Origin]
		public let credential: String
		
		public init(origins: [RemoteGreenCards.Origin], credential: String) {
			self.origins = origins
			self.credential = credential
		}
	}

	public struct Origin: Codable, Equatable {

		public let type: String
		public let eventTime: Date
		public let expirationTime: Date
		public let validFrom: Date
		public let doseNumber: Int?
		public let hints: [String]
		
		enum CodingKeys: String, CodingKey {
			case type
			case eventTime
			case expirationTime
			case validFrom
			case doseNumber
			case hints
		}
		
		public init(type: String, eventTime: Date, expirationTime: Date, validFrom: Date, doseNumber: Int?, hints: [String]) {
			self.type = type
			self.eventTime = eventTime
			self.expirationTime = expirationTime
			self.validFrom = validFrom
			self.doseNumber = doseNumber
			self.hints = hints
		}
	}
	
	public struct BlobExpiry: Codable, Equatable {
		
		public let identifier: String
		public let expirationDate: Date
		public let reason: String?
		
		enum CodingKeys: String, CodingKey {

			case identifier = "id"
			case expirationDate = "expiry"
			case reason = "reason"
		}
		
		public init(identifier: String, expirationDate: Date, reason: String?) {
			self.identifier = identifier
			self.expirationDate = expirationDate
			self.reason = reason
		}
	}
}
