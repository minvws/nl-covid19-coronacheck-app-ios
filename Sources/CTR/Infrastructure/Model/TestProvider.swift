/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The test providers
struct TestProvider: Codable, CertificateProvider, Equatable {

	/// The identifier of the provider
	let identifier: String

	/// The name of the provider
	let name: String

	/// The url of the provider to fetch the result
	let resultURLString: String

	/// The public key of the provider
	let publicKey: String

	/// The ssl certificate of the provider
	let certificate: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier = "provider_identifier"
		case name
		case resultURLString = "result_url"
		case publicKey = "public_key"
		case certificate = "ssl_cert"
	}

	var resultURL: URL? {

		return URL(string: resultURLString)
	}

	func getHostNames() -> [String] {

		[resultURL?.host].compactMap { $0 }
	}

	func getSSLCertificate() -> Data? {

		certificate.base64Decoded().map {
			Data($0.utf8)
		}
	}

	func getSigningCertificate() -> SigningCertificate? {

		publicKey.base64Decoded().map {
			SigningCertificate(
				name: "TestProvider",
				certificate: $0,
				commonName: nil,
				suffix: nil,
				authorityKeyIdentifier: nil,
				subjectKeyIdentifier: nil,
				rootSerial: nil
			)
		}
	}
}
