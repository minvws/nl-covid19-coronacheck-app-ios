/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol MappingManaging {

	init(remoteConfigManager: RemoteConfigManaging)

	func setProviderIdentifierMapping(_ providers: [EventFlow.EventProvider])

	func getProviderIdentifierMapping(_ code: String? ) -> String?

}

class MappingManager: MappingManaging, Logging {

	let remoteConfigManager: RemoteConfigManaging

	private var providerIdentifiers: [Mapping] = []

	required init(remoteConfigManager: RemoteConfigManaging) {

		self.remoteConfigManager = remoteConfigManager
	}

	func setProviderIdentifierMapping(_ providers: [EventFlow.EventProvider]) {

		providerIdentifiers.removeAll()

		providers.forEach { providerIdentifiers.append(Mapping(code: $0.identifier, name: $0.name)) }
	}

	func getProviderIdentifierMapping(_ code: String? ) -> String? {

		return providerIdentifiers.first(where: { $0.code == code })?.name
	}
}
