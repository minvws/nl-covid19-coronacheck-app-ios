/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class AboutViewModel {

	// MARK: - Bindable

	/// The title of the about page
	@Bindable private(set) var title: String

	/// The message of the about page
	@Bindable private(set) var message: String

	/// The link of the about page
	@Bindable private(set) var version: String

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor
	init(
		versionSupplier: AppVersionSupplierProtocol,
		flavor: AppFlavor) {

		self.title = flavor == .holder ? .holderAboutTitle : .verifierAboutTitle
		self.message = flavor == .holder ? .holderAboutText : .verifierAboutText

		let versionString: String = flavor == .holder ? .holderLaunchVersion : .verifierLaunchVersion
		version = String(
			format: versionString,
			versionSupplier.getCurrentVersion(),
			versionSupplier.getCurrentBuild()
		)
	}
}
