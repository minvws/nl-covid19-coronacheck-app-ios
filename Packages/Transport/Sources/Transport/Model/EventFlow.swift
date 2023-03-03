/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

public struct EventFlow {

	/// The access token used to fetch fat and thin ID Hashes
	public struct AccessToken: Codable, Equatable {
		public init(providerIdentifier: String, unomiAccessToken: String, eventAccessToken: String) {
			self.providerIdentifier = providerIdentifier
			self.unomiAccessToken = unomiAccessToken
			self.eventAccessToken = eventAccessToken
		}

		/// The provider identifier
		public let providerIdentifier: String

		/// The unomi access token (thin ID Hash)
		public let unomiAccessToken: String

		/// The event access token (fat ID Hash)
		public let eventAccessToken: String

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case providerIdentifier = "provider_identifier"
			case eventAccessToken = "event"
			case unomiAccessToken = "unomi"
		}
	}

	public enum ProviderUsage: String, Codable {

		case positiveTest = "pt"
		case negativeTest = "nt"
		case recovery = "r"
		case vaccination = "v"
		case none = ""
		
		/// Custom initializer to default to unknown state
		/// - Parameter decoder: the decoder
		/// - Throws: Decoding error
		public init(from decoder: Decoder) throws {
			self = try ProviderUsage(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
		}
	}
	
	/// The type of token a provider can handle
	public enum ProviderAuthenticationType: String, Codable {
		case manyAuthenticationExchange = "max"
		case patientAuthenticationProvider = "pap"
	}

	// A Vaccination Event Provider (VEP)
	public struct EventProvider: Codable, Equatable, CertificateProvider {
		public init(identifier: String, name: String, unomiUrl: URL?, eventUrl: URL?, cmsCertificates: [String], tlsCertificates: [String], accessToken: EventFlow.AccessToken? = nil, eventInformationAvailable: EventFlow.EventInformationAvailable? = nil, usages: [EventFlow.ProviderUsage], providerAuthentication: [EventFlow.ProviderAuthenticationType], queryFilter: [String: String?] = [:]) {
			self.identifier = identifier
			self.name = name
			self.unomiUrl = unomiUrl
			self.eventUrl = eventUrl
			self.cmsCertificates = cmsCertificates
			self.tlsCertificates = tlsCertificates
			self.accessToken = accessToken
			self.eventInformationAvailable = eventInformationAvailable
			self.usages = usages
			self.providerAuthentication = providerAuthentication
			self.queryFilter = queryFilter
		}

		/// The identifier of the provider
		public let identifier: String

		/// The name of the provider
		public let name: String

		/// The url of the provider to fetch the unomi
		public let unomiUrl: URL?

		/// The url of the provider to fetch the events
		public let eventUrl: URL?

		/// The public key of the provider
		public var cmsCertificates: [String]
		
		/// The ssl certificate of the provider
		public var tlsCertificates: [String]

		/// The access token for api calls
		public var accessToken: AccessToken?

		/// Result of the unomi call
		public var eventInformationAvailable: EventInformationAvailable?

		/// Where can we use this provider for?
		public var usages: [ProviderUsage]
		
		/// The type of tokens the provider can handle
		public var providerAuthentication: [ProviderAuthenticationType]

		/// The query filter to pass along to the provider
		public var queryFilter: [String: String?] = [:]

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identifier
			case name
			case unomiUrl
			case eventUrl
			case cmsCertificates = "cms"
			case tlsCertificates = "tls"
			case usages = "usage"
			case providerAuthentication = "auth"
		}
	}

	/// The response of a unomi call
	public struct EventInformationAvailable: Codable, Equatable {
		public init(providerIdentifier: String, protocolVersion: String?, informationAvailable: Bool) {
			self.providerIdentifier = providerIdentifier
			self.protocolVersion = protocolVersion
			self.informationAvailable = informationAvailable
		}
		
		/// The provider identifier
		public let providerIdentifier: String

		/// The protocol version
		public let protocolVersion: String?

		/// The event access token
		public let informationAvailable: Bool

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case providerIdentifier
			case protocolVersion
			case informationAvailable
		}
	}

	/// A wrapper around an event result.
	public struct EventResultWrapper: Codable, Equatable {
		public init(providerIdentifier: String, protocolVersion: String, identity: EventFlow.Identity?, status: EventFlow.EventState, events: [EventFlow.Event]? = []) {
			self.providerIdentifier = providerIdentifier
			self.protocolVersion = protocolVersion
			self.identity = identity
			self.status = status
			self.events = events
		}

		public var providerIdentifier: String
		public let protocolVersion: String
		public let identity: Identity?
		public let status: EventState
		public var events: [Event]? = []

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identity = "holder"
			case protocolVersion
			case providerIdentifier
			case status
			case events
		}
		
		public var isGGD: Bool {
			return providerIdentifier.lowercased() == "ggd"
		}
		
		public var isRIVM: Bool {
			return providerIdentifier.lowercased() == "rvv"
		}
		
		public var isZKVI: Bool {
			return providerIdentifier.lowercased() == "zkv"
		}
	}

	/// The state of a test
	public enum EventState: String, Codable, Equatable {

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
		
		/// Blocked (too many tries)
		case blocked = "result_blocked"

		/// Custom initializer to default to unknown state
		/// - Parameter decoder: the decoder
		/// - Throws: Decoding error
		public init(from decoder: Decoder) throws {
			self = try EventState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
		}
	}

	public struct Identity: Codable, Equatable {
		public init(infix: String?, firstName: String?, lastName: String?, birthDateString: String?) {
			self.infix = infix
			self.firstName = firstName
			self.lastName = lastName
			self.birthDateString = birthDateString
		}

		public let infix: String?
		public let firstName: String?
		public let lastName: String?
		public let birthDateString: String?

		public enum CodingKeys: String, CodingKey {
			case infix
			case firstName
			case lastName
			case birthDateString = "birthDate"
		}

		public var fullName: String {

			"\(infix ?? "") \(lastName ?? ""), \(firstName ?? "")".trimmingCharacters(in: .whitespaces)
		}
	}

	public struct Event: Codable, Equatable {
		public init(type: String, unique: String?, isSpecimen: Bool?, vaccination: EventFlow.VaccinationEvent?, negativeTest: EventFlow.TestEvent?, positiveTest: EventFlow.TestEvent?, recovery: EventFlow.RecoveryEvent?, dccEvent: EventFlow.DccEvent?, vaccinationAssessment: EventFlow.VaccinationAssessment?) {
			self.type = type
			self.unique = unique
			self.isSpecimen = isSpecimen
			self.vaccination = vaccination
			self.negativeTest = negativeTest
			self.positiveTest = positiveTest
			self.recovery = recovery
			self.dccEvent = dccEvent
			self.vaccinationAssessment = vaccinationAssessment
		}
		
		public let type: String
		public let unique: String?
		public let isSpecimen: Bool?
		public let vaccination: VaccinationEvent?
		public let negativeTest: TestEvent?
		public let positiveTest: TestEvent?
		public let recovery: RecoveryEvent?
		public let dccEvent: DccEvent?
		public let vaccinationAssessment: VaccinationAssessment?

		public enum CodingKeys: String, CodingKey {

			case type
			case unique
			case isSpecimen
			case vaccination
			case negativeTest = "negativetest"
			case positiveTest = "positivetest"
			case recovery
			case dccEvent
			case vaccinationAssessment = "vaccinationassessment"
		}
	}

	public struct DccEvent: Codable, Equatable {
		public init(credential: String, couplingCode: String?) {
			self.credential = credential
			self.couplingCode = couplingCode
		}
		
		public let credential: String
		public let couplingCode: String?

		public enum CodingKeys: String, CodingKey {

			case credential
			case couplingCode
		}
	}

	public struct RecoveryEvent: Codable, Equatable {

		public let sampleDate: String?
		public let validFrom: String?
		public let validUntil: String?

		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		public func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if let sampleDate {
				return dateformatter.date(from: sampleDate)
			}
			return nil
		}
		
		public init(sampleDate: String?, validFrom: String?, validUntil: String?) {
			self.sampleDate = sampleDate
			self.validFrom = validFrom
			self.validUntil = validUntil
		}
	}

	/// An actual vaccination event
	public struct VaccinationEvent: Codable, Equatable {

		public let dateString: String?
		public let hpkCode: String? /// the hpk code of the vaccine (https://hpkcode.nl/) if available: type/brand can be left blank.
		public let type: String?
		public let manufacturer: String?
		public let brand: String?
		public let doseNumber: Int?
		public let totalDoses: Int?
		public let country: String?
		public let completedByMedicalStatement: Bool?
		public let completedByPersonalStatement: Bool?
		public let completionReason: CompletionReason?

		public enum CodingKeys: String, CodingKey {

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
		
		public enum CompletionReason: String, Codable, Equatable {
			case none = ""
			case recovery = "recovery"
			case firstVaccinationElsewhere = "first-vaccination-elsewhere"
			
			/// Custom initializer to default to none state
			/// - Parameter decoder: the decoder
			/// - Throws: Decoding error
			public init(from decoder: Decoder) throws {
				self = try CompletionReason(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
			}
		}

		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if let dateString {
				return dateformatter.date(from: dateString)
			}
			return nil
		}
		
		public init(dateString: String?, hpkCode: String?, type: String?, manufacturer: String?, brand: String?, doseNumber: Int?, totalDoses: Int?, country: String?, completedByMedicalStatement: Bool?, completedByPersonalStatement: Bool?, completionReason: CompletionReason?) {
			self.dateString = dateString
			self.hpkCode = hpkCode
			self.type = type
			self.manufacturer = manufacturer
			self.brand = brand
			self.doseNumber = doseNumber
			self.totalDoses = totalDoses
			self.country = country
			self.completedByMedicalStatement = completedByMedicalStatement
			self.completedByPersonalStatement = completedByPersonalStatement
			self.completionReason = completionReason
		}
	}

	public struct TestEvent: Codable, Equatable {

		public let sampleDateString: String?
		public let negativeResult: Bool?
		public let positiveResult: Bool?
		public let facility: String?
		public let type: String?
		public let name: String?
		public let manufacturer: String?
		public let country: String?

		public enum CodingKeys: String, CodingKey {

			case sampleDateString = "sampleDate"
			case negativeResult
			case positiveResult
			case facility
			case type
			case name
			case manufacturer
			case country
		}

		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		public func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {

			if let sampleDateString {
				return dateformatter.date(from: sampleDateString)
			}
			return nil
		}
		
		public init(sampleDateString: String?, negativeResult: Bool?, positiveResult: Bool?, facility: String?, type: String?, name: String?, manufacturer: String?, country: String?) {
			self.sampleDateString = sampleDateString
			self.negativeResult = negativeResult
			self.positiveResult = positiveResult
			self.facility = facility
			self.type = type
			self.name = name
			self.manufacturer = manufacturer
			self.country = country
		}
	}
	
	public struct VaccinationAssessment: Codable, Equatable {
		
		public let dateTimeString: String?
		public let country: String?
		public let verified: Bool
		
		public enum CodingKeys: String, CodingKey {
			
			case dateTimeString = "assessmentDate"
			case country
			case verified = "digitallyVerified"
		}
		
		/// Get the date for this event
		/// - Parameter dateformatter: the date formatter
		/// - Returns: optional date
		public func getDate(with dateformatter: ISO8601DateFormatter) -> Date? {
			
			if let dateTimeString {
				return dateformatter.date(from: dateTimeString)
			}
			return nil
		}
		
		public init(dateTimeString: String?, country: String?, verified: Bool) {
			self.dateTimeString = dateTimeString
			self.country = country
			self.verified = verified
		}
	}

	/// This identifier is used for persiting paper proofs.
	public static let paperproofIdentier = "DCC"
}

