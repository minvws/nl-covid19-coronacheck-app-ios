/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PagedAnnouncementItemViewModel: Logging {
	
	var loggingCategory: String = "OnboardingPageViewModel"
	
	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var image: UIImage?
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	init(onboardingInfo: OnboardingPage) {
		
		title = onboardingInfo.title
		message = onboardingInfo.message
		image = onboardingInfo.image
	}
}
