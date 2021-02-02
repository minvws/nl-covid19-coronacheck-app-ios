/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class CTRModel {

	//	let eventIdentifier = "66f27d6a-b221-4e66-a3b4-8f199b2be116"
		let eventIdentifier = "d9ff36de-2357-4fa6-a64e-1569aa57bf1c"
	//	let eventIdentifier = "26820d8a-471e-4dc7-a38d-462b2baac5e0"
	//	let eventIdentifier = "904d864c-8e1b-499f-b9a1-d0debb1f5a6a"
	//	let eventIdentifier = "99285236-1847-4cdb-9c7d-4ac035282800"
	// let eventIdentifier = "ae7077dd-cf79-41e3-9248-9e71eb3e127e"
	//	let eventIdentifier = "3a381807-c564-4bad-960c-8eabf95d23fc"
	//	let eventIdentifier = "7d42af0f-9238-4289-812b-d9fec46b8c78"
	//	let eventIdentifier = "802d041c-f007-47e5-a48e-a221eb22137d"

	let userIdentifier = "ef9f409a-8613-4600-b135-8d2ac12559b3"
	//	let userIdentifier = "29b16f70-5f8a-49b4-a35f-5db253f5beab"
	//	let userIdentifier = "039072d7-875b-4928-a92e-b7d5b219d71a"
	//	let userIdentifier = "5e7a13ef-b037-42df-8a08-704d3e2a488a"

	var issuers: [Issuer] = []

	var apiClient: ApiClientProtocol = ApiClient()

	func populate() {

		fetchIssuers()
	}

	func fetchIssuers() {

		apiClient.getPublicKeys { issuers in
			self.issuers = issuers
		}
	}
}