public extension EventFlow.VaccinationEvent {

	func doesMatchEvent(_ otherEvent: EventFlow.VaccinationEvent) -> Bool {

		return dateString == otherEvent.dateString &&
			((hpkCode != nil && hpkCode == otherEvent.hpkCode) ||
				(manufacturer != nil && manufacturer == otherEvent.manufacturer))
	}
}

extension EventFlow.Event {

	public func getSortDate(with dateformatter: ISO8601DateFormatter) -> Date? {

		if hasVaccination {
			return vaccination?.getDate(with: dateformatter)
		}
		if hasNegativeTest {
			return negativeTest?.getDate(with: dateformatter)
		}
		if hasRecovery {
			return recovery?.getDate(with: dateformatter)
		}
		if hasVaccinationAssessment {
			return vaccinationAssessment?.getDate(with: dateformatter)
		}
		return positiveTest?.getDate(with: dateformatter)
	}

	public var hasVaccination: Bool {
		return vaccination != nil
	}

	public var hasNegativeTest: Bool {
		return negativeTest != nil
	}

	public var hasPositiveTest: Bool {
		return positiveTest != nil
	}

	public var hasRecovery: Bool {
		return recovery != nil
	}

	public var hasVaccinationAssessment: Bool {
		return vaccinationAssessment != nil
	}

	public var hasPaperCertificate: Bool {
		return dccEvent != nil
	}
}
