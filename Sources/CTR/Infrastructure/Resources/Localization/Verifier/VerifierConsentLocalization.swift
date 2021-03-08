/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

// MARK: - Verifier

extension String {

	static var verifierConsentTitle: String {

		return Localization.string(for: "verifier.consent.title")
	}

	static var verifierConsentMessage: String {

		return Localization.string(for: "verifier.consent.message")
	}

	static var verifierConsentMessageUnderlined: String {

		return Localization.string(for: "verifier.consent.message.underlined")
	}

	static var verifierConsentItemOne: String {

		return Localization.string(for: "verifier.consent.item.1")
	}

	static var verifierConsentItemTwo: String {

		return Localization.string(for: "verifier.consent.item.2")
	}

	static var verifierConsentItemThree: String {

		return Localization.string(for: "verifier.consent.item.3")
	}

	static var verifierConsentButtonTitle: String {

		return Localization.string(for: "verifier.consent.button")
	}
}
