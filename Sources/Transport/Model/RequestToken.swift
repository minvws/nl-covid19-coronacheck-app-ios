/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The request token to fetch a test result form a commercial tester
public struct RequestToken: Codable, Equatable {

    /// The current highest known protocol version
    /// 1.0: Checksum
    /// 2.0: Initials + Birthday/month
	public static let highestKnownProtocolVersion = "3.0"

	/// The request token
	public let token: String

	/// The version of the protocol
	public let protocolVersion: String

	/// The identifier of the provider
	public let providerIdentifier: String

	// Key mapping
	enum CodingKeys: String, CodingKey {

		case token
		case protocolVersion
		case providerIdentifier
	}

	public init(token: String, protocolVersion: String, providerIdentifier: String) {
		self.token = token
		self.protocolVersion = protocolVersion
		self.providerIdentifier = providerIdentifier
	}
}
