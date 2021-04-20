/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

// MARK: - Holder

extension String {

	static var holderUrlFAQ: String {
		
		return Localization.string(for: "holder.url.faq")
	}

	static var holderUrlAppointment: String {

		return Localization.string(for: "holder.url.appointment")
	}

	static var holderUrlPrivacy: String {

		return Localization.string(for: "holder.url.privacy")
	}
}

// MARK: - Verifier

extension String {

	static var verifierUrlFAQ: String {

		return Localization.string(for: "verifier.url.faq")
	}

	static var verifierUrlPrivacy: String {

		return Localization.string(for: "verifier.url.privacy")
	}
}
