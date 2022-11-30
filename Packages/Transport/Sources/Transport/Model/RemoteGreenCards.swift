/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct RemoteGreenCards: Codable, Equatable {

	public struct Response: Codable, Equatable {

		public var domesticGreenCard: DomesticGreenCard?
		public var euGreenCards: [EuGreenCard]?
		public var blobExpireDates: [BlobExpiry]?
		public var hints: [String]?
		
		enum CodingKeys: String, CodingKey {

			case domesticGreenCard = "domesticGreencard"
			case euGreenCards = "euGreencards"
			case blobExpireDates
			case hints
		}
	}

	public struct DomesticGreenCard: Codable, Equatable {

		public let origins: [RemoteGreenCards.Origin]
		public let createCredentialMessages: String?
	}

	public struct EuGreenCard: Codable, Equatable {

		public let origins: [RemoteGreenCards.Origin]
		public let credential: String
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
	}
}
