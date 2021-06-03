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

	/// The launch date of the EU greencard functionality
	var euLaunchDate: String? { get }

	/// What is the validity of a test
	var maxValidityHours: Int? { get }

	/// When should we update
	var requireUpdateBefore: TimeInterval? { get }

	/// Is the app temporarily disabled?
	var temporarilyDisabled: Bool? { get }

	/// What is the validity of a vaccination
	var vaccinationValidityHours: Int? { get }

	/// What is the validity of a recovery
	var recoveryValidityHours: Int? { get }

	/// What is the validity of a test
	var testValidityHours: Int? { get }

	/// What is the validity of a domestic test / vaccination
	var domesticValidityHours: Int? { get }
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

	/// The launch date of the EU greencard functionality
	let euLaunchDate: String?

	/// What is the validity of a test
	let maxValidityHours: Int?

	/// When should we update
	let requireUpdateBefore: TimeInterval?

	/// Is the app temporarily disabled?
	let temporarilyDisabled: Bool?

	/// What is the validity of a vaccination
	let vaccinationValidityHours: Int?

	/// What is the validity of a recovery
	let recoveryValidityHours: Int?

	/// What is the validity of a test
	let testValidityHours: Int?

	/// What is the validity of a domestic  test / vaccination
	let domesticValidityHours: Int?

	var hpkCodes: [Mapping]? = []

	var nlTestTypes: [Mapping]? = []

	var euBrands: [Mapping]? = []

	var euManufacturers: [Mapping]?

	var euVaccinationTypes: [Mapping]?

	var euTestTypes: [Mapping]? = []

	var euTestManufacturers: [Mapping]? = []

	/// Key mapping
	enum CodingKeys: String, CodingKey {

		case minimumVersion = "iosMinimumVersion"
		case minimumVersionMessage = "iosMinimumVersionMessage"
		case appStoreURL = "iosAppStoreURL"
		case appDeactivated = "appDeactivated"
		case informationURL = "informationURL"
		case configTTL = "configTTL"
		case euLaunchDate = "euLaunchDate"
		case maxValidityHours = "maxValidityHours"
		case requireUpdateBefore = "requireUpdateBefore"
		case temporarilyDisabled = "temporarilyDisabled"
		case vaccinationValidityHours = "vaccinationValidity"
		case recoveryValidityHours = "recoveryValidity"
		case testValidityHours = "testValidity"
		case domesticValidityHours = "domesticValidity"
		case hpkCodes = "hpkCodes"
		case euBrands = "euBrands"
		case nlTestTypes = "nlTestTypes"
		case euManufacturers = "euManufacturers"
		case euVaccinationTypes = "euVaccinations"
		case euTestTypes = "euTestTypes"
		case euTestManufacturers = "euTestManufacturers"
	}

	init(
		minVersion: String,
		minVersionMessage: String?,
		storeUrl: URL?,
		deactivated: Bool?,
		informationURL: URL?,
		configTTL: Int?,
		euLaunchDate: String?,
		maxValidityHours: Int?,
		requireUpdateBefore: TimeInterval?,
		temporarilyDisabled: Bool?,
		vaccinationValidityHours: Int?,
		recoveryValidityHours: Int?,
		testValidityHours: Int?,
		domesticValidityHours: Int?) {
		
		self.minimumVersion = minVersion
		self.minimumVersionMessage = minVersionMessage
		self.appStoreURL = storeUrl
		self.appDeactivated = deactivated
		self.informationURL = informationURL
		self.configTTL = configTTL
		self.euLaunchDate = euLaunchDate
		self.maxValidityHours = maxValidityHours
		self.requireUpdateBefore = requireUpdateBefore
		self.temporarilyDisabled = temporarilyDisabled
		self.vaccinationValidityHours = vaccinationValidityHours
		self.recoveryValidityHours = recoveryValidityHours
		self.testValidityHours = testValidityHours
		self.domesticValidityHours = domesticValidityHours
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
			euLaunchDate: nil,
			maxValidityHours: 40,
			requireUpdateBefore: nil,
			temporarilyDisabled: false,
			vaccinationValidityHours: 14600,
			recoveryValidityHours: 7300,
			testValidityHours: 40,
			domesticValidityHours: 40
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
}
