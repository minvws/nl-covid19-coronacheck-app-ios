/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ForcedInformationModel {
	
	/// Coordination Delegate
	weak var coordinator: ForcedInformationCoordinatorDelegate?
	
	/// The pages for onboarding
	@Bindable private(set) var pages: [ForcedInformationPage]
	@Bindable private(set) var enabled: Bool
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - forcedInfo: the container with forced info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: ForcedInformationCoordinatorDelegate,
		pages: [ForcedInformationPage]) {
		
		self.coordinator = coordinator
		self.pages = pages
		self.enabled = true
	}
}
