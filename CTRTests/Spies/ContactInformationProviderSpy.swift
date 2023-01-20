/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

class ContactInformationProviderSpy: ContactInformationProtocol {

	var invokedPhoneNumberLinkGetter = false
	var invokedPhoneNumberLinkGetterCount = 0
	var stubbedPhoneNumberLink: String! = ""

	var phoneNumberLink: String {
		invokedPhoneNumberLinkGetter = true
		invokedPhoneNumberLinkGetterCount += 1
		return stubbedPhoneNumberLink
	}
}
