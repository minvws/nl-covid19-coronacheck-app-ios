/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

struct Path {
    let components: [String]

    init(components: String...) {
        self.components = Array(components)
    }
}

struct Endpoint {

    // MARK: - API

	/// Endpoint for the remote configuration
	static let remoteConfiguration = Path(components: AppFlavor.flavor == .holder ? "holder" : "verifier", "config")

	/// Endpoint for the nonce
	static let nonce = Path(components: "holder", "get_nonce")

	/// Endpoint for test results as ism
	static let testResultIsm = Path(components: "holder", "get_test_ism")

	/// Endpoint for test providers
	static let testProviders = Path(components: "holder", "config_ctp")

	/// Endpoint for test types
	static let testTypes = Path(components: "holder", "get_test_types")
}
