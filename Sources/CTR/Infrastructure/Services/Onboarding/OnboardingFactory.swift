/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [NewFeatureItem]

	/// Get the Consent Title
	func getConsentTitle() -> String

	/// Get the Consent message
	func getConsentMessage() -> String

	/// Get the Consent underlined message
	func getConsentLink() -> String

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
	func create() -> [NewFeatureItem] {
		
		var pages = [NewFeatureItem]()
		
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
	
	private func getOnboardingPagesForZeroDisclosurePolicies() -> [NewFeatureItem] {
		
		return [
			NewFeatureItem(
				title: L.holder_onboarding_content_TravelSafe_0G_title(),
				content: L.holder_onboarding_content_TravelSafe_0G_message(),
				image: I.onboarding.zeroGInternational(),
				tagline: nil,
				step: 1
			),
			NewFeatureItem(
				title: L.holderOnboardingTitleYourqr(),
				content: L.holderOnboardingMessageYourqr(),
				image: I.onboarding.yourQR(),
				tagline: nil,
				step: 2
			),
			NewFeatureItem(
				title: L.holder_onboarding_content_onlyInternationalQR_0G_title(),
				content: L.holder_onboarding_content_onlyInternationalQR_0G_message(),
				image: I.onboarding.validity(),
				tagline: nil,
				step: 3
			)
		]
	}
	
	private func getOnboardingPages() -> [NewFeatureItem] {
		
		return [
			NewFeatureItem(
				title: L.holderOnboardingTitleSafely(),
				content: L.holderOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				tagline: nil,
				step: 1
			),
			NewFeatureItem(
				title: L.holderOnboardingTitleYourqr(),
				content: L.holderOnboardingMessageYourqr(),
				image: I.onboarding.yourQR(),
				tagline: nil,
				step: 2
			),
			NewFeatureItem(
				title: L.holderOnboardingTitleValidity(),
				content: L.holderOnboardingMessageValidity(),
				image: I.onboarding.validity(),
				tagline: nil,
				step: 3
			),
			NewFeatureItem(
				title: L.holderOnboardingTitlePrivacy(),
				content: L.holderOnboardingMessagePrivacy(),
				image: I.onboarding.international(),
				tagline: nil,
				step: 4
			)
		]
	}
	
	private func getDisclosurePolicyPage() -> NewFeatureItem? {
		
		if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			return NewFeatureItem(
				title: L.holder_onboarding_disclosurePolicyChanged_only1GAccess_title(),
				content: L.holder_onboarding_disclosurePolicyChanged_only1GAccess_message(),
				image: I.onboarding.disclosurePolicy(),
				tagline: nil,
				step: 5
			)
		} else if Current.featureFlagManager.is3GExclusiveDisclosurePolicyEnabled() {
			return NewFeatureItem(
				title: L.holder_onboarding_disclosurePolicyChanged_only3GAccess_title(),
				content: L.holder_onboarding_disclosurePolicyChanged_only3GAccess_message(),
				image: I.onboarding.disclosurePolicy(),
				tagline: nil,
				step: 5
			)
		} else if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			return NewFeatureItem(
				title: L.holder_onboarding_disclosurePolicyChanged_3Gand1GAccess_title(),
				content: L.holder_onboarding_disclosurePolicyChanged_3Gand1GAccess_message(),
				image: I.onboarding.disclosurePolicy(),
				tagline: nil,
				step: 5
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
	/// Get the Consent underlined message
	func getConsentLink() -> String {

		return L.holderConsentMessageUnderlined()
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
	func create() -> [NewFeatureItem] {

		let pages = [
			NewFeatureItem(
				title: L.verifierOnboardingTitleSafely(),
				content: L.verifierOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				tagline: nil,
				step: 1
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
	/// Get the Consent underlined message
	func getConsentLink() -> String {

		return L.verifierConsentMessageUnderlined()
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
