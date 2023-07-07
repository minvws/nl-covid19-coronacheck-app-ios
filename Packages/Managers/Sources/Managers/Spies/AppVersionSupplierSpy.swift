/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public class AppVersionSupplierSpy: AppVersionSupplierProtocol {

	public var getCurrentVersionCalled = false
	public var appVersion: String

	public var getCurrentBuildCalled = false
	public var appBuild: String

	public init(version: String, build: String = "") {

		appVersion = version
		appBuild = build
	}

	public func getCurrentVersion() -> String {

		getCurrentVersionCalled = true
		return appVersion
	}

	public func getCurrentBuild() -> String {

		getCurrentBuildCalled = true
		return appBuild
	}
}
