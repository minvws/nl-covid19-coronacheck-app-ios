/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import XCTest
@testable import CTR

class UserSettingsSpy: UserSettingsProtocol {

	var invokedScanInstructionShownSetter = false
	var invokedScanInstructionShownSetterCount = 0
	var invokedScanInstructionShown: Bool?
	var invokedScanInstructionShownList = [Bool]()
	var invokedScanInstructionShownGetter = false
	var invokedScanInstructionShownGetterCount = 0
	var stubbedScanInstructionShown: Bool! = false

	var scanInstructionShown: Bool {
		set {
			invokedScanInstructionShownSetter = true
			invokedScanInstructionShownSetterCount += 1
			invokedScanInstructionShown = newValue
			invokedScanInstructionShownList.append(newValue)
		}
		get {
			invokedScanInstructionShownGetter = true
			invokedScanInstructionShownGetterCount += 1
			return stubbedScanInstructionShown
		}
	}

	var invokedJailbreakWarningShownSetter = false
	var invokedJailbreakWarningShownSetterCount = 0
	var invokedJailbreakWarningShown: Bool?
	var invokedJailbreakWarningShownList = [Bool]()
	var invokedJailbreakWarningShownGetter = false
	var invokedJailbreakWarningShownGetterCount = 0
	var stubbedJailbreakWarningShown: Bool! = false

	var jailbreakWarningShown: Bool {
		set {
			invokedJailbreakWarningShownSetter = true
			invokedJailbreakWarningShownSetterCount += 1
			invokedJailbreakWarningShown = newValue
			invokedJailbreakWarningShownList.append(newValue)
		}
		get {
			invokedJailbreakWarningShownGetter = true
			invokedJailbreakWarningShownGetterCount += 1
			return stubbedJailbreakWarningShown
		}
	}

	var invokedDashboardRegionToggleValueSetter = false
	var invokedDashboardRegionToggleValueSetterCount = 0
	var invokedDashboardRegionToggleValue: QRCodeValidityRegion?
	var invokedDashboardRegionToggleValueList = [QRCodeValidityRegion]()
	var invokedDashboardRegionToggleValueGetter = false
	var invokedDashboardRegionToggleValueGetterCount = 0
	var stubbedDashboardRegionToggleValue: QRCodeValidityRegion!

	var dashboardRegionToggleValue: QRCodeValidityRegion {
		set {
			invokedDashboardRegionToggleValueSetter = true
			invokedDashboardRegionToggleValueSetterCount += 1
			invokedDashboardRegionToggleValue = newValue
			invokedDashboardRegionToggleValueList.append(newValue)
		}
		get {
			invokedDashboardRegionToggleValueGetter = true
			invokedDashboardRegionToggleValueGetterCount += 1
			return stubbedDashboardRegionToggleValue
		}
	}

	var invokedConfigFetchedTimestampSetter = false
	var invokedConfigFetchedTimestampSetterCount = 0
	var invokedConfigFetchedTimestamp: TimeInterval?
	var invokedConfigFetchedTimestampList = [TimeInterval?]()
	var invokedConfigFetchedTimestampGetter = false
	var invokedConfigFetchedTimestampGetterCount = 0
	var stubbedConfigFetchedTimestamp: TimeInterval!

	var configFetchedTimestamp: TimeInterval? {
		set {
			invokedConfigFetchedTimestampSetter = true
			invokedConfigFetchedTimestampSetterCount += 1
			invokedConfigFetchedTimestamp = newValue
			invokedConfigFetchedTimestampList.append(newValue)
		}
		get {
			invokedConfigFetchedTimestampGetter = true
			invokedConfigFetchedTimestampGetterCount += 1
			return stubbedConfigFetchedTimestamp
		}
	}

	var invokedConfigFetchedHashSetter = false
	var invokedConfigFetchedHashSetterCount = 0
	var invokedConfigFetchedHash: String?
	var invokedConfigFetchedHashList = [String?]()
	var invokedConfigFetchedHashGetter = false
	var invokedConfigFetchedHashGetterCount = 0
	var stubbedConfigFetchedHash: String!

	var configFetchedHash: String? {
		set {
			invokedConfigFetchedHashSetter = true
			invokedConfigFetchedHashSetterCount += 1
			invokedConfigFetchedHash = newValue
			invokedConfigFetchedHashList.append(newValue)
		}
		get {
			invokedConfigFetchedHashGetter = true
			invokedConfigFetchedHashGetterCount += 1
			return stubbedConfigFetchedHash
		}
	}

	var invokedLastScreenshotTimeSetter = false
	var invokedLastScreenshotTimeSetterCount = 0
	var invokedLastScreenshotTime: Date?
	var invokedLastScreenshotTimeList = [Date?]()
	var invokedLastScreenshotTimeGetter = false
	var invokedLastScreenshotTimeGetterCount = 0
	var stubbedLastScreenshotTime: Date!

