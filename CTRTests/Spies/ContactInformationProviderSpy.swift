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

	var invokedPhoneNumberAbroadLinkGetter = false
	var invokedPhoneNumberAbroadLinkGetterCount = 0
	var stubbedPhoneNumberAbroadLink: String! = ""

	var phoneNumberAbroadLink: String {
		invokedPhoneNumberAbroadLinkGetter = true
		invokedPhoneNumberAbroadLinkGetterCount += 1
		return stubbedPhoneNumberAbroadLink
	}

	var invokedOpeningDaysGetter = false
	var invokedOpeningDaysGetterCount = 0
	var stubbedOpeningDays: String! = ""

	var openingDays: String {
		invokedOpeningDaysGetter = true
		invokedOpeningDaysGetterCount += 1
		return stubbedOpeningDays
	}

	var invokedStartHourGetter = false
	var invokedStartHourGetterCount = 0
	var stubbedStartHour: String! = ""

	var startHour: String {
		invokedStartHourGetter = true
		invokedStartHourGetterCount += 1
		return stubbedStartHour
	}

	var invokedEndHourGetter = false
	var invokedEndHourGetterCount = 0
	var stubbedEndHour: String! = ""

	var endHour: String {
		invokedEndHourGetter = true
		invokedEndHourGetterCount += 1
		return stubbedEndHour
	}
}
