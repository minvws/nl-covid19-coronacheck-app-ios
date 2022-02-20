/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class NewDisclosurePolicyViewModel {
	
	/// Coordination Delegate
	weak var coordinator: Dismissable?
	
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var tagline: String?
	@Bindable private(set) var title: String?
	@Bindable private(set) var content: String?
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - forcedInfo: the container with forced info
	init?(coordinator: Dismissable) {
		
		self.coordinator = coordinator
		
		image = I.disclosurePolicy.newInTheApp()
		
		if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			tagline = L.general_newpolicy()
			title = L.holder_newintheapp_content_only1G_title()
			content = L.holder_newintheapp_content_only1G_body()
		} else if Current.featureFlagManager.is3GExclusiveDisclosurePolicyEnabled() {
			tagline = L.general_newpolicy()
			title = L.holder_newintheapp_content_only3G_title()
			content = L.holder_newintheapp_content_only3G_body()
		} else if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			tagline = L.general_newintheapp()
			title = L.holder_newintheapp_content_3Gand1G_title()
			content = L.holder_newintheapp_content_3Gand1G_body()
		} else {
			return nil
		}
	}
	
	func dismiss() {
		
		coordinator?.dismiss()
	}
}