	var lastScreenshotTime: Date? {
		set {
			invokedLastScreenshotTimeSetter = true
			invokedLastScreenshotTimeSetterCount += 1
			invokedLastScreenshotTime = newValue
			invokedLastScreenshotTimeList.append(newValue)
		}
		get {
			invokedLastScreenshotTimeGetter = true
			invokedLastScreenshotTimeGetterCount += 1
			return stubbedLastScreenshotTime
		}
	}

	var invokedIssuerKeysFetchedTimestampSetter = false
	var invokedIssuerKeysFetchedTimestampSetterCount = 0
	var invokedIssuerKeysFetchedTimestamp: TimeInterval?
	var invokedIssuerKeysFetchedTimestampList = [TimeInterval?]()
	var invokedIssuerKeysFetchedTimestampGetter = false
	var invokedIssuerKeysFetchedTimestampGetterCount = 0
	var stubbedIssuerKeysFetchedTimestamp: TimeInterval!

	var issuerKeysFetchedTimestamp: TimeInterval? {
		set {
			invokedIssuerKeysFetchedTimestampSetter = true
			invokedIssuerKeysFetchedTimestampSetterCount += 1
			invokedIssuerKeysFetchedTimestamp = newValue
			invokedIssuerKeysFetchedTimestampList.append(newValue)
		}
		get {
			invokedIssuerKeysFetchedTimestampGetter = true
			invokedIssuerKeysFetchedTimestampGetterCount += 1
			return stubbedIssuerKeysFetchedTimestamp
		}
	}

	var invokedLastRecommendUpdateDismissalTimestampSetter = false
	var invokedLastRecommendUpdateDismissalTimestampSetterCount = 0
	var invokedLastRecommendUpdateDismissalTimestamp: TimeInterval?
	var invokedLastRecommendUpdateDismissalTimestampList = [TimeInterval?]()
	var invokedLastRecommendUpdateDismissalTimestampGetter = false
	var invokedLastRecommendUpdateDismissalTimestampGetterCount = 0
	var stubbedLastRecommendUpdateDismissalTimestamp: TimeInterval!

	var lastRecommendUpdateDismissalTimestamp: TimeInterval? {
		set {
			invokedLastRecommendUpdateDismissalTimestampSetter = true
			invokedLastRecommendUpdateDismissalTimestampSetterCount += 1
			invokedLastRecommendUpdateDismissalTimestamp = newValue
			invokedLastRecommendUpdateDismissalTimestampList.append(newValue)
		}
		get {
			invokedLastRecommendUpdateDismissalTimestampGetter = true
			invokedLastRecommendUpdateDismissalTimestampGetterCount += 1
			return stubbedLastRecommendUpdateDismissalTimestamp
		}
	}

	var invokedLastSeenRecommendedUpdateSetter = false
	var invokedLastSeenRecommendedUpdateSetterCount = 0
	var invokedLastSeenRecommendedUpdate: String?
	var invokedLastSeenRecommendedUpdateList = [String?]()
	var invokedLastSeenRecommendedUpdateGetter = false
	var invokedLastSeenRecommendedUpdateGetterCount = 0
	var stubbedLastSeenRecommendedUpdate: String!

	var lastSeenRecommendedUpdate: String? {
		set {
			invokedLastSeenRecommendedUpdateSetter = true
			invokedLastSeenRecommendedUpdateSetterCount += 1
			invokedLastSeenRecommendedUpdate = newValue
			invokedLastSeenRecommendedUpdateList.append(newValue)
		}
		get {
			invokedLastSeenRecommendedUpdateGetter = true
			invokedLastSeenRecommendedUpdateGetterCount += 1
			return stubbedLastSeenRecommendedUpdate
		}
	}

	var invokedDeviceAuthenticationWarningShownSetter = false
	var invokedDeviceAuthenticationWarningShownSetterCount = 0
	var invokedDeviceAuthenticationWarningShown: Bool?
	var invokedDeviceAuthenticationWarningShownList = [Bool]()
	var invokedDeviceAuthenticationWarningShownGetter = false
	var invokedDeviceAuthenticationWarningShownGetterCount = 0
	var stubbedDeviceAuthenticationWarningShown: Bool! = false

	var deviceAuthenticationWarningShown: Bool {
		set {
			invokedDeviceAuthenticationWarningShownSetter = true
			invokedDeviceAuthenticationWarningShownSetterCount += 1
			invokedDeviceAuthenticationWarningShown = newValue
			invokedDeviceAuthenticationWarningShownList.append(newValue)
		}
		get {
			invokedDeviceAuthenticationWarningShownGetter = true
			invokedDeviceAuthenticationWarningShownGetterCount += 1
			return stubbedDeviceAuthenticationWarningShown
		}
	}

