/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationGeneralProtocol: AnyObject {

	/// Get the TTL for a test result
	/// - Returns: TTL for a test result
	func getTestResultTTL() -> Int

	/// Get the TTL for a QR
	/// - Returns: TTL for a QR
	func getQRTTL() -> TimeInterval
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

	/// Get the TTL for a QR
	/// - Returns: TTL for a QR
	func getQRTTL() -> TimeInterval {
		guard let value = general["QRTTL"] as? TimeInterval else {
			fatalError("Configuration: No QR TTL provided")
		}
		return value
	}
}
