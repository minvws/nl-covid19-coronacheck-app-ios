/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// Viewmodel for updating the application
class AppUpdateViewModel {

	/// The url to the app store
	fileprivate var updateURL: URL?

	/// The coordinator delegate
	weak var coordinator: AppCoordinatorDelegate?

	/// The title
	@Bindable fileprivate(set) var title: String

	/// The update message
	@Bindable fileprivate(set) var message: String

	/// The action text
	@Bindable fileprivate(set) var actionTitle: String

	/// The action text
	@Bindable fileprivate(set) var image: UIImage?

	/// Flag if we can't open the app store
	@Bindable fileprivate(set) var showCannotOpenAlert: Bool

	/// The error message if we can not open the url
	@Bindable fileprivate(set) var errorMessage: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionInformation: the verion information
	init(coordinator: AppCoordinatorDelegate, versionInformation: AppVersionInformation?) {

		self.coordinator = coordinator
		title = .updateAppTitle
		message = versionInformation?.minimumVersionMessage ?? .updateAppContent
		actionTitle = .updateAppButton
		updateURL = versionInformation?.appStoreURL
		showCannotOpenAlert = false
		errorMessage = .updateAppErrorMessage
		self.image = .warning
	}

	/// User tapped on the update button
	func actionButtonTapped() {

		guard let url = updateURL else {
			showCannotOpenAlert = true
			return
		}
		coordinator?.openUrl(url)
	}
}

/// Viewmodel when the app is deactivated
class EndOfLifeViewModel: AppUpdateViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionInformation: the verion information
	override init(coordinator: AppCoordinatorDelegate, versionInformation: AppVersionInformation?) {

		super.init(coordinator: coordinator, versionInformation: versionInformation)

		self.title = .endOfLifeTitle
		self.message = .endOfLifeDescription
		self.errorMessage = .endOfLifeErrorMessage
		self.actionTitle = .endOfLifeButton
		self.updateURL = versionInformation?.informationURL
		self.errorMessage = .endOfLifeErrorMessage
		self.image = .warning
		self.updateURL = URL(string: "https://coronacheck.nl")
	}
}

/// Viewmodel when the app is deactivated
class InternetRequiredViewModel: AppUpdateViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AppCoordinatorDelegate) {

		super.init(coordinator: coordinator, versionInformation: nil)

		self.title = .internetRequiredTitle
		self.message = .internetRequiredText
		self.actionTitle = .internetRequiredButton
	}

	/// User tapped on the update button
	override func actionButtonTapped() {

		coordinator?.retry()
	}
}
