/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

class SecureUserSettingsSpy: SecureUserSettingsProtocol {

	var invokedScanLockUntilSetter = false
	var invokedScanLockUntilSetterCount = 0
	var invokedScanLockUntil: Date?
	var invokedScanLockUntilList = [Date]()
	var invokedScanLockUntilGetter = false
	var invokedScanLockUntilGetterCount = 0
	var stubbedScanLockUntil: Date!

	var scanLockUntil: Date {
		set {
			invokedScanLockUntilSetter = true
			invokedScanLockUntilSetterCount += 1
			invokedScanLockUntil = newValue
			invokedScanLockUntilList.append(newValue)
		}
		get {
			invokedScanLockUntilGetter = true
			invokedScanLockUntilGetterCount += 1
			return stubbedScanLockUntil
		}
	}

	var invokedAppInstalledDateSetter = false
	var invokedAppInstalledDateSetterCount = 0
	var invokedAppInstalledDate: Date?
	var invokedAppInstalledDateList = [Date?]()
	var invokedAppInstalledDateGetter = false
	var invokedAppInstalledDateGetterCount = 0
	var stubbedAppInstalledDate: Date!

	var appInstalledDate: Date? {
		set {
			invokedAppInstalledDateSetter = true
			invokedAppInstalledDateSetterCount += 1
			invokedAppInstalledDate = newValue
			invokedAppInstalledDateList.append(newValue)
		}
		get {
			invokedAppInstalledDateGetter = true
			invokedAppInstalledDateGetterCount += 1
			return stubbedAppInstalledDate
		}
	}

	var invokedCryptoDataSetter = false
	var invokedCryptoDataSetterCount = 0
	var invokedCryptoData: CryptoData?
	var invokedCryptoDataList = [CryptoData]()
	var invokedCryptoDataGetter = false
	var invokedCryptoDataGetterCount = 0
	var stubbedCryptoData: CryptoData!

	var cryptoData: CryptoData {
		set {
			invokedCryptoDataSetter = true
			invokedCryptoDataSetterCount += 1
			invokedCryptoData = newValue
			invokedCryptoDataList.append(newValue)
		}
		get {
			invokedCryptoDataGetter = true
			invokedCryptoDataGetterCount += 1
			return stubbedCryptoData
		}
	}

	var invokedForcedInformationDataSetter = false
	var invokedForcedInformationDataSetterCount = 0
	var invokedForcedInformationData: ForcedInformationData?
	var invokedForcedInformationDataList = [ForcedInformationData]()
	var invokedForcedInformationDataGetter = false
	var invokedForcedInformationDataGetterCount = 0
	var stubbedForcedInformationData: ForcedInformationData!

	var forcedInformationData: ForcedInformationData {
		set {
			invokedForcedInformationDataSetter = true
			invokedForcedInformationDataSetterCount += 1
			invokedForcedInformationData = newValue
			invokedForcedInformationDataList.append(newValue)
		}
		get {
			invokedForcedInformationDataGetter = true
			invokedForcedInformationDataGetterCount += 1
			return stubbedForcedInformationData
		}
	}

	var invokedOnboardingDataSetter = false
	var invokedOnboardingDataSetterCount = 0
	var invokedOnboardingData: OnboardingData?
	var invokedOnboardingDataList = [OnboardingData]()
	var invokedOnboardingDataGetter = false
	var invokedOnboardingDataGetterCount = 0
	var stubbedOnboardingData: OnboardingData!

	var onboardingData: OnboardingData {
		set {
			invokedOnboardingDataSetter = true
			invokedOnboardingDataSetterCount += 1
			invokedOnboardingData = newValue
			invokedOnboardingDataList.append(newValue)
		}
		get {
			invokedOnboardingDataGetter = true
			invokedOnboardingDataGetterCount += 1
			return stubbedOnboardingData
		}
	}

	var invokedStoredConfigurationSetter = false
	var invokedStoredConfigurationSetterCount = 0
	var invokedStoredConfiguration: RemoteConfiguration?
	var invokedStoredConfigurationList = [RemoteConfiguration]()
	var invokedStoredConfigurationGetter = false
	var invokedStoredConfigurationGetterCount = 0
	var stubbedStoredConfiguration: RemoteConfiguration!

	var storedConfiguration: RemoteConfiguration {
		set {
			invokedStoredConfigurationSetter = true
			invokedStoredConfigurationSetterCount += 1
			invokedStoredConfiguration = newValue
			invokedStoredConfigurationList.append(newValue)
		}
		get {
			invokedStoredConfigurationGetter = true
			invokedStoredConfigurationGetterCount += 1
			return stubbedStoredConfiguration
		}
	}

	var invokedRiskLevelSetter = false
	var invokedRiskLevelSetterCount = 0
	var invokedRiskLevel: RiskLevel?
	var invokedRiskLevelList = [RiskLevel?]()
	var invokedRiskLevelGetter = false
	var invokedRiskLevelGetterCount = 0
	var stubbedRiskLevel: RiskLevel!

	var riskLevel: RiskLevel? {
		set {
			invokedRiskLevelSetter = true
			invokedRiskLevelSetterCount += 1
			invokedRiskLevel = newValue
			invokedRiskLevelList.append(newValue)
		}
		get {
			invokedRiskLevelGetter = true
			invokedRiskLevelGetterCount += 1
			return stubbedRiskLevel
		}
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
