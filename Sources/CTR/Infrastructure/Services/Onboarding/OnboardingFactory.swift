/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The steps of the onboarding
enum OnboardingStep: Int {

	case safelyOnTheRoad
	case yourQR
	case validity
	case access
	case privacy
	case who
}

struct OnboardingPage {

	/// The title of the onboarding page
	let title: String

	/// The message of the onboarding page
	let message: String

	/// The image of the onboarding page
	let image: UIImage?

	/// The step of the onboarding page
	let step: OnboardingStep
}

protocol OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [OnboardingPage]

	/// Get the Consent Title
	func getConsentTitle() -> String

	/// Get the Consent message
	func getConsentMessage() -> String

	/// Get the Consent underlined message
	func getConsentLink() -> String

	/// Get the Consent Button Title
	func getConsentButtonTitle() -> String

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
	func create() -> [OnboardingPage] {

		let pages = [
			OnboardingPage(
				title: L.holderOnboardingTitleSafely(),
				message: L.holderOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				step: .safelyOnTheRoad
			),
			OnboardingPage(
				title: L.holderOnboardingTitleYourqr(),
				message: L.holderOnboardingMessageYourqr(),
				image: I.onboarding.yourQR(),
				step: .yourQR
			),
			OnboardingPage(
				title: L.holderOnboardingTitleValidity(),
				message: L.holderOnboardingMessageValidity(),
				image: I.onboarding.validity(),
				step: .validity
			),
			OnboardingPage(
				title: L.holderOnboardingTitlePrivacy(),
				message: L.holderOnboardingMessagePrivacy(),
				image: I.onboarding.international(),
				step: .who
			)
		]

		return pages.sorted { $0.step.rawValue < $1.step.rawValue }
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
}

struct VerifierOnboardingFactory: OnboardingFactoryProtocol {

	/// Generate an array of onboarding steps
	/// - Returns: an array of onboarding steps
	func create() -> [OnboardingPage] {

		let pages = [
			OnboardingPage(
				title: L.verifierOnboardingTitleSafely(),
				message: L.verifierOnboardingMessageSafely(),
				image: I.onboarding.safely(),
				step: .safelyOnTheRoad
			),
			OnboardingPage(
				title: L.verifierOnboardingTitleScanqr(),
				message: L.verifierOnboardingMessageScanqr(),
				image: I.onboarding.scan(),
				step: .yourQR
			),
			OnboardingPage(
				title: L.verifierOnboardingTitleAccess(),
				message: L.verifierOnboardingMessageAccess(),
				image: I.onboarding.identity(),
				step: .access
			),
			OnboardingPage(
				title: L.verifierOnboardingTitleWho(),
				message: L.verifierOnboardingMessageWho(),
				image: I.onboarding.who(),
				step: .privacy
			)
		]

		return pages.sorted { $0.step.rawValue < $1.step.rawValue }
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
		return L.generalNext()
	}
}
