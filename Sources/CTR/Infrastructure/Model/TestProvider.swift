/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The test providers
struct TestProvider: Codable, Equatable {

	/// The identifier of the provider
	let identifier: String

	/// The name of the provider
	let name: String

	/// The url of the provider to fetch the result
	let resultURL: URL?

	/// The public key of the provider
	let publicKey: String

	/// The ssl certificate of the provider
	let certificate: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "provider_identifier"
		case name
		case resultURL = "result_url"
		case publicKey = "public_key"
		case certificate = "ssl_cert"
	}

	/// Get the certificate data
	/// - Returns: Certificate as Data
	func getCertificateData() -> Data? {

		if let base64DecodedString = certificate.base64Decoded() {
			return Data(base64DecodedString.utf8)
		}
		return nil
	}
}
