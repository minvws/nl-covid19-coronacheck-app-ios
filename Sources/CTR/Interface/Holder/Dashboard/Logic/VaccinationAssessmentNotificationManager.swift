/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
// swiftlint:disable type_name
protocol VaccinationAssessmentNotificationManagerProtocol {
	
	func hasVaccinationAssessmentEventButNoOrigin(now: Date) -> Bool
}

final class VaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationManagerProtocol {
	
	func hasVaccinationAssessmentEventButNoOrigin(now: Date) -> Bool {
	
		return hasValidVaccinationAssessmentEventGroup(now) && !hasValidVaccinationAssessmentOrigin(now)
	}
	
	private func hasValidVaccinationAssessmentOrigin(_ now: Date) -> Bool {
		
		return !Current.walletManager.greencardsWithUnexpiredOrigins(now: now, ofOriginType: OriginType.vaccinationassessment).isEmpty
	}
	
	private func hasValidVaccinationAssessmentEventGroup(_ now: Date) -> Bool {
		
		return !Current.walletManager.listEventGroups()
			// Filter for vaccinationassessment
			.filter { $0.type == OriginType.vaccinationassessment.rawValue }
			// Filter for validity
			.filter {
				guard let expiry = $0.expiryDate else {
					return false
				}
				return expiry > now
			}
			.isEmpty
	}
}
