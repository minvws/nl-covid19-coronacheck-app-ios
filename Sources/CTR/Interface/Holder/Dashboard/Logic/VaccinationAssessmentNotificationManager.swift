/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol VaccinationAssessmentNotificationnManagerProtocol {
	
	func hasVaccinationAssessmentEventButNoOrigin(now: Date) -> Bool
}

final class VaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationnManagerProtocol {
	
	func hasVaccinationAssessmentEventButNoOrigin(now: Date) -> Bool {
	
		return hasValidVaccinationAssessmentEventGroup(now) && !hasValidVaccinationAssessmentOrigin(now)
	}
	
	private func hasValidVaccinationAssessmentOrigin(_ now: Date) -> Bool {
		
		let originType = OriginType.vaccinationassessment
		return !Current.walletManager.greencardsWithUnexpiredOrigins(now: now, ofOriginType: originType).isEmpty
	}
	
	private func hasValidVaccinationAssessmentEventGroup(_ now: Date) -> Bool {
		
		let originType = OriginType.vaccinationassessment
		let validityDays = Current.remoteConfigManager.storedConfiguration.vaccinationAssessementEventValidityDays ?? 14
		let validityDaysTimeInterval = TimeInterval(validityDays * 24 * 60 * 60)
		
		return !Current.walletManager.listEventGroups()
			// Filter for vaccinationassessment
			.filter { $0.type == originType.rawValue }
			// Filter for validity
			.filter {
				if let maxIssuedAt = $0.maxIssuedAt {
					return maxIssuedAt.addingTimeInterval(validityDaysTimeInterval) > now
				}
				return false
			}
			.isEmpty
	}
}
