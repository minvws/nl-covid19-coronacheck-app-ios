/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// View Model for updating the application
class AppStatusViewModel {

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
	init(coordinator: AppCoordinatorDelegate, appStoreUrl: URL?, flavor: AppFlavor) {

		self.coordinator = coordinator
		title = flavor == .holder ? L.holder_updateApp_title() : L.verifier_updateApp_title()
		message = flavor == .holder ? L.holder_updateApp_content() : L.verifier_updateApp_content()
		actionTitle = flavor == .holder ? L.holder_updateApp_button() : L.verifier_updateApp_button()
		updateURL = appStoreUrl
		showCannotOpenAlert = false
		errorMessage = flavor == .holder ? L.holder_updateApp_errorMessage() : L.verifier_updateApp_errorMessage()
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
class AppDeactivatedViewModel: AppStatusViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - appStoreUrl: the store url
	override init(coordinator: AppCoordinatorDelegate, appStoreUrl: URL?, flavor: AppFlavor) {

		super.init(coordinator: coordinator, appStoreUrl: appStoreUrl, flavor: flavor)

		self.title = flavor == .holder ? L.holder_endOfLife_title() : L.verifier_endOfLife_title()
		self.message = flavor == .holder ? L.holder_endOfLife_description() : L.verifier_endOfLife_description()
		self.errorMessage = flavor == .holder ? L.holder_endOfLife_errorMessage() : L.verifier_endOfLife_errorMessage()
		self.actionTitle = flavor == .holder ? L.holder_endOfLife_button() : L.verifier_endOfLife_button()
		self.image = I.endOfLife()
	}
}

/// View Model when there is no internet
class InternetRequiredViewModel: AppStatusViewModel {

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AppCoordinatorDelegate, flavor: AppFlavor) {

		super.init(coordinator: coordinator, appStoreUrl: nil, flavor: flavor)

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

extension AppStatusViewModel: Equatable {
	static func == (lhs: AppStatusViewModel, rhs: AppStatusViewModel) -> Bool {
		return lhs.title == rhs.title &&
		lhs.message == rhs.message &&
		lhs.updateURL == rhs.updateURL &&
		lhs.actionTitle == rhs.actionTitle &&
		lhs.image == rhs.image
	}
}
