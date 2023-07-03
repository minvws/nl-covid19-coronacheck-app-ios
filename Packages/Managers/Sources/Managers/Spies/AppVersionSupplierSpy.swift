/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class AppVersionSupplierSpy: AppVersionSupplierProtocol {

	var getCurrentVersionCalled = false
	var appVersion: String

	var getCurrentBuildCalled = false
	var appBuild: String

	init(version: String, build: String = "") {

		appVersion = version
		appBuild = build
	}

	func getCurrentVersion() -> String {

		getCurrentVersionCalled = true
		return appVersion
	}

	func getCurrentBuild() -> String {

		getCurrentBuildCalled = true
		return appBuild
	}
}
