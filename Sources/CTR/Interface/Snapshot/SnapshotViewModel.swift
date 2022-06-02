/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class SnapshotViewModel: Logging {

	/// The logging Category
	var loggingCategory: String = "SnapshotViewModel"

	var willEnterForegroundObserver: NSObjectProtocol?

	/// The version of the launch page
	@Bindable private(set) var dismiss: Bool = false

	/// The icon of the launch page
	@Bindable private(set) var appIcon: UIImage?

	/// Initializer
	/// - Parameters:
	///   - flavor: the app flavor (holder or verifier)
	init(flavor: AppFlavor) {

		appIcon = flavor == .holder ? I.launch.holderAppIcon() : I.launch.verifierAppIcon()

		willEnterForegroundObserver = NotificationCenter.default.addObserver(
			forName: UIApplication.willEnterForegroundNotification,
			object: nil,
			queue: nil) { [weak self] _ in

			self?.dismiss = true
		}
	}
}
