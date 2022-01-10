/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

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
		
		let validityDays = Current.remoteConfigManager.storedConfiguration.vaccinationAssessementEventValidityDays ?? 14
		let validityDaysTimeInterval = TimeInterval(validityDays * 24 * 60 * 60)
		
		return !Current.walletManager.listEventGroups()
			// Filter for vaccinationassessment
			.filter { $0.type == OriginType.vaccinationassessment.rawValue }
			// Filter for validity
			.filter {
				guard let maxIssuedAt = $0.maxIssuedAt else {
					return false
				}
				return maxIssuedAt.addingTimeInterval(validityDaysTimeInterval) > now
			}
			.isEmpty
	}
}
