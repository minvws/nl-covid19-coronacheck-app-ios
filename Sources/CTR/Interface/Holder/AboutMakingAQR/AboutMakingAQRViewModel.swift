/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutMakingAQRViewModel: Logging {

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The header image
	@Bindable private(set) var image: UIImage?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The sub title of the scene (differs from the page title)
	@Bindable private(set) var header: String

	/// The information body of the scene
	@Bindable private(set) var body: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		title = L.holderAboutmakingaqrTitle()
		header = L.holderAboutmakingaqrHeader()
		body = L.holderAboutmakingaqrBody()
		image = .create
	}

	func userTouchedURL(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}

	/// Login at a commercial tester
	@objc func userTappedNext() {

		coordinator?.userWishesToCreateAQR()
	}
}
