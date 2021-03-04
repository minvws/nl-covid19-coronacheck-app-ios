/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

// MARK: - Verifier

extension String {

	static var verifierOnboardingTitleSafely: String {

		return Localization.string(for: "verifier.onboarding.title.safely")
	}

	static var verifierOnboardingMessageSafely: String {

		return Localization.string(for: "verifier.onboarding.message.safely")
	}

	static var verifierOnboardingTitleScanQR: String {

		return Localization.string(for: "verifier.onboarding.title.scanqr")
	}

	static var verifierOnboardingMessageScanQR: String {

		return Localization.string(for: "verifier.onboarding.message.scanqr")
	}

	static var verifierOnboardingTitleAccess: String {

		return Localization.string(for: "verifier.onboarding.title.access")
	}

	static var verifierOnboardingMessageAccess: String {

		return Localization.string(for: "verifier.onboarding.message.access")
	}

	static var verifierOnboardingTitleWho: String {

		return Localization.string(for: "verifier.onboarding.title.who")
	}

	static var verifierOnboardingMessageWho: String {

		return Localization.string(for: "verifier.onboarding.message.who")
	}
}
