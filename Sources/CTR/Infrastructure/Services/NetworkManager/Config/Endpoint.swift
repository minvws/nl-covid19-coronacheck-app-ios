/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

struct Path {

	/// The path components
    let components: [String]

	/// Initalizer
	/// - Parameter components: the path components
    init(components: String...) {
        self.components = Array(components)
    }
}

struct Endpoint {
	
	// MARK: - API
	
	/// Endpoint for the nonce
	static let nonce = Path(components: "holder", "nonce")
	
	/// Endpoint for the public keys
	static let publicKeys = Path(components: AppFlavor.flavor == .holder ? "holder" : "verifier", "public_keys")
	
	/// Endpoint for the remote configuration
	static let remoteConfiguration = Path(components: AppFlavor.flavor == .holder ? "holder" : "verifier", "config")
	
	/// Endpoint for test providers
	static let providers = Path(components: "holder", "config_providers")
	
	/// Endpoint for test results as ism
	static let sign = Path(components: "holder", "sign")
}
