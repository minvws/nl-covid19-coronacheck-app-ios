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
    static let remoteConfiguration = Path(components: "holder", "config")

	/// Endpoint for the nonce
	static let nonce = Path(components: "holder", "get_nonce")

	/// Endpoint for test results as ism
	static let testResultIsm = Path(components: "holder", "get_test_ism")

	/// Endpoint for test providers
	static let testProviders = Path(components: "holder", "config_ctp")
    
//    static let pairings = Path(components: "pairings")
//
//    static func `case`(identifier: String) -> Path { Path(components: "cases", identifier) }
//
//    static let questionnaires = Path(components: "questionnaires")
}
