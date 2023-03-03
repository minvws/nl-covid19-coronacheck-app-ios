/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The test providers
public struct TestProvider: Codable, CertificateProvider, Equatable {

	/// The identifier of the provider
	public let identifier: String

	/// The name of the provider
	public let name: String

	/// The url of the provider to fetch the result
	public let resultURLString: String

	/// The public key of the provider
	public var cmsCertificates: [String]

	/// The ssl certificate of the provider
	public var tlsCertificates: [String]
	
	/// Where can we use this provider for?
	public var usages: [EventFlow.ProviderUsage]

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case identifier
		case name
		case resultURLString = "url"
		case cmsCertificates = "cms"
		case tlsCertificates = "tls"
		case usages = "usage"
	}

	public var resultURL: URL? {

		return URL(string: resultURLString)
	}
	
	public init(identifier: String, name: String, resultURLString: String, cmsCertificates: [String], tlsCertificates: [String], usages: [EventFlow.ProviderUsage]) {
		self.identifier = identifier
		self.name = name
		self.resultURLString = resultURLString
		self.cmsCertificates = cmsCertificates
		self.tlsCertificates = tlsCertificates
		self.usages = usages
	}
}
