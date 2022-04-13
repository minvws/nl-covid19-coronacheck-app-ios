/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol UpdatedDisclosurePolicyFactoryProtocol {

	/// Generate an array of `PagedAnnoucementItem` for New Disclosure Policy screens
	func create() -> [PagedAnnoucementItem]?
}

struct UpdatedDisclosurePolicyFactory: UpdatedDisclosurePolicyFactoryProtocol {

	/// Generate an array of `PagedAnnoucementItem` for New Disclosure Policy screens
	func create() -> [PagedAnnoucementItem]? {
		
		if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			
			return [PagedAnnoucementItem(
				title: L.holder_newintheapp_content_only1G_title(),
				content: L.holder_newintheapp_content_only1G_body(),
				image: I.disclosurePolicy.newInTheApp(),
				imageBackgroundColor: nil,
				tagline: L.general_newpolicy(),
				step: 0
			)]
		} else if Current.featureFlagManager.is3GExclusiveDisclosurePolicyEnabled() {
			
			if Current.userSettings.lastKnownConfigDisclosurePolicy == [] {
				
				// Special case: 0G -> 3G
				return [
					PagedAnnoucementItem(
						title: L.holder_newintheapp_content_only3G_title(),
						content: L.holder_newintheapp_content_only3G_body(),
						image: I.disclosurePolicy.newInTheApp(),
						imageBackgroundColor: nil,
						tagline: L.general_newpolicy(),
						step: 0
					),
					PagedAnnoucementItem(
						title: L.holder_newintheapp_content_dutchAndInternationalCertificates_title(),
						content: L.holder_newintheapp_content_dutchAndInternationalCertificates_body(),
						image: I.disclosurePolicy.dutchAndInternationalQRCards(),
						imageBackgroundColor: nil,
						tagline: L.general_newintheapp(),
						step: 0,
						nextButtonTitle: L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates()
					)
				]
			} else {
				
				return [PagedAnnoucementItem(
					title: L.holder_newintheapp_content_only3G_title(),
					content: L.holder_newintheapp_content_only3G_body(),
					image: I.disclosurePolicy.newInTheApp(),
					imageBackgroundColor: nil,
					tagline: L.general_newpolicy(),
					step: 0
				)]
			}
		} else if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			
			return [PagedAnnoucementItem(
				title: L.holder_newintheapp_content_3Gand1G_title(),
				content: L.holder_newintheapp_content_3Gand1G_body(),
				image: I.disclosurePolicy.newInTheApp(),
				imageBackgroundColor: nil,
				tagline: L.general_newintheapp(),
				step: 0
			)]
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
			
			return nil
		}
	}
}
