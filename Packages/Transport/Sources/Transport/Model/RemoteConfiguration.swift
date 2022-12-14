/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

public struct Mapping: Codable, Equatable {

	public let code: String
	
	public let name: String
}

public struct UniversalLinkPermittedDomain: Codable, Equatable {

	public let url: String

	public let name: String
}

public struct RemoteConfiguration: Codable, Equatable {

	/// The minimum required version
	public var minimumVersion: String

	/// The message for the minimum required version
	public var minimumVersionMessage: String?

	/// The recommended version
	public var recommendedVersion: String?

	/// The recommended version nag interval
	public var recommendedNagIntervalHours: Int?

	/// The url to the appStore
	public var appStoreURL: URL?

	/// The url to the site
	public var informationURL: URL?

	/// Is the app deactivated?
	public var appDeactivated: Bool?

	/// What is the TTL of the config
	public var configTTL: Int?

	/// Loading config should always be done opportunisically,
	/// but never more often than this value:
	public var configMinimumIntervalSeconds: Int?

	public var configAlmostOutOfDateWarningSeconds: Int?

	public var recoveryExpirationDays: Int?

	public var domesticQRRefreshSeconds: Int?
	
	public var hpkCodes: [HPKData]? = []

	public var nlTestTypes: [Mapping]? = []

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
	
	public var visitorPassEnabled: Bool?
	
	public var shouldShowCoronaMelderRecommendation: Bool?
	
	public var verificationPolicies: [String]?
	
	public var disclosurePolicies: [String]?
	
	public var backendTLSCertificates: [String]?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case minimumVersion = "iosMinimumVersion"
		case minimumVersionMessage = "iosMinimumVersionMessage"
		case recommendedVersion = "iosRecommendedVersion"
		case recommendedNagIntervalHours = "upgradeRecommendationInterval"
		case appStoreURL = "iosAppStoreURL"
		case appDeactivated = "appDeactivated"
		case informationURL = "informationURL"
		case configTTL = "configTTL"
		case configMinimumIntervalSeconds = "configMinimumIntervalSeconds"
		case configAlmostOutOfDateWarningSeconds = "configAlmostOutOfDateWarningSeconds"
		case recoveryExpirationDays = "recoveryExpirationDays"
		case hpkCodes = "hpkCodes"
		case euBrands = "euBrands"
		case nlTestTypes = "nlTestTypes"
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
		case visitorPassEnabled = "visitorPassEnabled"
		case verificationPolicies = "verificationPolicies"
		case disclosurePolicies = "disclosurePolicies"
		case backendTLSCertificates = "backendTLSCertificates"
		case providerIdentifiers = "providerIdentifiers"
	}
	
	init(minVersion: String) {

		self.minimumVersion = minVersion
	}

	/// Default remote configuration
	public static var `default`: RemoteConfiguration {

		var config = RemoteConfiguration(minVersion: "1.0.0")
		config.minimumVersionMessage = nil
		config.recommendedVersion = "1.0.0"
		config.recommendedNagIntervalHours = 24
		config.appStoreURL = nil
		config.appDeactivated = false
		config.informationURL = nil
		config.configTTL = 3600
		config.configMinimumIntervalSeconds = 300
		config.configAlmostOutOfDateWarningSeconds = 300
		config.recoveryExpirationDays = 180
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
		config.visitorPassEnabled = true
		config.verificationPolicies = ["3G"]
		config.disclosurePolicies = ["3G"]
		config.backendTLSCertificates = []
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