	var invokedDidCompleteEUVaccinationMigrationSetter = false
	var invokedDidCompleteEUVaccinationMigrationSetterCount = 0
	var invokedDidCompleteEUVaccinationMigration: Bool?
	var invokedDidCompleteEUVaccinationMigrationList = [Bool]()
	var invokedDidCompleteEUVaccinationMigrationGetter = false
	var invokedDidCompleteEUVaccinationMigrationGetterCount = 0
	var stubbedDidCompleteEUVaccinationMigration: Bool! = false

	var didCompleteEUVaccinationMigration: Bool {
		set {
			invokedDidCompleteEUVaccinationMigrationSetter = true
			invokedDidCompleteEUVaccinationMigrationSetterCount += 1
			invokedDidCompleteEUVaccinationMigration = newValue
			invokedDidCompleteEUVaccinationMigrationList.append(newValue)
		}
		get {
			invokedDidCompleteEUVaccinationMigrationGetter = true
			invokedDidCompleteEUVaccinationMigrationGetterCount += 1
			return stubbedDidCompleteEUVaccinationMigration
		}
	}

	var invokedDidDismissEUVaccinationMigrationSuccessBannerSetter = false
	var invokedDidDismissEUVaccinationMigrationSuccessBannerSetterCount = 0
	var invokedDidDismissEUVaccinationMigrationSuccessBanner: Bool?
	var invokedDidDismissEUVaccinationMigrationSuccessBannerList = [Bool]()
	var invokedDidDismissEUVaccinationMigrationSuccessBannerGetter = false
	var invokedDidDismissEUVaccinationMigrationSuccessBannerGetterCount = 0
	var stubbedDidDismissEUVaccinationMigrationSuccessBanner: Bool! = false

	var didDismissEUVaccinationMigrationSuccessBanner: Bool {
		set {
			invokedDidDismissEUVaccinationMigrationSuccessBannerSetter = true
			invokedDidDismissEUVaccinationMigrationSuccessBannerSetterCount += 1
			invokedDidDismissEUVaccinationMigrationSuccessBanner = newValue
			invokedDidDismissEUVaccinationMigrationSuccessBannerList.append(newValue)
		}
		get {
			invokedDidDismissEUVaccinationMigrationSuccessBannerGetter = true
			invokedDidDismissEUVaccinationMigrationSuccessBannerGetterCount += 1
			return stubbedDidDismissEUVaccinationMigrationSuccessBanner
		}
	}

	var invokedShouldCheckRecoveryGreenCardRevisedValiditySetter = false
	var invokedShouldCheckRecoveryGreenCardRevisedValiditySetterCount = 0
	var invokedShouldCheckRecoveryGreenCardRevisedValidity: Bool?
	var invokedShouldCheckRecoveryGreenCardRevisedValidityList = [Bool]()
	var invokedShouldCheckRecoveryGreenCardRevisedValidityGetter = false
	var invokedShouldCheckRecoveryGreenCardRevisedValidityGetterCount = 0
	var stubbedShouldCheckRecoveryGreenCardRevisedValidity: Bool! = false

	var shouldCheckRecoveryGreenCardRevisedValidity: Bool {
		set {
			invokedShouldCheckRecoveryGreenCardRevisedValiditySetter = true
			invokedShouldCheckRecoveryGreenCardRevisedValiditySetterCount += 1
			invokedShouldCheckRecoveryGreenCardRevisedValidity = newValue
			invokedShouldCheckRecoveryGreenCardRevisedValidityList.append(newValue)
		}
		get {
			invokedShouldCheckRecoveryGreenCardRevisedValidityGetter = true
			invokedShouldCheckRecoveryGreenCardRevisedValidityGetterCount += 1
			return stubbedShouldCheckRecoveryGreenCardRevisedValidity
		}
	}

	var invokedShouldShowRecoveryValidityExtensionCardSetter = false
	var invokedShouldShowRecoveryValidityExtensionCardSetterCount = 0
	var invokedShouldShowRecoveryValidityExtensionCard: Bool?
	var invokedShouldShowRecoveryValidityExtensionCardList = [Bool]()
	var invokedShouldShowRecoveryValidityExtensionCardGetter = false
	var invokedShouldShowRecoveryValidityExtensionCardGetterCount = 0
	var stubbedShouldShowRecoveryValidityExtensionCard: Bool! = false

	var shouldShowRecoveryValidityExtensionCard: Bool {
		set {
			invokedShouldShowRecoveryValidityExtensionCardSetter = true
			invokedShouldShowRecoveryValidityExtensionCardSetterCount += 1
			invokedShouldShowRecoveryValidityExtensionCard = newValue
			invokedShouldShowRecoveryValidityExtensionCardList.append(newValue)
		}
		get {
			invokedShouldShowRecoveryValidityExtensionCardGetter = true
			invokedShouldShowRecoveryValidityExtensionCardGetterCount += 1
			return stubbedShouldShowRecoveryValidityExtensionCard
		}
	}

