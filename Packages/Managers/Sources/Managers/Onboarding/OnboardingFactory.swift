/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Models
import Resources

public protocol OnboardingFactoryProtocol {

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

public struct HolderOnboardingFactory: OnboardingFactoryProtocol {

	public init() {}
	
	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	public func create() -> [PagedAnnoucementItem] {
		
		let pages = getOnboardingPagesForZeroDisclosurePolicies()
		return pages.sorted { $0.step < $1.step }
	}
	
	private func getOnboardingPagesForZeroDisclosurePolicies() -> [PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holder_onboarding_content_TravelSafe_0G_title(),
				content: L.holder_onboarding_content_TravelSafe_0G_message(),
				image: I.onboarding.zeroGInternational(),
				step: 1
			),
			PagedAnnoucementItem(
				title: L.holderOnboardingTitleYourqr(),
				content: L.holderOnboardingMessageYourqr(),
				image: I.onboarding.yourQR(),
				step: 2
			),
			PagedAnnoucementItem(
				title: L.holder_onboarding_content_onlyInternationalQR_0G_title(),
				content: L.holder_onboarding_content_onlyInternationalQR_0G_message(),
				image: I.onboarding.validity(),
				step: 3,
				nextButtonTitle: L.generalNext()
			)
		]
	}
	
	/// Get the Consent Title
	public func getConsentTitle() -> String {

		return L.holderConsentTitle()
	}

	/// Get the Consent message
	public func getConsentMessage() -> String {

		return L.holderConsentMessage()
	}

	/// Get the Consent Button Title
	public func getConsentButtonTitle() -> String {

		return L.holderConsentButton()
	}

	/// Get the consent Items
	public func getConsentItems() -> [String] {

		return [
			L.holderConsentItem1(),
			L.holderConsentItem2()
		]
	}

	/// Should we use the consent button
	public func useConsentButton() -> Bool {
		return false
	}

	public func getActionButtonTitle() -> String {
		return L.holderConsentAction()
	}
	
	public func getConsentNotGivenError() -> String? {
		return nil
	}
}

public struct VerifierOnboardingFactory: OnboardingFactoryProtocol {

	public init() {}
	
	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	public func create() -> [PagedAnnoucementItem] {

		let pages = [
			PagedAnnoucementItem(
				title: L.verifierOnboardingTitleSafely(),
				content: L.verifierOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				step: 1,
				nextButtonTitle: L.generalNext()
			)
		]

		return pages.sorted { $0.step < $1.step }
	}

	/// Get the Consent Title
	public func getConsentTitle() -> String {

		return L.verifierConsentTitle()
	}

	/// Get the Consent message
	public func getConsentMessage() -> String {

		return L.verifierConsentMessage()
	}

	/// Get the Consent Button Title
	public func getConsentButtonTitle() -> String {

		return L.verifierConsentButton()
	}

	/// Get the consent Items
	public func getConsentItems() -> [String] {

		return [
			L.verifierConsentItem1(),
			L.verifierConsentItem2(),
			L.verifierConsentItem3()
		]
	}

	/// Should we use the consent button
	public func useConsentButton() -> Bool {
		return true
	}

	public func getActionButtonTitle() -> String {
		return L.verifierConsentAction()
	}
	
	public func getConsentNotGivenError() -> String? {
		return L.verifierConsentButtonError()
	}
}
