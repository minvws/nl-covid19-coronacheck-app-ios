/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

// MARK: - Holder

extension String {

	static var holderConsentTitle: String {

		return Localization.string(for: "holder.consent.title")
	}

	static var holderConsentMessage: String {

		return Localization.string(for: "holder.consent.message")
	}

	static var holderConsentMessageUnderlined: String {

		return Localization.string(for: "holder.consent.message.underlined")
	}

	static var holderConsentItemOne: String {

		return Localization.string(for: "holder.consent.item.1")
	}

	static var holderConsentItemTwo: String {

		return Localization.string(for: "holder.consent.item.2")
	}

	static var holderConsentButtonTitle: String {

		return Localization.string(for: "holder.consent.button")
	}
}
