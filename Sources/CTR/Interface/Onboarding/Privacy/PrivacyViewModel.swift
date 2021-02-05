//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PrivacyViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: OnboardingCoordinatorDelegate,
		title: String,
		message: String) {

		self.coordinator = coordinator
		self.title = title
		self.message = message
	}

	/// The user clicked on the next button
	func dismiss() {

		// Notify the coordinator
		coordinator?.dismiss()
	}
}
