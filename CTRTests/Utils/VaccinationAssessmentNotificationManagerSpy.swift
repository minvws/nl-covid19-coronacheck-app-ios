/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

// swiftlint:disable:next type_name
class VaccinationAssessmentNotificationManagerSpy: VaccinationAssessmentNotificationManagerProtocol {

	var invokedHasVaccinationAssessmentEventButNoOrigin = false
	var invokedHasVaccinationAssessmentEventButNoOriginCount = 0
	var invokedHasVaccinationAssessmentEventButNoOriginParameters: (now: Date, Void)?
	var invokedHasVaccinationAssessmentEventButNoOriginParametersList = [(now: Date, Void)]()
	var stubbedHasVaccinationAssessmentEventButNoOriginResult: Bool! = false

	func hasVaccinationAssessmentEventButNoOrigin(now: Date) -> Bool {
		invokedHasVaccinationAssessmentEventButNoOrigin = true
		invokedHasVaccinationAssessmentEventButNoOriginCount += 1
		invokedHasVaccinationAssessmentEventButNoOriginParameters = (now, ())
		invokedHasVaccinationAssessmentEventButNoOriginParametersList.append((now, ()))
		return stubbedHasVaccinationAssessmentEventButNoOriginResult
	}
}
