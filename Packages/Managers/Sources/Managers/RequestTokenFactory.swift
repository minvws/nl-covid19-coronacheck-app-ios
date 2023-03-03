/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Transport
import Models

public class RequestTokenFactory {
	
	public static func create(input: String, tokenValidator: TokenValidatorProtocol) -> RequestToken? {
		// Check the validity of the input
		guard tokenValidator.validate(input) else {
			return nil
		}
		
		let parts = input.split(separator: "-")
		guard parts.count >= 2, parts[0].count == 3 else { return nil }
		
		let identifierPart = String(parts[0])
		let tokenPart = String(parts[1])
		return RequestToken(
			token: tokenPart,
			protocolVersion: RequestToken.highestKnownProtocolVersion,
			providerIdentifier: identifierPart
		)
	}
}
