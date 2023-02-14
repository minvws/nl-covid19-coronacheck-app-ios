/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public struct EuCredentialAttributes: Codable, Equatable {

	public struct DigitalCovidCertificate: Codable, Equatable {

		public let dateOfBirth: String
		public let name: Name
		public let schemaVersion: String
		public var vaccinations: [Vaccination]?
		public var tests: [TestEntry]?
		public var recoveries: [RecoveryEntry]?

		public enum CodingKeys: String, CodingKey {

			case dateOfBirth = "dob"
			case name = "nam"
			case schemaVersion = "ver"
			case vaccinations = "v"
			case tests = "t"
			case recoveries = "r"
		}
	}

	public struct Name: Codable, Equatable {

		public let familyName: String
		public let standardisedFamilyName: String
		public let givenName: String
		public let standardisedGivenName: String

		public enum CodingKeys: String, CodingKey {

			case familyName = "fn"
			case standardisedFamilyName = "fnt"
			case givenName = "gn"
			case standardisedGivenName = "gnt"
		}
	}

	public struct Vaccination: Codable, Equatable {

		public let certificateIdentifier: String
		public let country: String
		public let diseaseAgentTargeted: String
		public let doseNumber: Int?
		public let dateOfVaccination: String
		public let issuer: String
		public let marketingAuthorizationHolder: String
		public let medicalProduct: String
		public let totalDose: Int?
		public let vaccineOrProphylaxis: String

		public enum CodingKeys: String, CodingKey {

			case certificateIdentifier = "ci"
			case country = "co"
			case diseaseAgentTargeted = "tg"
			case doseNumber = "dn"
			case dateOfVaccination = "dt"
			case issuer = "is"
			case marketingAuthorizationHolder = "ma"
			case medicalProduct = "mp"
			case totalDose = "sd"
			case vaccineOrProphylaxis = "vp"
		}
	}

	public struct TestEntry: Codable, Equatable {

		public let certificateIdentifier: String
		public let country: String
		public let diseaseAgentTargeted: String
		public let issuer: String
		public let marketingAuthorizationHolder: String?
		public let name: String?
		public let sampleDate: String
		public let testResult: String
		public let testCenter: String
		public let typeOfTest: String

		public enum CodingKeys: String, CodingKey {

			case certificateIdentifier = "ci"
			case country = "co"
			case diseaseAgentTargeted = "tg"
			case issuer = "is"
			case marketingAuthorizationHolder = "ma"
			case name = "nm"
			case sampleDate = "sc"
			case testResult = "tr"
			case testCenter = "tc"
			case typeOfTest = "tt"
		}
	}

	public struct RecoveryEntry: Codable, Equatable {

		public let certificateIdentifier: String
		public let country: String
		public let diseaseAgentTargeted: String
		public let expiresAt: String
		public let firstPositiveTestDate: String
		public let issuer: String
		public let validFrom: String

		public enum CodingKeys: String, CodingKey {

			case certificateIdentifier = "ci"
			case country = "co"
			case diseaseAgentTargeted = "tg"
			case expiresAt = "du"
			case firstPositiveTestDate = "fr"
			case issuer = "is"
			case validFrom = "df"
		}
	}

	public let credentialVersion: Int
	public let digitalCovidCertificate: DigitalCovidCertificate
	public let expirationTime: TimeInterval
	public let issuedAt: TimeInterval
	public let issuer: String

	public enum CodingKeys: String, CodingKey {

		case credentialVersion
		case digitalCovidCertificate = "dcc"
		case expirationTime
		case issuedAt
		case issuer
	}

	public var eventDate: String? {

		if let vaccination = digitalCovidCertificate.vaccinations?.first {
			return vaccination.dateOfVaccination
		} else if let recovery = digitalCovidCertificate.recoveries?.first {
			return recovery.firstPositiveTestDate
		} else if let test = digitalCovidCertificate.tests?.first {
			return test.sampleDate
		}
		return nil
	}
}
