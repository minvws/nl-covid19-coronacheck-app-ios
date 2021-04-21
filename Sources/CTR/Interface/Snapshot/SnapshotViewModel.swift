/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class SnapshotViewModel: Logging {

	/// The logging Category
	var loggingCategory: String = "SnapshotViewModel"

	/// The current app version supplier
	var versionSupplier: AppVersionSupplierProtocol

	var willEnterForegroundObserver: NSObjectProtocol?

	/// The title of the launch page
	@Bindable private(set) var title: String

	/// The version of the launch page
	@Bindable private(set) var version: String

	/// The version of the launch page
	@Bindable private(set) var dismiss: Bool = false

	/// The icon of the launch page
	@Bindable private(set) var appIcon: UIImage?

	/// Initializer
	/// - Parameters:
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor (holder or verifier)
	init(
		versionSupplier: AppVersionSupplierProtocol,
		flavor: AppFlavor) {

		self.versionSupplier = versionSupplier

		title = flavor == .holder ? .holderLaunchTitle : .verifierLaunchTitle
		appIcon = flavor == .holder ? .holderAppIcon : .verifierAppIcon

		let versionString: String = flavor == .holder ? .holderLaunchVersion : .verifierLaunchVersion
		version = String(
			format: versionString,
			versionSupplier.getCurrentVersion(),
			versionSupplier.getCurrentBuild()
		)

		willEnterForegroundObserver = NotificationCenter.default.addObserver(
			forName: UIApplication.willEnterForegroundNotification,
			object: nil,
			queue: nil) { [weak self] _ in

			self?.dismiss = true
		}
	}
}
