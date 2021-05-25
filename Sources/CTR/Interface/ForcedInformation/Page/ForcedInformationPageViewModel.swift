/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ForcedInformationPageViewModel: Logging {
	
	var loggingCategory: String = "OnboardingPageViewModel"
	
	/// Coordination Delegate
	weak var coordinator: ForcedInformationCoordinatorDelegate?
	
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var tagline: String
	@Bindable private(set) var title: String
	@Bindable private(set) var content: String
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - forcedInfo: the container with forced info
	init(
		coordinator: ForcedInformationCoordinatorDelegate,
		forcedInfo: ForcedInformationPage) {
		
		self.coordinator = coordinator
		image = forcedInfo.image
		tagline = forcedInfo.tagline
		title = forcedInfo.title
		content = forcedInfo.content
	}
}
