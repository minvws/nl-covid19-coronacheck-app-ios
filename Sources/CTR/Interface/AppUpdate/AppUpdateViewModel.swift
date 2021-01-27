/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class AppUpdateViewModel {

	/// The url to the app store
	let updateURL: URL?

	/// The coordinator delegate
	weak var coordinator: AppCoordinatorDelegate?

	/// The update message
	@Bindable private(set) var message: String

	/// Flag if we can't open the app store
	@Bindable private(set) var showCannotOpenAppStoreAlert: Bool

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionInformation: the verion information
	init(coordinator: AppCoordinatorDelegate, versionInformation: AppVersionInformation) {

		self.coordinator = coordinator
		message = versionInformation.minimumVersionMessage ?? .updateAppContent
		updateURL = versionInformation.appStoreURL
		showCannotOpenAppStoreAlert = false
	}

	/// User tapped on the update button
	func updateButtonTapped() {

		guard let url = updateURL else {
			showCannotOpenAppStoreAlert = true
			return
		}
		coordinator?.openUrl(url)
	}
}
