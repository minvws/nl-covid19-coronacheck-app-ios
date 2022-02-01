/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PolicyInformationViewModel {
	
	/// Coordination Delegate
	weak var coordinator: ScanInstructionsCoordinatorDelegate?
	
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var tagline: String
	@Bindable private(set) var title: String
	@Bindable private(set) var content: String
	@Bindable private(set) var primaryButtonTitle = L.generalNext()
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - forcedInfo: the container with forced info
	init(
		coordinator: ScanInstructionsCoordinatorDelegate
	) {
		
		self.coordinator = coordinator
		
		image = I.scanner.scanStartHighRisk()
		tagline = L.new_policy_subtitle()
		
		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			title = L.new_in_app_risksetting_title()
			content = L.new_in_app_risksetting_subtitle()
		} else {
			// 1G only enabled
			title = L.new_policy_1G_title()
			content = L.new_policy_1G_subtitle()
		}
	}
	
	func finish() {
		
		Current.userSettings.policyInformationShown = true
		coordinator?.userDidCompletePages(hasScanLock: false)
	}
}
