/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable let_var_whitespace redundant_optional_initialization

import Foundation

protocol SecureUserSettingsProtocol: AnyObject {
	typealias CryptoData = CryptoManager.CryptoData
	typealias ForcedInformationData = ForcedInformationManager.ForcedInformationData
	typealias OnboardingData = OnboardingManager.OnboardingData
	
	var scanLockUntil: Date { get set }
	var appInstalledDate: Date? { get set }
	var cryptoData: CryptoData { get set }
	var forcedInformationData: ForcedInformationData { get set }
	var onboardingData: OnboardingData { get set }
	var storedConfiguration: RemoteConfiguration { get set }
	var riskLevel: RiskLevel? { get set }
	
	func wipePersistedData()
}

class SecureUserSettings: SecureUserSettingsProtocol {
	struct Defaults {
		static var scanLockUntil: Date = .distantPast
		static var appInstalledDate: Date? = nil
		static var cryptoData: CryptoManager.CryptoData = .empty
		static var forcedInformationData: ForcedInformationManager.ForcedInformationData = .empty
		static var onboardingData: OnboardingManager.OnboardingData = .empty
		static var storedConfiguration: RemoteConfiguration = .default
		static var riskLevel: RiskLevel? = .none
	}
	
	@Keychain(name: "scanLockUntil", service: "ScanLockManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	var scanLockUntil: Date = Defaults.scanLockUntil
	
	@Keychain(name: "appInstalledDate", service: "AppInstalledSinceManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var appInstalledDate: Date? = Defaults.appInstalledDate

	@Keychain(name: "cryptoData", service: "CryptoManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var cryptoData: CryptoData = Defaults.cryptoData

	@Keychain(name: "data", service: "ForcedInformationManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var forcedInformationData: ForcedInformationData = Defaults.forcedInformationData

	@Keychain(name: "onboardingData", service: "OnboardingManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	var onboardingData: OnboardingData = Defaults.onboardingData

	@Keychain(name: "storedConfiguration", service: "RemoteConfigManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	var storedConfiguration: RemoteConfiguration = Defaults.storedConfiguration

	@Keychain(name: "riskLevel", service: "RiskLevelManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	var riskLevel: RiskLevel? = Defaults.riskLevel
}

extension SecureUserSettings {

	func wipePersistedData() {
		scanLockUntil = Defaults.scanLockUntil
		appInstalledDate = Defaults.appInstalledDate
		cryptoData = Defaults.cryptoData
		forcedInformationData = Defaults.forcedInformationData
		onboardingData = Defaults.onboardingData
		storedConfiguration = Defaults.storedConfiguration
		riskLevel = Defaults.riskLevel
	}
}
