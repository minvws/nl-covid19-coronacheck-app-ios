/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

final class NewFeaturesFactorySpy: NewFeaturesFactory {

	var invokedInformationGetter = false
	var invokedInformationGetterCount = 0
	var stubbedInformation: NewFeatureInformation!

	var information: NewFeatureInformation {
		invokedInformationGetter = true
		invokedInformationGetterCount += 1
		return stubbedInformation
	}
}
