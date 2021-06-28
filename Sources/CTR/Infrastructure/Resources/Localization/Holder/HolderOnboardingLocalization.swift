/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

// MARK: - Holder

extension String {

	static var holderOnboardingTitleSafely: String {

		return Localization.string(for: "holder.onboarding.title.safely")
	}

	static var holderOnboardingMessageSafely: String {

		return Localization.string(for: "holder.onboarding.message.safely")
	}

	static var holderOnboardingTitleYourQR: String {

		return Localization.string(for: "holder.onboarding.title.yourqr")
	}

	static var holderOnboardingMessageYourQR: String {

		return Localization.string(for: "holder.onboarding.message.yourqr")
	}

	static var holderOnboardingTitleValidity: String {

		return Localization.string(for: "holder.onboarding.title.validity")
	}

	static var holderOnboardingMessageValidity: String {

		return Localization.string(for: "holder.onboarding.message.validity")
	}
}
