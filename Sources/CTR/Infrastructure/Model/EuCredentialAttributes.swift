/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct EuCredentialAttributes: Codable {

	struct DigitalCovidCertificate: Codable {

		let dateOfBirth: String
		let name: Name
		let schemaVersion: String
		var vaccinations: [Vaccination]?
		var tests: [TestEntry]?
		var recoveries: [RecoveryEntry]?

		enum CodingKeys: String, CodingKey {

			case dateOfBirth = "dob"
			case name = "nam"
			case schemaVersion = "ver"
			case vaccinations = "v"
			case tests = "t"
			case recoveries = "r"
		}
	}

	struct Name: Codable {

		let familyName: String
		let standardisedFamilyName: String
		let givenName: String
		let standardisedGivenName: String

		enum CodingKeys: String, CodingKey {

			case familyName = "fn"
			case standardisedFamilyName = "fnt"
			case givenName = "gn"
			case standardisedGivenName = "gnt"
		}
	}

	struct Vaccination: Codable {

		let certificateIdentifier: String
		let country: String
		let diseaseAgentTargeted: String
		let doseNumber: Int
		let dateOfVaccination: String
		let issuer: String
		let marketingAuthorizationHolder: String
		let medicalProduct: String
		let totalDose: Int
		let vaccineOrProphylaxis: String

		enum CodingKeys: String, CodingKey {

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

	struct TestEntry: Codable {

		let certificateIdentifier: String
		let country: String
		let diseaseAgentTargeted: String
		let issuer: String
		let sampleDate: String
		let testResult: String
		let testCenter: String
		let typeOfTest: String

		enum CodingKeys: String, CodingKey {

			case certificateIdentifier = "ci"
			case country = "co"
			case diseaseAgentTargeted = "tg"
			case issuer = "is"
			case sampleDate = "sc"
			case testResult = "tr"
			case testCenter = "tc"
			case typeOfTest = "tt"
		}
	}

	struct RecoveryEntry: Codable {

		let certificateIdentifier: String
		let country: String
		let diseaseAgentTargeted: String
		let expiresAt: String
		let firstPositiveTestDate: String
		let issuer: String
		let validFrom: String

		enum CodingKeys: String, CodingKey {

			case certificateIdentifier = "ci"
			case country = "co"
			case diseaseAgentTargeted = "tg"
			case expiresAt = "du"
			case firstPositiveTestDate = "fr"
			case issuer = "is"
			case validFrom = "df"
		}
	}

	let credentialVersion: Int
	let digitalCovidCertificate: DigitalCovidCertificate
	let expirationTime: TimeInterval
	let issuedAt: TimeInterval
	let issuer: String

	enum CodingKeys: String, CodingKey {

		case credentialVersion
		case digitalCovidCertificate = "dcc"
		case expirationTime
		case issuedAt
		case issuer
	}
}
