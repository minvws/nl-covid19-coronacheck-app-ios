/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationGeneralProtocol: AnyObject {

	/// Get the time for auto close
	/// - Returns: Time for auto close
	func getAutoCloseTime() -> TimeInterval
}

// MARK: - ConfigurationGeneralProtocol

extension Configuration: ConfigurationGeneralProtocol {

	/// Get the time for auto close
	/// - Returns: Time for auto close
	func getAutoCloseTime() -> TimeInterval {
		guard let value = general["autoCloseTime"] as? TimeInterval else {
			fatalError("Configuration: No Auto Close Time provided")
		}
		return value
	}
}
