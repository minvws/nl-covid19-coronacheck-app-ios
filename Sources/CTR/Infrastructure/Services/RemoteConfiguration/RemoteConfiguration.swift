/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Protocol for app version information
protocol RemoteInformation {

	/// The minimum required version
	var minimumVersion: String { get }

	/// The message for the minimum required version
	var minimumVersionMessage: String? { get }

	/// The url to the appStore
	var appStoreURL: URL? { get }

	/// The url to the site
	var informationURL: URL? { get }

	/// Is the app deactivated?
	var appDeactivated: Bool? { get }

	/// What is the TTL of the config
	var configTTL: Int? { get }

	/// What is the validity of a test
	var maxValidityHours: Int? { get }

	/// What is the waiting period before a recovery is valid?
	var recoveryWaitingPeriodDays: Int? { get }

	/// When should we update
	var requireUpdateBefore: TimeInterval? { get }

	/// Is the app temporarily disabled?
	var temporarilyDisabled: Bool? { get }

	/// What is the validity of a domestic test / vaccination
	var domesticValidityHours: Int? { get }

	var vaccinationEventValidity: Int? { get }
	var recoveryEventValidity: Int? { get }
	var testEventValidity: Int? { get }

	// The number of days before a recovery expires
	var recoveryExpirationDays: Int? { get }

	// What is the lower threshold for remaining Credentials on a Greencard before we fetch more? (StrippenKaart)
	var credentialRenewalDays: Int? { get }
}

extension RemoteInformation {

	/// Is the app deactivated?
	var isDeactivated: Bool {

		return appDeactivated ?? false
	}
}

struct RemoteConfiguration: RemoteInformation, Codable {

	struct Mapping: Codable {
		let code: String
		let name: String
	}

	/// The minimum required version
	let minimumVersion: String

	/// The message for the minimum required version
	let minimumVersionMessage: String?

	/// The url to the appStore
	let appStoreURL: URL?

	/// The url to the site
	let informationURL: URL?

	/// Is the app deactivated?
	let appDeactivated: Bool?

	/// What is the TTL of the config
	let configTTL: Int?

	/// What is the validity of a test
	let maxValidityHours: Int?

	/// What is the waiting period before a recovery is valid?
	let recoveryWaitingPeriodDays: Int?

	/// When should we update
	let requireUpdateBefore: TimeInterval?

	/// Is the app temporarily disabled?
	let temporarilyDisabled: Bool?

	/// What is the validity of a domestic  test / vaccination
	let domesticValidityHours: Int?

	/// Max validity of a vaccination
	var vaccinationEventValidity: Int?

	/// max validity of a recovery
	var recoveryEventValidity: Int?

	/// max validity of a test
	var testEventValidity: Int?

	var recoveryExpirationDays: Int?

	var hpkCodes: [Mapping]? = []

	var nlTestTypes: [Mapping]? = []

	var euBrands: [Mapping]? = []

	var euManufacturers: [Mapping]?

	var euVaccinationTypes: [Mapping]?

	var euTestTypes: [Mapping]? = []

	var euTestManufacturers: [Mapping]? = []

	var providerIdentifiers: [Mapping]? = []
	
	/// Restricts access to GGD test provider login
	var isGGDEnabled: Bool?

	var credentialRenewalDays: Int?

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case minimumVersion = "iosMinimumVersion"
		case minimumVersionMessage = "iosMinimumVersionMessage"
		case appStoreURL = "iosAppStoreURL"
		case appDeactivated = "appDeactivated"
		case informationURL = "informationURL"
		case configTTL = "configTTL"
		case maxValidityHours = "maxValidityHours"
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
		case providerIdentifiers = "providerIdentifiers"
		case isGGDEnabled = "ggdEnabled"
		case credentialRenewalDays = "credentialRenewalDays"
	}

	init(
		minVersion: String,
		minVersionMessage: String?,
		storeUrl: URL?,
		deactivated: Bool?,
		informationURL: URL?,
		configTTL: Int?,
		maxValidityHours: Int?,
		recoveryWaitingPeriodDays: Int?,
		requireUpdateBefore: TimeInterval?,
		temporarilyDisabled: Bool?,
		domesticValidityHours: Int?,
		vaccinationEventValidity: Int?,
		recoveryEventValidity: Int?,
		testEventValidity: Int?,
		isGGDEnabled: Bool?,
		recoveryExpirationDays: Int?,
		credentialRenewalDays: Int?) {

		self.minimumVersion = minVersion
		self.minimumVersionMessage = minVersionMessage
		self.appStoreURL = storeUrl
		self.appDeactivated = deactivated
		self.informationURL = informationURL
		self.configTTL = configTTL
		self.maxValidityHours = maxValidityHours
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
			maxValidityHours: 40,
			recoveryWaitingPeriodDays: 11,
			requireUpdateBefore: nil,
			temporarilyDisabled: false,
			domesticValidityHours: 40,
			vaccinationEventValidity: 14600,
			recoveryEventValidity: 7300,
			testEventValidity: 40,
			isGGDEnabled: true,
			recoveryExpirationDays: 180,
			credentialRenewalDays: 5
		)
	}
}

// MARK: Mapping

extension RemoteConfiguration {

	func getHpkMapping(_ code: String? ) -> String? {

		return hpkCodes?.first(where: { $0.code == code })?.name
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

	func getProviderIdentifierMapping(_ code: String? ) -> String? {

		return providerIdentifiers?.first(where: { $0.code == code })?.name
	}
}
