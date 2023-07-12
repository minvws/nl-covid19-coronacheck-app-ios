/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct HPKData: Codable, Equatable {
	
	public let code: String
	
	public let name: String
	
	public let displayName: String?
	
	/// euVaccinationTypes lookup
	public let vaccineOrProphylaxis: String
	
	/// euBrands lookup
	public let medicalProduct: String
	
	/// euManufacturers lookup
	public let marketingAuthorizationHolder: String
	
	public init(
		code: String,
		name: String,
		displayName: String? = nil,
		vaccineOrProphylaxis: String,
		medicalProduct: String,
		marketingAuthorizationHolder: String) {
			self.code = code
			self.name = name
			self.displayName = displayName
			self.vaccineOrProphylaxis = vaccineOrProphylaxis
			self.medicalProduct = medicalProduct
			self.marketingAuthorizationHolder = marketingAuthorizationHolder
		}
	
	/// Key mapping
	enum CodingKeys: String, CodingKey {
		
		case code
		case name
		case displayName
		case vaccineOrProphylaxis = "vp"
		case medicalProduct = "mp"
		case marketingAuthorizationHolder = "ma"
	}
}

public struct ContactInformation: Codable, Equatable {
	
	public let phoneNumber: String?
	public let phoneNumberAbroad: String?
	public let startDay: Int?
	public let startHour: String?
	public let endDay: Int?
	public let endHour: String?
	
	public init(
		phoneNumber: String? = nil,
		phoneNumberAbroad: String? = nil,
		startDay: Int? = nil,
		startHour: String? = nil,
		endDay: Int? = nil,
		endHour: String? = nil) {
		self.phoneNumber = phoneNumber
		self.phoneNumberAbroad = phoneNumberAbroad
		self.startDay = startDay
		self.startHour = startHour
		self.endDay = endDay
		self.endHour = endHour
	}
	
	/// Key mapping
	enum CodingKeys: String, CodingKey {
		
		case phoneNumber
		case phoneNumberAbroad
		case startDay
		case startHour
		case endDay
		case endHour
	}
}

public struct Mapping: Codable, Equatable {
	
	public let code: String
	
	public let name: String
	
	public init(code: String, name: String) {
		self.code = code
		self.name = name
	}
}

public struct UniversalLinkPermittedDomain: Codable, Equatable {
	
	public let url: String
	
	public let name: String
	
	public init(url: String, name: String) {
		self.url = url
		self.name = name
	}
}

public struct RemoteConfiguration: Codable, Equatable {

	/// The minimum required version
	public var minimumVersion: String

	/// The recommended version
	public var recommendedVersion: String?

	/// The recommended version nag interval
	public var recommendedNagIntervalHours: Int?

	/// The url to the appStore
	public var appStoreURL: URL?

	/// Is the app deactivated?
	public var appDeactivated: Bool?

	/// What is the TTL of the config
	public var configTTL: Int?

	/// Loading config should always be done opportunisically,
	/// but never more often than this value:
	public var configMinimumIntervalSeconds: Int?

	public var configAlmostOutOfDateWarningSeconds: Int?

	public var domesticQRRefreshSeconds: Int?
	
	public var hpkCodes: [HPKData]? = []

	public var euBrands: [Mapping]? = []

	public var euManufacturers: [Mapping]?

	public var euVaccinationTypes: [Mapping]?

	public var euTestTypes: [Mapping]? = []

	public var euTestNames: [Mapping]? = []

	public var euTestManufacturers: [Mapping]? = []
	
	public var providerIdentifiers: [Mapping]? = []

	/// Restricts access to GGD test provider login
	public var isGGDEnabled: Bool?
	
	/// Restricts access to PAP provider login
	public var isPAPEnabled: Bool?

	public var credentialRenewalDays: Int?

	public var universalLinkPermittedDomains: [UniversalLinkPermittedDomain]?

	public var clockDeviationThresholdSeconds: Int?
	
	/// Enables luhn check for token validation
	public var isLuhnCheckEnabled: Bool?

	/// The minimum number of seconds between switching risk level
	public var scanLockSeconds: Int?

