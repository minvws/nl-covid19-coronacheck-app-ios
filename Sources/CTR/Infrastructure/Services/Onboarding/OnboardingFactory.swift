/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [PagedAnnoucementItem]

	/// Get the Consent Title
	func getConsentTitle() -> String

	/// Get the Consent message
	func getConsentMessage() -> String

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String
	
	/// Get the Consent not given error
	func getConsentNotGivenError() -> String?

	/// Get the consent Items
	func getConsentItems() -> [String]

	/// Should we use the consent button
	func useConsentButton() -> Bool

	/// Get the action Button Title
	func getActionButtonTitle() -> String
}

struct HolderOnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [PagedAnnoucementItem] {
		
		var pages = [PagedAnnoucementItem]()
		
		if Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() {
			pages = getOnboardingPagesForZeroDisclosurePolicies()
		} else {
			pages = getOnboardingPages()
		}
		if let policyPage = getDisclosurePolicyPage() {
			pages.append(policyPage)
		}
		return pages.sorted { $0.step < $1.step }
	}
	
	private func getOnboardingPagesForZeroDisclosurePolicies() -> [PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holder_onboarding_content_TravelSafe_0G_title(),
				content: L.holder_onboarding_content_TravelSafe_0G_message(),
				image: I.onboarding.zeroGInternational(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 1
			),
			PagedAnnoucementItem(
				title: L.holderOnboardingTitleYourqr(),
				content: L.holderOnboardingMessageYourqr(),
				image: I.onboarding.yourQR(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 2
			),
			PagedAnnoucementItem(
				title: L.holder_onboarding_content_onlyInternationalQR_0G_title(),
				content: L.holder_onboarding_content_onlyInternationalQR_0G_message(),
				image: I.onboarding.validity(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 3,
				nextButtonTitle: L.generalNext()
			)
		]
	}
	
	private func getOnboardingPages() -> [PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holderOnboardingTitleSafely(),
				content: L.holderOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 1
			),
			PagedAnnoucementItem(
				title: L.holderOnboardingTitleYourqr(),
				content: L.holderOnboardingMessageYourqr(),
				image: I.onboarding.yourQR(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 2
			),
			PagedAnnoucementItem(
				title: L.holderOnboardingTitleValidity(),
				content: L.holderOnboardingMessageValidity(),
				image: I.onboarding.validity(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 3
			),
			PagedAnnoucementItem(
				title: L.holderOnboardingTitlePrivacy(),
				content: L.holderOnboardingMessagePrivacy(),
				image: I.onboarding.international(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 4,
				nextButtonTitle: L.generalNext()
			)
		]
	}
	
	private func getDisclosurePolicyPage() -> PagedAnnoucementItem? {
		
		if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			return PagedAnnoucementItem(
				title: L.holder_onboarding_disclosurePolicyChanged_only1GAccess_title(),
				content: L.holder_onboarding_disclosurePolicyChanged_only1GAccess_message(),
				image: I.onboarding.disclosurePolicy(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 5,
				nextButtonTitle: L.generalNext()
			)
		} else if Current.featureFlagManager.is3GExclusiveDisclosurePolicyEnabled() {
			return PagedAnnoucementItem(
				title: L.holder_onboarding_disclosurePolicyChanged_only3GAccess_title(),
				content: L.holder_onboarding_disclosurePolicyChanged_only3GAccess_message(),
				image: I.onboarding.disclosurePolicy(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 5,
				nextButtonTitle: L.generalNext()
			)
		} else if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			return PagedAnnoucementItem(
				title: L.holder_onboarding_disclosurePolicyChanged_3Gand1GAccess_title(),
				content: L.holder_onboarding_disclosurePolicyChanged_3Gand1GAccess_message(),
				image: I.onboarding.disclosurePolicy(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 5,
				nextButtonTitle: L.generalNext()
			)
		}
		// No disclosure page for zero G
		return nil
	}
	
	/// Get the Consent Title
	func getConsentTitle() -> String {

		return L.holderConsentTitle()
	}

	/// Get the Consent message
	func getConsentMessage() -> String {

		return L.holderConsentMessage()
	}

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String {

		return L.holderConsentButton()
	}

	/// Get the consent Items
	func getConsentItems() -> [String] {

		return [
			L.holderConsentItem1(),
			L.holderConsentItem2()
		]
	}

	/// Should we use the consent button
	func useConsentButton() -> Bool {
		return false
	}

	func getActionButtonTitle() -> String {
		return L.holderConsentAction()
	}
	
	func getConsentNotGivenError() -> String? {
		return nil
	}
}

struct VerifierOnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [PagedAnnoucementItem] {

		let pages = [
			PagedAnnoucementItem(
				title: L.verifierOnboardingTitleSafely(),
				content: L.verifierOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				imageBackgroundColor: nil,
				tagline: nil,
				step: 1,
				nextButtonTitle: L.generalNext()
			)
		]

		return pages.sorted { $0.step < $1.step }
	}

	/// Get the Consent Title
	func getConsentTitle() -> String {

		return L.verifierConsentTitle()
	}

	/// Get the Consent message
	func getConsentMessage() -> String {

		return L.verifierConsentMessage()
	}

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String {

		return L.verifierConsentButton()
	}

	/// Get the consent Items
	func getConsentItems() -> [String] {

		return [
			L.verifierConsentItem1(),
			L.verifierConsentItem2(),
			L.verifierConsentItem3()
		]
	}

	/// Should we use the consent button
	func useConsentButton() -> Bool {
		return true
	}

	func getActionButtonTitle() -> String {
		return L.verifierConsentAction()
	}
	
	func getConsentNotGivenError() -> String? {
		return L.verifierConsentButtonError()
	}
}
