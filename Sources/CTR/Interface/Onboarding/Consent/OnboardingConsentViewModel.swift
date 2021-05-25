/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class OnboardingConsentViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	/// The onboarding factory for all content.
	var factory: OnboardingFactoryProtocol

	// MARK: - Bindable variables

	@Bindable private(set) var isContinueButtonEnabled: Bool
	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var underlinedText: String?
	@Bindable private(set) var consentText: String?
	@Bindable private(set) var summary: [String]
	@Bindable private(set) var shouldHideBackButton: Bool

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - factory: The factory for onboarding content
	init(coordinator: OnboardingCoordinatorDelegate, factory: OnboardingFactoryProtocol, shouldHideBackButton: Bool) {

		self.coordinator = coordinator
		self.factory = factory
		self.title = factory.getConsentTitle()
		self.message = factory.getConsentMessage()
		self.underlinedText = factory.getConsentLink()
		self.consentText = factory.getConsentButtonTitle()
		self.summary = factory.getConsentItems()
		self.isContinueButtonEnabled = false
		self.shouldHideBackButton = shouldHideBackButton
	}

	/// The user tapped on the consent button
	/// - Parameter given: True if consent is given
	func consentGiven(_ given: Bool) {

		isContinueButtonEnabled = given
	}

	/// The user tapped on the privacy link
	func linkTapped() {

		coordinator?.showPrivacyPage()
	}

	/// The user tapped on the primary button
	func primaryButtonTapped() {

		coordinator?.consentGiven()
	}
}
