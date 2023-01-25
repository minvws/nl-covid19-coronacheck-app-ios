/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared

struct UpdatedDisclosurePolicyFactory {
	
	/// Generate an array of `PagedAnnoucementItem` for New Disclosure Policy screens
	func create() -> [PagedAnnoucementItem] {
		
		if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			
			return possiblyCombineWithReturnToCTB(
				PagedAnnoucementItem(
					title: L.holder_newintheapp_content_only1G_title(),
					content: L.holder_newintheapp_content_only1G_body(),
					image: I.disclosurePolicy.newInTheApp(),
					imageBackgroundColor: nil,
					tagline: L.general_newpolicy(),
					step: returningFromNoDisclosurePolicies ? 1 : 0,
					nextButtonTitle: returningFromNoDisclosurePolicies ? L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates() : nil
				)
			)
		} else if Current.featureFlagManager.is3GExclusiveDisclosurePolicyEnabled() {
			
			return possiblyCombineWithReturnToCTB(
				PagedAnnoucementItem(
					title: L.holder_newintheapp_content_only3G_title(),
					content: L.holder_newintheapp_content_only3G_body(),
					image: I.disclosurePolicy.newInTheApp(),
					imageBackgroundColor: nil,
					tagline: L.general_newpolicy(),
					step: returningFromNoDisclosurePolicies ? 1 : 0,
					nextButtonTitle: returningFromNoDisclosurePolicies ? L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates() : nil
				)
			)
		} else if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			
			return possiblyCombineWithReturnToCTB(
				PagedAnnoucementItem(
					title: L.holder_newintheapp_content_3Gand1G_title(),
					content: L.holder_newintheapp_content_3Gand1G_body(),
					image: I.disclosurePolicy.newInTheApp(),
					imageBackgroundColor: nil,
					tagline: L.general_newpolicy(),
					step: returningFromNoDisclosurePolicies ? 1 : 0,
					nextButtonTitle: returningFromNoDisclosurePolicies ? L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates() : nil
				)
			)
			
		} else if Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() {
			
			return [PagedAnnoucementItem(
				title: L.holder_newintheapp_content_onlyInternationalCertificates_0G_title(),
				content: L.holder_newintheapp_content_onlyInternationalCertificates_0G_body(),
				image: I.onboarding.validity(),
				imageBackgroundColor: nil,
				tagline: L.general_newintheapp(),
				step: 0
			)]
		} else {
			
			return []
		}
	}
	
	private func possiblyCombineWithReturnToCTB(_ item: PagedAnnoucementItem) -> [PagedAnnoucementItem] {
		
		if returningFromNoDisclosurePolicies {
			// Special case: 0G -> Any G
			return [reenabledCTBItem, item]
		} else {
			return [item]
		}
	}
	
	private var returningFromNoDisclosurePolicies: Bool {
		
		return Current.userSettings.lastKnownConfigDisclosurePolicy == [] ||
		Current.userSettings.lastKnownConfigDisclosurePolicy == ["0G"]
	}
	
	private let reenabledCTBItem: PagedAnnoucementItem = PagedAnnoucementItem(
		title: L.holder_newintheapp_content_dutchAndInternationalCertificates_title(),
		content: L.holder_newintheapp_content_dutchAndInternationalCertificates_body(),
		image: I.disclosurePolicy.dutchAndInternationalQRCards(),
		imageBackgroundColor: nil,
		tagline: L.general_newintheapp(),
		step: 0
	)
}
