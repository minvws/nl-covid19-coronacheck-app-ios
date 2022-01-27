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
	///   - appStoreUrl: the store url
	init(coordinator: AppCoordinatorDelegate, appStoreUrl: URL?) {

		self.coordinator = coordinator
		title = L.updateAppTitle()
		message = L.updateAppContent()
		actionTitle = L.updateAppButton()
		updateURL = appStoreUrl
		showCannotOpenAlert = false
		errorMessage = L.updateAppErrorMessage()
		self.image = I.updateRequired()
	}

	/// User tapped on the update button
	func actionButtonTapped() {

		guard let url = updateURL else {
			showCannotOpenAlert = true
			return
		}
		coordinator?.openUrl(url, completionHandler: nil)
	}
}

/// View Model when the app is deactivated
class EndOfLifeViewModel: AppUpdateViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - appStoreUrl: the store url
	override init(coordinator: AppCoordinatorDelegate, appStoreUrl: URL?) {

		super.init(coordinator: coordinator, appStoreUrl: URL(string: "https://coronacheck.nl"))

		self.title = L.endOfLifeTitle()
		self.message = L.endOfLifeDescription()
		self.errorMessage = L.endOfLifeErrorMessage()
		self.actionTitle = L.endOfLifeButton()
		self.image = I.endOfLife()
	}
}

/// View Model when there is no internet
class InternetRequiredViewModel: AppUpdateViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AppCoordinatorDelegate) {

		super.init(coordinator: coordinator, appStoreUrl: nil)

		self.title = L.internetRequiredTitle()
		self.message = L.internetRequiredText()
		self.actionTitle = L.internetRequiredButton()
		self.image = I.noInternet()
	}

	/// User tapped on the update button
	override func actionButtonTapped() {

		coordinator?.retry()
	}
}
