/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct DomesticCredentialAttributes: Codable {

	let birthDay: String
	let birthMonth: String
	let firstNameInitial: String
	let lastNameInitial: String
	let credentialVersion: String
	let specimen: String
	let paperProof: String
	let validFrom: String
	let validForHours: String

	enum CodingKeys: String, CodingKey {

		case birthDay
		case birthMonth
		case firstNameInitial
		case lastNameInitial
		case credentialVersion
		case specimen = "isSpecimen"
		case paperProof = "stripType"
		case validFrom
		case validForHours
	}

	var isPaperProof: Bool {

		return paperProof == "1"
	}

	var isSpecimen: Bool {

		return specimen == "1"
	}

	/// Map the identity of the holder
	/// - Parameter months: the months
	/// - Returns: mapped identify
	func mapIdentity(months: [String]) -> [String] {

		var output: [String] = []
		output.append(firstNameInitial)
		output.append(lastNameInitial)
		if let value = Int(birthDay), value > 0 {
			let formatter = NumberFormatter()
			formatter.minimumIntegerDigits = 2
			if let day = formatter.string(from: NSNumber(value: value)) {
				output.append(day)
			}
		} else {
			output.append(birthDay)
		}

		if let value = Int(birthMonth), value <= months.count, value > 0 {
			output.append(months[value - 1])
		} else {
			output.append(birthMonth)
		}

		return output
	}
}

struct DomesticCredential: Codable {

	let credential: Data?
	let attributes: DomesticCredentialAttributes

	enum CodingKeys: String, CodingKey {

		case credential
		case attributes
	}

	init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		attributes = try container.decode(DomesticCredentialAttributes.self, forKey: .attributes)
		let structure = try container.decode(AnyCodable.self, forKey: .credential)
		let jsonEncoder = JSONEncoder()

		if let data = try? jsonEncoder.encode(structure),
		   let str = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/") {
			credential = Data(str.utf8)
		} else {
			credential = nil
		}
	}
}
