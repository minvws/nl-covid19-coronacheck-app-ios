/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

extension String {

	static var consentTitle: String {

		return Localization.string(for: "holder.consent.title")
	}

	static var consentMessage: String {

		return Localization.string(for: "holder.consent.message")
	}

	static var consentMessageUnderlined: String {

		return Localization.string(for: "holder.consent.message.underlined")
	}

	static var consentItemOne: String {

		return Localization.string(for: "holder.consent.item.1")
	}

	static var consentItemTwo: String {

		return Localization.string(for: "holder.consent.item.2")
	}

	static var consentItemThree: String {

		return Localization.string(for: "holder.consent.item.3")
	}

	static var consentItemFour: String {

		return Localization.string(for: "holder.consent.item.4")
	}

	static var consentButtonTitle: String {

		return Localization.string(for: "holder.consent.button")
	}
}
