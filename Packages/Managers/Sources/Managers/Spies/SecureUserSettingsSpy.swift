/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import Models

public class SecureUserSettingsSpy: SecureUserSettingsProtocol {
	
	public init() {}

	public var invokedScanLockUntilSetter = false
	public var invokedScanLockUntilSetterCount = 0
	public var invokedScanLockUntil: Date?
	public var invokedScanLockUntilList = [Date]()
	public var invokedScanLockUntilGetter = false
	public var invokedScanLockUntilGetterCount = 0
	public var stubbedScanLockUntil: Date!

	public var scanLockUntil: Date {
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

	public var invokedAppInstalledDateSetter = false
	public var invokedAppInstalledDateSetterCount = 0
	public var invokedAppInstalledDate: Date?
	public var invokedAppInstalledDateList = [Date?]()
	public var invokedAppInstalledDateGetter = false
	public var invokedAppInstalledDateGetterCount = 0
	public var stubbedAppInstalledDate: Date!

	public var appInstalledDate: Date? {
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

	public var invokedForcedInformationDataSetter = false
	public var invokedForcedInformationDataSetterCount = 0
	public var invokedForcedInformationData: ForcedInformationData?
	public var invokedForcedInformationDataList = [ForcedInformationData]()
	public var invokedForcedInformationDataGetter = false
	public var invokedForcedInformationDataGetterCount = 0
	public var stubbedForcedInformationData: ForcedInformationData!

	public var forcedInformationData: ForcedInformationData {
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

	public var invokedHolderSecretKeySetter = false
	public var invokedHolderSecretKeySetterCount = 0
	public var invokedHolderSecretKey: Data?
	public var invokedHolderSecretKeyList = [Data?]()
	public var invokedHolderSecretKeyGetter = false
	public var invokedHolderSecretKeyGetterCount = 0
	public var stubbedHolderSecretKey: Data!

	public var holderSecretKey: Data? {
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

	public var invokedOnboardingDataSetter = false
	public var invokedOnboardingDataSetterCount = 0
	public var invokedOnboardingData: OnboardingData?
	public var invokedOnboardingDataList = [OnboardingData]()
	public var invokedOnboardingDataGetter = false
	public var invokedOnboardingDataGetterCount = 0
	public var stubbedOnboardingData: OnboardingData!

	public var onboardingData: OnboardingData {
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

	public var invokedSelectedIdentitySetter = false
	public var invokedSelectedIdentitySetterCount = 0
	public var invokedSelectedIdentity: String?
	public var invokedSelectedIdentityList = [String?]()
	public var invokedSelectedIdentityGetter = false
	public var invokedSelectedIdentityGetterCount = 0
	public var stubbedSelectedIdentity: String!

	public var selectedIdentity: String? {
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

	public var invokedStoredConfigurationSetter = false
	public var invokedStoredConfigurationSetterCount = 0
	public var invokedStoredConfiguration: RemoteConfiguration?
	public var invokedStoredConfigurationList = [RemoteConfiguration]()
	public var invokedStoredConfigurationGetter = false
	public var invokedStoredConfigurationGetterCount = 0
	public var stubbedStoredConfiguration: RemoteConfiguration!

	public var storedConfiguration: RemoteConfiguration {
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

	public var invokedVerificationPolicySetter = false
	public var invokedVerificationPolicySetterCount = 0
	public var invokedVerificationPolicy: VerificationPolicy?
	public var invokedVerificationPolicyList = [VerificationPolicy?]()
	public var invokedVerificationPolicyGetter = false
	public var invokedVerificationPolicyGetterCount = 0
	public var stubbedVerificationPolicy: VerificationPolicy!

	public var verificationPolicy: VerificationPolicy? {
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

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
