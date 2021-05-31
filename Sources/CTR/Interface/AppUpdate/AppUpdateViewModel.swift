/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// View Model for updating the application
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
	///   - versionInformation: the version information
	init(coordinator: AppCoordinatorDelegate, versionInformation: RemoteInformation?) {

		self.coordinator = coordinator
		title = .updateAppTitle
		message = versionInformation?.minimumVersionMessage ?? .updateAppContent
		actionTitle = .updateAppButton
		updateURL = versionInformation?.appStoreURL
		showCannotOpenAlert = false
		errorMessage = .updateAppErrorMessage
		self.image = .updateRequired
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

/// View Model when the app is deactivated
class EndOfLifeViewModel: AppUpdateViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionInformation: the version information
	override init(coordinator: AppCoordinatorDelegate, versionInformation: RemoteInformation?) {

		super.init(coordinator: coordinator, versionInformation: versionInformation)

		self.title = .endOfLifeTitle
		self.message = .endOfLifeDescription
		self.errorMessage = .endOfLifeErrorMessage
		self.actionTitle = .endOfLifeButton
		self.updateURL = versionInformation?.informationURL
		self.errorMessage = .endOfLifeErrorMessage
		self.image = .endOfLife
		self.updateURL = URL(string: "https://coronacheck.nl")
	}
}

/// View Model when there is no internet
class InternetRequiredViewModel: AppUpdateViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AppCoordinatorDelegate) {

		super.init(coordinator: coordinator, versionInformation: nil)

		self.title = .internetRequiredTitle
		self.message = .internetRequiredText
		self.actionTitle = .internetRequiredButton
		self.image = .noInternet
	}

	/// User tapped on the update button
	override func actionButtonTapped() {

		coordinator?.retry()
	}
}
