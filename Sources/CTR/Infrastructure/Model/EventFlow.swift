/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

typealias RemoteEvent = (wrapper: EventFlow.EventResultWrapper, signedResponse: SignedResponse?)

struct EventFlow {

	/// The access token used to fetch fat and thin ID Hashes
	struct AccessToken: Codable, Equatable {

		/// The provider identifier
		let providerIdentifier: String

		/// The unomi access token (thin ID Hash)
		let unomiAccessToken: String

		/// The event access token (fat ID Hash)
		let eventAccessToken: String

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case providerIdentifier = "provider_identifier"
			case eventAccessToken = "event"
			case unomiAccessToken = "unomi"
		}
	}

	enum ProviderUsage: String, Codable {

		case positiveTest = "pt"
		case negativeTest = "nt"
		case recovery = "r"
		case vaccination = "v"
	}

	// A Vaccination Event Provider (VEP)
	struct EventProvider: Codable, Equatable, CertificateProvider {

		/// The identifier of the provider
		let identifier: String

		/// The name of the provider
		let name: String

		/// The url of the provider to fetch the unomi
		let unomiURL: URL?

		/// The url of the provider to fetch the events
		let eventURL: URL?

		/// The ssl certificate of the provider
		let cmsCertificate: String

		/// The ssl certificate of the provider
		let tlsCertificate: String

		/// The access token for api calls
		var accessToken: AccessToken?

		/// Result of the unomi call
		var eventInformationAvailable: EventInformationAvailable?

		/// Where can we use this provider for?
		var usages: [ProviderUsage]

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identifier = "provider_identifier"
			case name
			case unomiURL = "unomi_url"
			case eventURL = "event_url"
			case cmsCertificate = "cms"
			case tlsCertificate = "tls"
			case usages = "usage"
		}

		func getHostNames() -> [String] {
			
			[unomiURL?.host, eventURL?.host].compactMap { $0 }
		}

		func getSSLCertificate() -> Data? {

			tlsCertificate.base64Decoded().map {
				Data($0.utf8)
			}
		}

		func getSigningCertificate() -> SigningCertificate? {

			cmsCertificate.base64Decoded().map {
				SigningCertificate(
					name: "EventProvider",
					certificate: $0,
					commonName: nil,
					authorityKeyIdentifier: nil,
					subjectKeyIdentifier: nil,
					rootSerial: nil
				)
			}
		}
	}

	/// The response of a unomi call
	struct EventInformationAvailable: Codable, Equatable {

		/// The provider identifier
		let providerIdentifier: String

		/// The protocol version
		let protocolVersion: String?

		/// The event access token
		let informationAvailable: Bool

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case providerIdentifier
			case protocolVersion
			case informationAvailable
		}
	}

	/// A wrapper around an event result.
	struct EventResultWrapper: Codable, Equatable {

		var providerIdentifier: String
		let protocolVersion: String
		let identity: Identity? // 3.0
		let status: EventState
		let result: TestResult? // 2.0
		var events: [Event]? = [] // 3.0

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identity = "holder"
			case protocolVersion
			case providerIdentifier
			case status
			case events
			case result
		}
	}

	/// The state of a test
	enum EventState: String, Codable, Equatable {

		/// The vaccination result is pending
		case pending

		/// The vaccination result is complete
		/// This refers to the data-completeness, not vaccination status.
		case complete

		/// The test is invalid
		case invalid = "invalid_token"

		/// Verification is required before we can fetch the result
		case verificationRequired = "verification_required"

		/// Unknown state
		case unknown

		/// Custom initializer to default to unknown state
		/// - Parameter decoder: the decoder
		/// - Throws: Decoding error
		init(from decoder: Decoder) throws {
			self = try EventState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
		}
	}

	struct Identity: Codable, Equatable {

		let infix: String?
		let firstName: String?
		let lastName: String?
		let birthDateString: String?

		enum CodingKeys: String, CodingKey {

			case infix
			case firstName
			case lastName
			case birthDateString = "birthDate"
		}

		var fullName: String {

			"\(infix ?? "") \(lastName ?? ""), \(firstName ?? "")".trimmingCharacters(in: .whitespaces)
		}
	}

	struct Event: Codable, Equatable {

		let type: String
		let unique: String?
		let isSpecimen: Bool?
		let vaccination: VaccinationEvent?
		let negativeTest: TestEvent?
		let positiveTest: TestEvent?
		let recovery: RecoveryEvent?
		let dccEvent: DccEvent?
		let assessment: VaccinationAssessment?

		enum CodingKeys: String, CodingKey {

			case type
			case unique
			case isSpecimen
			case vaccination
			case negativeTest = "negativetest"
			case positiveTest = "positivetest"
			case recovery
			case dccEvent
			case assessment = "vaccinationassessment"
		}

		func getSortDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if vaccination != nil {
				return vaccination?.getDate(with: dateformatter)
			}
			if negativeTest != nil {
				return negativeTest?.getDate(with: dateformatter)
			}
			if recovery != nil {
				return recovery?.getDate(with: dateformatter)
			}
			return positiveTest?.getDate(with: dateformatter)
		}
	}

	struct DccEvent: Codable, Equatable {

		let credential: String
		let couplingCode: String

		enum CodingKeys: String, CodingKey {

			case credential
			case couplingCode
		}
	}

	struct RecoveryEvent: Codable, Equatable {

		let sampleDate: String?
		let validFrom: String?
		let validUntil: String?

		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if let dateString = sampleDate {
				return  dateformatter.date(from: dateString)
			}
			return nil
		}
	}

	/// An actual vaccination event
	struct VaccinationEvent: Codable, Equatable {

		let dateString: String?
		let hpkCode: String? /// the hpk code of the vaccine (https://hpkcode.nl/) if available: type/brand can be left blank.
		let type: String?
		let manufacturer: String?
		let brand: String?
		let doseNumber: Int?
		let totalDoses: Int?
		let country: String?
		let completedByMedicalStatement: Bool?
		let completedByPersonalStatement: Bool?
		let completionReason: CompletionReason?

		enum CodingKeys: String, CodingKey {

			case dateString = "date"
			case hpkCode
			case type
			case manufacturer
			case brand
			case doseNumber
			case totalDoses
			case country
			case completedByMedicalStatement
			case completedByPersonalStatement
			case completionReason
		}
		
		enum CompletionReason: String, Codable, Equatable {
			case none = ""
			case recovery = "recovery"
			case priorEvent = "priorevent"
		}

		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if let dateString = dateString {
				return  dateformatter.date(from: dateString)
			}
			return nil
		}
	}

	struct TestEvent: Codable, Equatable {

		let sampleDateString: String?
		let negativeResult: Bool?
		let positiveResult: Bool?
		let facility: String?
		let type: String?
		let name: String?
		let manufacturer: String?

		enum CodingKeys: String, CodingKey {

			case sampleDateString = "sampleDate"
			case negativeResult
			case positiveResult
			case facility
			case type
			case name
			case manufacturer
		}

		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if let dateString = sampleDateString {
				return  dateformatter.date(from: dateString)
			}
			return nil
		}
	}
	
	struct VaccinationAssessment: Codable, Equatable {
		
		let dateString: String?
		let country: String?
		let verified: Bool
		
		enum CodingKeys: String, CodingKey {
			
			case dateString = "assessmentDate"
			case country
			case verified = "digitallyVerified"
		}
		
		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {
			
			if let dateString = dateString {
				return  dateformatter.date(from: dateString)
			}
			return nil
		}
	}

	/// This identifier is used for persiting paper proofs.
	static let paperproofIdentier = "DCC"
}

extension EventFlow.VaccinationEvent {

	func doesMatchEvent(_ otherEvent: EventFlow.VaccinationEvent) -> Bool {

		return dateString == otherEvent.dateString &&
			((hpkCode != nil && hpkCode == otherEvent.hpkCode) ||
				(manufacturer != nil && manufacturer == otherEvent.manufacturer))
	}
}
