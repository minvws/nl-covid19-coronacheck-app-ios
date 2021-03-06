/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The version of the app
protocol AppVersionSupplierProtocol {

	/// Get the current version of the app
	func getCurrentVersion() -> String

	/// Get the current build of the app
	func getCurrentBuild() -> String
}

struct AppVersionSupplier: AppVersionSupplierProtocol {

	/// Get the current version number of the app
	/// - Returns: the current version number
	func getCurrentVersion() -> String {

		if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return version
		}
		// Default to 1.0.0
		return "1.0.0"
	}

	/// Get the current build of the app
	func getCurrentBuild() -> String {

		if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
			return version
		}
		// Default to 1
		return "1"
	}
}
