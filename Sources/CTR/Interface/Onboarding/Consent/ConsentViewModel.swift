/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ConsentViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	/// The onboarding factory for all texts.
	var factory: OnboardingFactoryProtocol

	/// Is the button enabled?
	@Bindable private(set) var isContinueButtonEnabled: Bool
	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var underlinedText: String?
	@Bindable private(set) var consentText: String?
	@Bindable private(set) var summary: [String]

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: OnboardingCoordinatorDelegate, factory: OnboardingFactoryProtocol) {

		self.coordinator = coordinator
		self.factory = factory
		self.title = factory.getConsentTitle()
		self.message = factory.getConsentMessage()
		self.underlinedText = factory.getConsentLink()
		self.consentText = factory.getConsentButtonTitle()
		self.summary = factory.getConsentItems()
		self.isContinueButtonEnabled = false
	}

	/// The user tapped on the consent buton
	/// - Parameter given: True if consent is given
	func consentGiven(_ given: Bool) {

		isContinueButtonEnabled = given
	}

	/// The user tapped on the privacy link
	/// - Parameter viewController: the presenting view controller
	func linkTapped(_ presentingViewController: UIViewController) {

		coordinator?.showPrivacyPage(presentingViewController)
	}

	/// The user tapped on the primary button
	func primaryButtonTapped() {

		coordinator?.consentGiven()
	}
}
