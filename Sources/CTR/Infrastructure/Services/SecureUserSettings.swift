/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable redundant_optional_initialization

import Foundation

protocol SecureUserSettingsProtocol: AnyObject {
	typealias ForcedInformationData = NewFeaturesManager.ForcedInformationData
	typealias OnboardingData = OnboardingManager.OnboardingData
	
	var scanLockUntil: Date { get set }
	var appInstalledDate: Date? { get set }
	var forcedInformationData: ForcedInformationData { get set }
	var holderSecretKey: Data? { get set }
	var onboardingData: OnboardingData { get set }
	var storedConfiguration: RemoteConfiguration { get set }
	var verificationPolicy: VerificationPolicy? { get set }
	
	func wipePersistedData()
}

class SecureUserSettings: SecureUserSettingsProtocol {
	
	struct Defaults {
		static var scanLockUntil: Date = .distantPast
		static var appInstalledDate: Date? = nil
		static var holderSecretKey: Data? = nil
		static var forcedInformationData: NewFeaturesManager.ForcedInformationData = .empty
		static var onboardingData: OnboardingManager.OnboardingData = .empty
		static var storedConfiguration: RemoteConfiguration = .default
		static var verificationPolicy: VerificationPolicy? = .none
	}
	
	@Keychain(name: "scanLockUntil", service: "ScanLockManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	var scanLockUntil: Date = Defaults.scanLockUntil
	
	@Keychain(name: "appInstalledDate", service: "AppInstalledSinceManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var appInstalledDate: Date? = Defaults.appInstalledDate
	
	@Keychain(name: "data", service: "ForcedInformationManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var forcedInformationData: ForcedInformationData = Defaults.forcedInformationData
	
	@Keychain(name: "holderSecretKey", service: "CryptoManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var holderSecretKey: Data? = Defaults.holderSecretKey

	@Keychain(name: "onboardingData", service: "OnboardingManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var onboardingData: OnboardingData = Defaults.onboardingData

	@Keychain(name: "storedConfiguration", service: "RemoteConfigManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	var storedConfiguration: RemoteConfiguration = Defaults.storedConfiguration

	@Keychain(name: "verificationPolicy", service: "RiskLevelManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	var verificationPolicy: VerificationPolicy? = Defaults.verificationPolicy
}

extension SecureUserSettings {

	func wipePersistedData() {
		scanLockUntil = Defaults.scanLockUntil
		appInstalledDate = Defaults.appInstalledDate
		forcedInformationData = Defaults.forcedInformationData
		holderSecretKey = Defaults.holderSecretKey
		onboardingData = Defaults.onboardingData
		storedConfiguration = Defaults.storedConfiguration
		verificationPolicy = Defaults.verificationPolicy
	}
}
