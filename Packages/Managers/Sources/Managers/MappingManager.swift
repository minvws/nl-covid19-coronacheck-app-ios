/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import Resources

public protocol MappingManaging {

	func getProviderIdentifierMapping(_ code: String? ) -> String?

	func getDisplayIssuer(_ issuer: String, country: String) -> String

	func getBilingualDisplayCountry(_ country: String, languageCode: String?) -> String
	
	func getDisplayCountry(_ country: String) -> String
	
	func getDisplayFacility(_ facility: String) -> String

	func getTestType(_ code: String? ) -> String?

	func getTestName(_ code: String? ) -> String?

	func getTestManufacturer(_ code: String? ) -> String?

	func isRatTest(_ code: String?) -> Bool

	func getHpkData(_ code: String? ) -> HPKData?

	func getVaccinationBrand(_ code: String? ) -> String?

	func getVaccinationType(_ code: String? ) -> String?

	func getVaccinationManufacturer(_ code: String? ) -> String?
}

public class MappingManager: MappingManaging {

	public static let RATTest = "LP217198-3"

	public let remoteConfigManager: RemoteConfigManaging

	private var providerIdentifiers: [Mapping] = []

	public required init(remoteConfigManager: RemoteConfigManaging) {

		self.remoteConfigManager = remoteConfigManager
		self.providerIdentifiers = remoteConfigManager.storedConfiguration.providerIdentifiers ?? []
	}

	public func getProviderIdentifierMapping(_ code: String? ) -> String? {

		return providerIdentifiers.first(where: { $0.code == code })?.name
	}

	public func getDisplayIssuer(_ issuer: String, country: String) -> String {
		guard issuer == "Ministry of Health Welfare and Sport", ["NL", "NLD"].contains(country) else {
			return issuer
		}
		return L.holderVaccinationAboutIssuer()
	}

	public func getBilingualDisplayCountry(_ country: String, languageCode: String?) -> String {
		guard ["NL", "NLD"].contains(country) else {
			if "nl" == languageCode {
				return (Locale.current.localizedString(forRegionCode: country) ?? country) + " / "
				+ (Locale(identifier: "en_GB").localizedString(forRegionCode: country) ?? country)
			} else {
				return Locale.current.localizedString(forRegionCode: country) ?? country
			}
		}
		return L.holderVaccinationAboutCountry()
	}
	
	public func getDisplayCountry(_ country: String) -> String {
		
		guard ["NL", "NLD"].contains(country) else {
			return Locale.current.localizedString(forRegionCode: country) ?? country
		}
		return L.generalNetherlands()
	}

	public func getDisplayFacility(_ facility: String) -> String {
		guard facility == "Facility approved by the State of The Netherlands" else {
			return facility
		}
		return L.holderDccListFacility()
	}

	// MARK: Test

	public func getTestType(_ code: String? ) -> String? {

		return remoteConfigManager.storedConfiguration.euTestTypes?.first(where: { $0.code == code })?.name
	}

	public func getTestName(_ code: String? ) -> String? {

		return remoteConfigManager.storedConfiguration.euTestNames?.first(where: { $0.code == code })?.name
	}

	public func getTestManufacturer(_ code: String? ) -> String? {

		return remoteConfigManager.storedConfiguration.euTestManufacturers?.first(where: { $0.code == code })?.name
	}

	public func isRatTest(_ code: String?) -> Bool {

		return code == MappingManager.RATTest
	}

	// Vaccination

	public func getHpkData(_ code: String? ) -> HPKData? {

		return remoteConfigManager.storedConfiguration.hpkCodes?.first(where: { $0.code == code })
	}

	public func getVaccinationBrand(_ code: String? ) -> String? {

		return remoteConfigManager.storedConfiguration.euBrands?.first(where: { $0.code == code })?.name
	}

	public func getVaccinationType(_ code: String? ) -> String? {

		return remoteConfigManager.storedConfiguration.euVaccinationTypes?.first(where: { $0.code == code })?.name
	}

	public func getVaccinationManufacturer(_ code: String? ) -> String? {

		return remoteConfigManager.storedConfiguration.euManufacturers?.first(where: { $0.code == code })?.name
	}
}
