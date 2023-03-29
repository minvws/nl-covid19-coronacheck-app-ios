/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct DomesticCredentialAttributes: Codable {

	public let birthDay: String
	public let birthMonth: String
	public let firstNameInitial: String
	public let lastNameInitial: String
	public let credentialVersion: String
	public let category: String?
	public let specimen: String
	public let paperProof: String
	public let validFrom: String
	public let validForHours: String

	public enum CodingKeys: String, CodingKey {

		case birthDay
		case birthMonth
		case firstNameInitial
		case lastNameInitial
		case credentialVersion
		case category
		case specimen = "isSpecimen"
		case paperProof = "isPaperProof"
		case validFrom
		case validForHours
	}

	public var isPaperProof: Bool {

		return paperProof == "1"
	}

	public var isSpecimen: Bool {

		return specimen == "1"
	}

	/// Map the identity of the holder
	/// - Parameter months: the months
	/// - Returns: mapped identify
	public func mapIdentity(months: [String]) -> [String] {

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

public struct DomesticCredential: Codable {
	
	public struct DomesticCredentialContainer: Codable {
		
		public let attributes: [String?]
		public let signature: DomesticSignature
		
		enum CodingKeys: String, CodingKey {
			
			case attributes
			case signature
		}
	}
	
	public struct DomesticSignature: Codable {
		
		public let aPart: String
		public let ePart: String
		public let keyShareP: String?
		public let vPart: String
		
		public enum CodingKeys: String, CodingKey {
			
			case aPart = "A"
			case ePart = "e"
			case keyShareP
			case vPart = "v"
		}
	}

	public let credential: Data?
	public let attributes: DomesticCredentialAttributes

	public enum CodingKeys: String, CodingKey {

		case credential
		case attributes
	}

	public init(credential: Data?, attributes: DomesticCredentialAttributes) {
		self.credential = credential
		self.attributes = attributes
	}

	public init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		attributes = try container.decode(DomesticCredentialAttributes.self, forKey: .attributes)
		let structure = try container.decode(DomesticCredentialContainer.self, forKey: .credential)
		let jsonEncoder = JSONEncoder()

		if let data = try? jsonEncoder.encode(structure),
		   let str = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/") {
			credential = Data(str.utf8)
		} else {
			credential = nil
		}
	}
}