	var invokedShouldShowRecoveryValidityReinstationCardSetter = false
	var invokedShouldShowRecoveryValidityReinstationCardSetterCount = 0
	var invokedShouldShowRecoveryValidityReinstationCard: Bool?
	var invokedShouldShowRecoveryValidityReinstationCardList = [Bool]()
	var invokedShouldShowRecoveryValidityReinstationCardGetter = false
	var invokedShouldShowRecoveryValidityReinstationCardGetterCount = 0
	var stubbedShouldShowRecoveryValidityReinstationCard: Bool! = false

	var shouldShowRecoveryValidityReinstationCard: Bool {
		set {
			invokedShouldShowRecoveryValidityReinstationCardSetter = true
			invokedShouldShowRecoveryValidityReinstationCardSetterCount += 1
			invokedShouldShowRecoveryValidityReinstationCard = newValue
			invokedShouldShowRecoveryValidityReinstationCardList.append(newValue)
		}
		get {
			invokedShouldShowRecoveryValidityReinstationCardGetter = true
			invokedShouldShowRecoveryValidityReinstationCardGetterCount += 1
			return stubbedShouldShowRecoveryValidityReinstationCard
		}
	}

	var invokedHasDismissedRecoveryValidityExtensionCompletionCardSetter = false
	var invokedHasDismissedRecoveryValidityExtensionCompletionCardSetterCount = 0
	var invokedHasDismissedRecoveryValidityExtensionCompletionCard: Bool?
	var invokedHasDismissedRecoveryValidityExtensionCompletionCardList = [Bool]()
	var invokedHasDismissedRecoveryValidityExtensionCompletionCardGetter = false
	var invokedHasDismissedRecoveryValidityExtensionCompletionCardGetterCount = 0
	var stubbedHasDismissedRecoveryValidityExtensionCompletionCard: Bool! = false

	var hasDismissedRecoveryValidityExtensionCompletionCard: Bool {
		set {
			invokedHasDismissedRecoveryValidityExtensionCompletionCardSetter = true
			invokedHasDismissedRecoveryValidityExtensionCompletionCardSetterCount += 1
			invokedHasDismissedRecoveryValidityExtensionCompletionCard = newValue
			invokedHasDismissedRecoveryValidityExtensionCompletionCardList.append(newValue)
		}
		get {
			invokedHasDismissedRecoveryValidityExtensionCompletionCardGetter = true
			invokedHasDismissedRecoveryValidityExtensionCompletionCardGetterCount += 1
			return stubbedHasDismissedRecoveryValidityExtensionCompletionCard
		}
	}

	var invokedHasDismissedRecoveryValidityReinstationCompletionCardSetter = false
	var invokedHasDismissedRecoveryValidityReinstationCompletionCardSetterCount = 0
	var invokedHasDismissedRecoveryValidityReinstationCompletionCard: Bool?
	var invokedHasDismissedRecoveryValidityReinstationCompletionCardList = [Bool]()
	var invokedHasDismissedRecoveryValidityReinstationCompletionCardGetter = false
	var invokedHasDismissedRecoveryValidityReinstationCompletionCardGetterCount = 0
	var stubbedHasDismissedRecoveryValidityReinstationCompletionCard: Bool! = false

	var hasDismissedRecoveryValidityReinstationCompletionCard: Bool {
		set {
			invokedHasDismissedRecoveryValidityReinstationCompletionCardSetter = true
			invokedHasDismissedRecoveryValidityReinstationCompletionCardSetterCount += 1
			invokedHasDismissedRecoveryValidityReinstationCompletionCard = newValue
			invokedHasDismissedRecoveryValidityReinstationCompletionCardList.append(newValue)
		}
		get {
			invokedHasDismissedRecoveryValidityReinstationCompletionCardGetter = true
			invokedHasDismissedRecoveryValidityReinstationCompletionCardGetterCount += 1
			return stubbedHasDismissedRecoveryValidityReinstationCompletionCard
		}
	}

	var invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardSetter = false
	var invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardSetterCount = 0
	var invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard: Bool?
	var invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardList = [Bool]()
	var invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardGetter = false
	var invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardGetterCount = 0
	var stubbedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard: Bool! = false

	var hasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard: Bool {
		set {
			invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardSetter = true
			invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardSetterCount += 1
			invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard = newValue
			invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardList.append(newValue)
		}
		get {
			invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardGetter = true
			invokedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCardGetterCount += 1
			return stubbedHasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard
		}
	}

	var invokedReset = false
	var invokedResetCount = 0

	func reset() {
		invokedReset = true
		invokedResetCount += 1
	}
}
