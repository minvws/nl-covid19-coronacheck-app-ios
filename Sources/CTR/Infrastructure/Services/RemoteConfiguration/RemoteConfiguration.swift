/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct HPKData: Codable {
	
	let code: String
	
	let name: String
	
	/// euVaccinationTypes lookup
	let vp: String
	
	/// euBrands lookup
	let mp: String
	
	/// euManufacturers lookup
	let ma: String
}

struct Mapping: Codable {

	let code: String
	
	let name: String
}

struct UniversalLinkPermittedDomain: Codable {

	let url: String

	let name: String
}

struct RemoteConfiguration: Codable {

	/// The minimum required version
	var minimumVersion: String

	/// The message for the minimum required version
	var minimumVersionMessage: String?

	/// The url to the appStore
	var appStoreURL: URL?

	/// The url to the site
	var informationURL: URL?

	/// Is the app deactivated?
	var appDeactivated: Bool?

	/// What is the TTL of the config
	var configTTL: Int?

	/// What is the waiting period before a recovery is valid?
	var recoveryWaitingPeriodDays: Int?

	/// When should we update
	var requireUpdateBefore: TimeInterval?

	/// Is the app temporarily disabled?
	var temporarilyDisabled: Bool?

	/// What is the validity of a domestic  test / vaccination
	var domesticValidityHours: Int?

	/// Max validity of a vaccination
	var vaccinationEventValidity: Int?

	/// max validity of a recovery
	var recoveryEventValidity: Int?

	/// max validity of a test
	var testEventValidity: Int?

	var recoveryExpirationDays: Int?

	var domesticQRRefreshSeconds: Int?
	
	var hpkCodes: [HPKData]? = []

	var nlTestTypes: [Mapping]? = []

	var euBrands: [Mapping]? = []

	var euManufacturers: [Mapping]?

	var euVaccinationTypes: [Mapping]?

	var euTestTypes: [Mapping]? = []

	var euTestManufacturers: [Mapping]? = []

	/// Restricts access to GGD test provider login
	var isGGDEnabled: Bool?

	var credentialRenewalDays: Int?

	var universalLinkPermittedDomains: [UniversalLinkPermittedDomain]?

	var clockDeviationThresholdSeconds: Int?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case minimumVersion = "iosMinimumVersion"
		case minimumVersionMessage = "iosMinimumVersionMessage"
		case appStoreURL = "iosAppStoreURL"
		case appDeactivated = "appDeactivated"
		case informationURL = "informationURL"
		case configTTL = "configTTL"
		case recoveryWaitingPeriodDays = "recoveryWaitingPeriodDays"
		case requireUpdateBefore = "requireUpdateBefore"
		case temporarilyDisabled = "temporarilyDisabled"
		case domesticValidityHours = "domesticValidity"
		case vaccinationEventValidity = "vaccinationEventValidity"
		case recoveryEventValidity = "recoveryEventValidity"
		case testEventValidity = "testEventValidity"
		case recoveryExpirationDays = "recoveryExpirationDays"
		case hpkCodes = "hpkCodes"
		case euBrands = "euBrands"
		case nlTestTypes = "nlTestTypes"
		case euManufacturers = "euManufacturers"
		case euVaccinationTypes = "euVaccinations"
		case euTestTypes = "euTestTypes"
		case euTestManufacturers = "euTestManufacturers"
		case isGGDEnabled = "ggdEnabled"
		case credentialRenewalDays = "credentialRenewalDays"
		case domesticQRRefreshSeconds = "domesticQRRefreshSeconds"
		case universalLinkPermittedDomains = "universalLinkDomains"
		case clockDeviationThresholdSeconds = "clockDeviationThresholdSeconds"
	}

	init(
		minVersion: String,
		minVersionMessage: String?,
		storeUrl: URL?,
		deactivated: Bool?,
		informationURL: URL?,
		configTTL: Int?,
		recoveryWaitingPeriodDays: Int?,
		requireUpdateBefore: TimeInterval?,
		temporarilyDisabled: Bool?,
		domesticValidityHours: Int?,
		vaccinationEventValidity: Int?,
		recoveryEventValidity: Int?,
		testEventValidity: Int?,
		isGGDEnabled: Bool?,
		recoveryExpirationDays: Int?,
		credentialRenewalDays: Int?,
		domesticQRRefreshSeconds: Int?,
		universalLinkPermittedDomains: [UniversalLinkPermittedDomain]?,
		clockDeviationThresholdSeconds: Int?) {

		self.minimumVersion = minVersion
		self.minimumVersionMessage = minVersionMessage
		self.appStoreURL = storeUrl
		self.appDeactivated = deactivated
		self.informationURL = informationURL
		self.configTTL = configTTL
		self.recoveryWaitingPeriodDays = recoveryWaitingPeriodDays
		self.requireUpdateBefore = requireUpdateBefore
		self.temporarilyDisabled = temporarilyDisabled
		self.domesticValidityHours = domesticValidityHours
		self.vaccinationEventValidity = vaccinationEventValidity
		self.recoveryEventValidity = recoveryEventValidity
		self.testEventValidity = testEventValidity
		self.isGGDEnabled = isGGDEnabled
		self.recoveryExpirationDays = recoveryExpirationDays
		self.credentialRenewalDays = credentialRenewalDays
		self.domesticQRRefreshSeconds = domesticQRRefreshSeconds
		self.universalLinkPermittedDomains = universalLinkPermittedDomains
		self.clockDeviationThresholdSeconds = clockDeviationThresholdSeconds
	}

	/// Default remote configuration
	static var `default`: RemoteConfiguration {
 		return RemoteConfiguration(
			minVersion: "1.0.0",
			minVersionMessage: nil,
			storeUrl: nil,
			deactivated: false,
			informationURL: nil,
			configTTL: 3600,
			recoveryWaitingPeriodDays: 11,
			requireUpdateBefore: nil,
			temporarilyDisabled: false,
			domesticValidityHours: 40,
			vaccinationEventValidity: 14600,
			recoveryEventValidity: 7300,
			testEventValidity: 40,
			isGGDEnabled: true,
			recoveryExpirationDays: 180,
			credentialRenewalDays: 5,
			domesticQRRefreshSeconds: 60,
			universalLinkPermittedDomains: nil,
			clockDeviationThresholdSeconds: 30
		)
	}

	/// Is the app deactivated?
	var isDeactivated: Bool {

		return appDeactivated ?? false
	}
}

// MARK: Mapping

extension RemoteConfiguration {

	func getHpkData(_ code: String? ) -> HPKData? {

		return hpkCodes?.first(where: { $0.code == code })
	}

	func getNlTestType(_ code: String? ) -> String? {

		return nlTestTypes?.first(where: { $0.code == code })?.name
	}

	func getBrandMapping(_ code: String? ) -> String? {

		return euBrands?.first(where: { $0.code == code })?.name
	}

	func getTypeMapping(_ code: String? ) -> String? {

		return euVaccinationTypes?.first(where: { $0.code == code })?.name
	}

	func getVaccinationManufacturerMapping(_ code: String? ) -> String? {

		return euManufacturers?.first(where: { $0.code == code })?.name
	}

	func getTestTypeMapping(_ code: String? ) -> String? {

		return euTestTypes?.first(where: { $0.code == code })?.name
	}

	func getTestManufacturerMapping(_ code: String? ) -> String? {

		return euTestManufacturers?.first(where: { $0.code == code })?.name
	}
}
