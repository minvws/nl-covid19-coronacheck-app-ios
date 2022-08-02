/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	var cmsCertificates: [String]

	/// The ssl certificate of the provider
	var tlsCertificates: [String]
	
	/// Where can we use this provider for?
	var usages: [EventFlow.ProviderUsage]

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier
		case name
		case resultURLString = "url"
		case cmsCertificates = "cms"
		case tlsCertificates = "tls"
		case usages = "usage"
	}

	var resultURL: URL? {

		return URL(string: resultURLString)
	}
}
