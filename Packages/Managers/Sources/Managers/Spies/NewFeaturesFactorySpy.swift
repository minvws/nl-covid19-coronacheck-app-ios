/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

final public class NewFeaturesFactorySpy: NewFeaturesFactory {

	public init() {}
	
	public var invokedInformationGetter = false
	public var invokedInformationGetterCount = 0
	public var stubbedInformation: NewFeatureInformation!

	public var information: NewFeatureInformation {
		invokedInformationGetter = true
		invokedInformationGetterCount += 1
		return stubbedInformation
	}
}
