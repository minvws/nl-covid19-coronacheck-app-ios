/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol MappingManaging {

	init(remoteConfigManager: RemoteConfigManaging)

	func setEventProviders(_ providers: [EventFlow.EventProvider])

	func getProviderIdentifierMapping(_ code: String? ) -> String?

	func getDisplayIssuer(_ issuer: String) -> String

	func getDisplayCountry(_ country: String) -> String
	
	func getDisplayFacility(_ facility: String) -> String
}

class MappingManager: MappingManaging, Logging {

	let remoteConfigManager: RemoteConfigManaging

	private var providerIdentifiers: [Mapping] = []

	required init(remoteConfigManager: RemoteConfigManaging) {

		self.remoteConfigManager = remoteConfigManager
	}

	func setEventProviders(_ providers: [EventFlow.EventProvider]) {

		providerIdentifiers.removeAll()

		providers.forEach { providerIdentifiers.append(Mapping(code: $0.identifier, name: $0.name)) }
	}

	func getProviderIdentifierMapping(_ code: String? ) -> String? {

		return providerIdentifiers.first(where: { $0.code == code })?.name
	}

	func getDisplayIssuer(_ issuer: String) -> String {
		guard issuer == "Ministry of Health Welfare and Sport" else {
			return issuer
		}
		return L.holderVaccinationAboutIssuer()
	}

	func getDisplayCountry(_ country: String) -> String {
		guard ["NL", "NLD"].contains(country) else {
			return country
		}
		return L.holderVaccinationAboutCountry()
	}

	func getDisplayFacility(_ facility: String) -> String {
		guard facility == "Facility approved by the State of The Netherlands" else {
			return facility
		}
		return L.holderDccListFacility()
	}

}
