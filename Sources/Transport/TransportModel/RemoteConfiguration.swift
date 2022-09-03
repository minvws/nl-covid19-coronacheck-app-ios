/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct HPKData: Codable, Equatable {
	
	let code: String
	
	let name: String
	
	/// euVaccinationTypes lookup
	let vp: String
	
	/// euBrands lookup
	let mp: String
	
	/// euManufacturers lookup
	let ma: String
}

struct Mapping: Codable, Equatable {

	let code: String
	
	let name: String
}

struct UniversalLinkPermittedDomain: Codable, Equatable {

	let url: String

	let name: String
}

struct RemoteConfiguration: Codable, Equatable {

	/// The minimum required version
	var minimumVersion: String

	/// The message for the minimum required version
	var minimumVersionMessage: String?

	/// The recommended version
	var recommendedVersion: String?

	/// The recommended version nag interval
	var recommendedNagIntervalHours: Int?

	/// The url to the appStore
	var appStoreURL: URL?

	/// The url to the site
	var informationURL: URL?

	/// Is the app deactivated?
	var appDeactivated: Bool?

	/// What is the TTL of the config
	var configTTL: Int?

	/// Loading config should always be done opportunisically,
	/// but never more often than this value:
	var configMinimumIntervalSeconds: Int?

	var configAlmostOutOfDateWarningSeconds: Int?

	var recoveryExpirationDays: Int?

	var domesticQRRefreshSeconds: Int?
	
	var hpkCodes: [HPKData]? = []

	var nlTestTypes: [Mapping]? = []

	var euBrands: [Mapping]? = []

	var euManufacturers: [Mapping]?

	var euVaccinationTypes: [Mapping]?

	var euTestTypes: [Mapping]? = []

	var euTestNames: [Mapping]? = []

	var euTestManufacturers: [Mapping]? = []
	
	var providerIdentifiers: [Mapping]? = []

	/// Restricts access to GGD test provider login
	var isGGDEnabled: Bool?
	
	/// Restricts access to PAP provider login
	var isPAPEnabled: Bool?

	var credentialRenewalDays: Int?

	var universalLinkPermittedDomains: [UniversalLinkPermittedDomain]?

	var clockDeviationThresholdSeconds: Int?
	
	/// Enables luhn check for token validation
	var isLuhnCheckEnabled: Bool?

	/// The minimum number of seconds between switching risk level
	var scanLockSeconds: Int?

	/// The number of seconds we show a warning before switching risk level
	var scanLockWarningSeconds: Int?

	/// The number of seconds to keep scan entries in the log
	var scanLogStorageSeconds: Int?
	
	var visitorPassEnabled: Bool?
	
	var shouldShowCoronaMelderRecommendation: Bool?
	
	var verificationPolicies: [String]?
	
	var disclosurePolicies: [String]?
	
	var backendTLSCertificates: [String]?

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
		case shouldShowCoronaMelderRecommendation = "shouldShowCoronaMelderRecommendation"
		case verificationPolicies = "verificationPolicies"
		case disclosurePolicies = "disclosurePolicies"
		case backendTLSCertificates = "backendTLSCertificates"
		case providerIdentifiers = "providerIdentifiers"
	}
	
	init(minVersion: String) {

		self.minimumVersion = minVersion
	}

	/// Default remote configuration
	static var `default`: RemoteConfiguration {

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
		config.shouldShowCoronaMelderRecommendation = false
		config.verificationPolicies = ["3G"]
		config.disclosurePolicies = ["3G"]
		config.backendTLSCertificates = []
		return config
	}

	/// Is the app deactivated?
	var isDeactivated: Bool {

		return appDeactivated ?? false
	}
	
	func getTLSCertificates() -> [Data] {
		
		var result = [Data]()
		backendTLSCertificates?.forEach { tlsCertificate in
			if let decoded = tlsCertificate.base64Decoded() {
				result.append(Data(decoded.utf8))
			}
		}
		return result
	}
}
