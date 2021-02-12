/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationGeneralProtocol {

	/// Get the TTL for a test result
	/// - Returns: TTL for a test result
	func getTestResultTTL() -> Int
}

extension Configuration: ConfigurationGeneralProtocol {

	/// Get the TTL for a test result
	/// - Returns: TTL for a test result
	func getTestResultTTL() -> Int {
		guard let value = general["testresultTTL"] as? Int else {
			fatalError("Configuration: No Test Restult TTL provided")
		}
		return value
	}
}
