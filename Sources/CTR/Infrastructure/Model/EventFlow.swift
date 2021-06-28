/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

typealias RemoteEvent = (wrapper: EventFlow.EventResultWrapper, signedResponse: SignedResponse)

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

		// Key mapping
		enum CodingKeys: String, CodingKey {

			case identifier = "provider_identifier"
			case name
			case unomiURL = "unomi_url"
			case eventURL = "event_url"
			case cmsCertificate = "cms"
			case tlsCertificate = "tls"
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
				SigningCertificate(name: "EventProvider", certificate: $0)
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

		/// The provider identifier
		let providerIdentifier: String

		/// The protocol version
		let protocolVersion: String

		let identity: Identity?

		/// The state of the test
		let status: EventState

		/// The test result
		let result: TestResult?

		/// The vaccination events
		var events: [Event]? = []

		func getMaxIssuedAt() -> Date? {

			let maxIssuedAt: Date? = events?
				.compactMap { $0.vaccination?.dateString }
				.compactMap(Formatter.getDateFrom)
				.reduce(nil) { (latestDateFound: Date?, nextDate: Date) -> Date? in

					switch latestDateFound {
						case let latestDateFound? where nextDate > latestDateFound:
							return nextDate
						case .none:
							return nextDate
						default:
							return latestDateFound
					}
				}

			return maxIssuedAt
		}

		func getMaxSampleDate() -> Date? {

			let maxIssuedAt: Date? = events?
				.compactMap { $0.negativeTest?.sampleDateString }
				.compactMap(Formatter.getDateFrom)
				.reduce(nil) { (latestDateFound: Date?, nextDate: Date) -> Date? in

					switch latestDateFound {
						case let latestDateFound? where nextDate > latestDateFound:
							return nextDate
						case .none:
							return nextDate
						default:
							return latestDateFound
					}
				}

			return maxIssuedAt
		}

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

		// Key mapping
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

		/// The type of event (vaccination / negativetest)
		let type: String

		/// The identifier of this event
		let unique: String?

		let isSpecimen: Bool?

		/// The vaccination
		let vaccination: VaccinationEvent?

		let negativeTest: TestEvent?

		enum CodingKeys: String, CodingKey {

			case type
			case unique
			case isSpecimen
			case vaccination
			case negativeTest = "negativetest"
		}
	}

	/// An actual vaccination event
	struct VaccinationEvent: Codable, Equatable {

		/// The date of administering the vaccine
		let dateString: String?

		/// the hpk code of the vaccine (https://hpkcode.nl/)
		/// If available: type/brand can be left blank.
		let hpkCode: String?

		/// the type of vaccine
		let type: String?

		/// The manufacturer of the vaccine
		let manufacturer: String?

		/// the brand of the vaccine
		let brand: String?

		let doseNumber: Int?

		/// optional, will be based on brand info if left out
		let totalDoses: Int?

		let country: String?

		enum CodingKeys: String, CodingKey {

			case dateString = "date"
			case hpkCode
			case type
			case manufacturer
			case brand
			case doseNumber
			case totalDoses
			case country
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

		let negativeResult: Bool

		let facility: String?

		let type: String?

		let name: String?

		let manufacturer: String?

		enum CodingKeys: String, CodingKey {

			case sampleDateString = "sampleDate"
			case negativeResult
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
}
