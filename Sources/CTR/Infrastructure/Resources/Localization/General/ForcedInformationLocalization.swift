/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// MARK: Holder

extension String {

	static var newTermsTitle: String {

		return Localization.string(for: "new.terms.title")
	}

	static var newTermsHighlights: String {

		return Localization.string(for: "new.terms.highlights")
	}

	static var newTermsDescription: String {

		return Localization.string(for: "new.terms.description")
	}

	static var newTermsErrorTitle: String {

		return Localization.string(for: "new.terms.error.title")
	}

	static var newTermsErrorMessage: String {

		return Localization.string(for: "new.terms.error.message")
	}

	static var newTermsAgree: String {

		return Localization.string(for: "new.terms.agree")
	}

	static var newTermsDisagree: String {

		return Localization.string(for: "new.terms.disagree")
	}
	
	static var forcedInformationUpdatePageTitle: String {
		
		return Localization.string(for: "forcedinformation.updatepage.title")
	}
	
	static var forcedInformationUpdatePageTagline: String {
		
		return Localization.string(for: "forcedinformation.updatepage.tagline")
	}
	
	static var forcedInformationUpdatePageContent: String {
		
		return Localization.string(for: "forcedinformation.updatepage.content")
	}
}
