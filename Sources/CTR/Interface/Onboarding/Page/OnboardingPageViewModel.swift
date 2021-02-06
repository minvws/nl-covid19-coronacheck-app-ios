/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ConsentDelegate: AnyObject {

	func consentGiven(_ consent: Bool)
}

class OnboardingPageViewModel: Logging {

	var loggingCategory: String = "OnboardingPageViewModel"

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	/// Consent delegate
	weak var delegate: ConsentDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var underlinedText: String?
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var consent: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	init(
		coordinator: OnboardingCoordinatorDelegate,
		consentDelegate: ConsentDelegate?,
		onboardingInfo: OnboardingPage) {

		self.coordinator = coordinator
		delegate = consentDelegate
		title = onboardingInfo.title
		message = onboardingInfo.message
		image = onboardingInfo.image
		underlinedText = onboardingInfo.underlinedText
		consent = onboardingInfo.consent
	}

	/// Show the privacy page
	/// - Parameter viewController: the presenting viewcontroller
	func linkClicked(_ viewController: UIViewController) {
		
		coordinator?.showPrivacyPage(viewController)
	}

	/// Was consent given?
	/// - Parameter consent: True if it was
	func consentGiven(_ consent: Bool) {

		logDebug("Consent given: \(consent)")
		delegate?.consentGiven(consent)
	}
}
