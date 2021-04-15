/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

extension ForcedInformationConsent {

	static var consentWithoutMandatoryConsent = ForcedInformationConsent(
		title: "test title without mandatory consent",
		highlight: "test highlight without mandatory consent",
		content: "test content without mandatory consent",
		consentMandatory: false
	)

	static var consentWithMandatoryConsent = ForcedInformationConsent(
		title: "test title with mandatory consent",
		highlight: "test highlight with mandatory consent",
		content: "test content with mandatory consent",
		consentMandatory: true
	)
}
