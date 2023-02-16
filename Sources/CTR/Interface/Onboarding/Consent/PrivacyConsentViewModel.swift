/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Managers

final class PrivacyConsentViewModel {

	/// Coordination Delegate
	weak var coordinator: (OnboardingCoordinatorDelegate & OpenUrlProtocol)?

	// MARK: - Bindable variables

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var consentText: String?
	@Bindable private(set) var consentNotGivenError: String?
	@Bindable private(set) var actionTitle: String?
	@Bindable private(set) var summary: [String]
	@Bindable private(set) var shouldHideBackButton: Bool
	@Bindable private(set) var shouldHideConsentButton: Bool
	@Bindable private(set) var shouldDisplayConsentError: Bool

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - factory: The factory for onboarding content
	init(coordinator: OnboardingCoordinatorDelegate & OpenUrlProtocol, factory: OnboardingFactoryProtocol, shouldHideBackButton: Bool) {

		self.coordinator = coordinator
		self.title = factory.getConsentTitle()
		self.message = factory.getConsentMessage()
		self.summary = factory.getConsentItems()
		self.consentText = factory.getConsentButtonTitle()
		self.shouldHideBackButton = shouldHideBackButton
		self.actionTitle = factory.getActionButtonTitle()
		self.consentNotGivenError = factory.getConsentNotGivenError()
		self.shouldHideConsentButton = !factory.useConsentButton()
		self.shouldDisplayConsentError = false
	}

	/// The user tapped on the consent button
	/// - Parameter given: True if consent is given
	func consentGiven(_ given: Bool) {

		shouldDisplayConsentError = !given
	}
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}

	/// The user tapped on the primary button
	func primaryButtonTapped() {

		coordinator?.consentGiven()
	}
}
