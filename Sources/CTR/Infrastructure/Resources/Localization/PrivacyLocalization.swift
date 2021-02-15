/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

// MARK: - Holder

extension String {

	static var holderPrivacyTitle: String {

		return Localization.string(for: "holder.privacy.title")
	}

	static var holderPrivacyMessage: String {

		return Localization.string(for: "holder.privacy.message")
	}
}

// MARK: - Verifier

extension String {

	static var verifierPrivacyTitle: String {

		return Localization.string(for: "verifier.privacy.title")
	}

	static var verifierPrivacyMessage: String {

		return Localization.string(for: "verifier.privacy.message")
	}
}
