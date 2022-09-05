/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// TODO: Move back? 
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

    public init?(input: String, tokenValidator: TokenValidatorProtocol) {
        // Check the validity of the input
        guard tokenValidator.validate(input) else {
            return nil
        }

        let parts = input.split(separator: "-")
        guard parts.count >= 2, parts[0].count == 3 else { return nil }

        let identifierPart = String(parts[0])
        let tokenPart = String(parts[1])
        self = RequestToken(
            token: tokenPart,
            protocolVersion: type(of: self).highestKnownProtocolVersion,
            providerIdentifier: identifierPart
        )
    }
}