	/// The number of seconds we show a warning before switching risk level
	public var scanLockWarningSeconds: Int?

	/// The number of seconds to keep scan entries in the log
	public var scanLogStorageSeconds: Int?
	
	public var shouldShowCoronaMelderRecommendation: Bool?
	
	public var verificationPolicies: [String]?
	
	public var backendTLSCertificates: [String]?
	
	public var contactInformation: ContactInformation?
	
	public var priorityNotification: String?
	
	public var migrateButtonEnabled: Bool?
	
	public var addEventsButtonEnabled: Bool?
	
	public var scanCertificateButtonEnabled: Bool?
	
	public var archiveOnlyDate: Date?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case minimumVersion = "iosMinimumVersion"
		case recommendedVersion = "iosRecommendedVersion"
		case recommendedNagIntervalHours = "upgradeRecommendationInterval"
		case appStoreURL = "iosAppStoreURL"
		case appDeactivated = "appDeactivated"
		case configTTL = "configTTL"
		case configMinimumIntervalSeconds = "configMinimumIntervalSeconds"
		case configAlmostOutOfDateWarningSeconds = "configAlmostOutOfDateWarningSeconds"
		case hpkCodes = "hpkCodes"
		case euBrands = "euBrands"
		case euManufacturers = "euManufacturers"
		case euVaccinationTypes = "euVaccinations"
		case euTestTypes = "euTestTypes"
		case euTestNames = "euTestNames"
		case euTestManufacturers = "euTestManufacturers"
		case isGGDEnabled = "ggdEnabled"
		case isPAPEnabled = "papEnabled"
		case credentialRenewalDays = "credentialRenewalDays"
		case domesticQRRefreshSeconds = "domesticQRRefreshSeconds"
		case universalLinkPermittedDomains = "universalLinkDomains"
		case clockDeviationThresholdSeconds = "clockDeviationThresholdSeconds"
		case isLuhnCheckEnabled = "luhnCheckEnabled"
		case scanLockSeconds = "scanLockSeconds"
		case scanLockWarningSeconds = "scanLockWarningSeconds"
		case scanLogStorageSeconds = "scanLogStorageSeconds"
		case verificationPolicies = "verificationPolicies"
		case backendTLSCertificates = "backendTLSCertificates"
		case providerIdentifiers = "providerIdentifiers"
		case contactInformation = "contactInformation"
		case priorityNotification = "priorityNotification"
		case addEventsButtonEnabled = "addEventsButtonEnabled"
		case migrateButtonEnabled = "migrateButtonEnabled"
		case scanCertificateButtonEnabled = "scanCertificateButtonEnabled"
		case archiveOnlyDate = "archiveOnlyDate"
	}
	
	init(minVersion: String) {

		self.minimumVersion = minVersion
	}

	/// Default remote configuration
	public static var `default`: RemoteConfiguration {

		var config = RemoteConfiguration(minVersion: "1.0.0")
		config.recommendedVersion = "1.0.0"
		config.recommendedNagIntervalHours = 24
		config.appStoreURL = nil
		config.appDeactivated = false
		config.configTTL = 3600
		config.configMinimumIntervalSeconds = 300
		config.configAlmostOutOfDateWarningSeconds = 300
		config.isGGDEnabled = true
		config.isPAPEnabled = true
		config.credentialRenewalDays = 5
		config.domesticQRRefreshSeconds = 60
		config.universalLinkPermittedDomains = nil
		config.clockDeviationThresholdSeconds = 30
		config.isLuhnCheckEnabled = true
		config.scanLockSeconds = 300
		config.scanLockWarningSeconds = 3600
		config.scanLogStorageSeconds = 3600
		config.verificationPolicies = ["3G"]
		config.backendTLSCertificates = []
		config.priorityNotification = nil
		return config
	}

	/// Is the app deactivated?
	public var isDeactivated: Bool {

		return appDeactivated ?? false
	}
	
	public func getTLSCertificates() -> [Data] {
		
		var result = [Data]()
		backendTLSCertificates?.forEach { tlsCertificate in
			if let decoded = tlsCertificate.base64Decoded() {
				result.append(Data(decoded.utf8))
			}
		}
		return result
	}
}
