/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
@testable import Transport
@testable import Shared
@testable import Models

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

	var invokedHolderSecretKeySetter = false
	var invokedHolderSecretKeySetterCount = 0
	var invokedHolderSecretKey: Data?
	var invokedHolderSecretKeyList = [Data?]()
	var invokedHolderSecretKeyGetter = false
	var invokedHolderSecretKeyGetterCount = 0
	var stubbedHolderSecretKey: Data!

	var holderSecretKey: Data? {
		set {
			invokedHolderSecretKeySetter = true
			invokedHolderSecretKeySetterCount += 1
			invokedHolderSecretKey = newValue
			invokedHolderSecretKeyList.append(newValue)
		}
		get {
			invokedHolderSecretKeyGetter = true
			invokedHolderSecretKeyGetterCount += 1
			return stubbedHolderSecretKey
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

	var invokedSelectedIdentitySetter = false
	var invokedSelectedIdentitySetterCount = 0
	var invokedSelectedIdentity: String?
	var invokedSelectedIdentityList = [String?]()
	var invokedSelectedIdentityGetter = false
	var invokedSelectedIdentityGetterCount = 0
	var stubbedSelectedIdentity: String!

	var selectedIdentity: String? {
		set {
			invokedSelectedIdentitySetter = true
			invokedSelectedIdentitySetterCount += 1
			invokedSelectedIdentity = newValue
			invokedSelectedIdentityList.append(newValue)
		}
		get {
			invokedSelectedIdentityGetter = true
			invokedSelectedIdentityGetterCount += 1
			return stubbedSelectedIdentity
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

	var invokedVerificationPolicySetter = false
	var invokedVerificationPolicySetterCount = 0
	var invokedVerificationPolicy: VerificationPolicy?
	var invokedVerificationPolicyList = [VerificationPolicy?]()
	var invokedVerificationPolicyGetter = false
	var invokedVerificationPolicyGetterCount = 0
	var stubbedVerificationPolicy: VerificationPolicy!

	var verificationPolicy: VerificationPolicy? {
		set {
			invokedVerificationPolicySetter = true
			invokedVerificationPolicySetterCount += 1
			invokedVerificationPolicy = newValue
			invokedVerificationPolicyList.append(newValue)
		}
		get {
			invokedVerificationPolicyGetter = true
			invokedVerificationPolicyGetterCount += 1
			return stubbedVerificationPolicy
		}
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
